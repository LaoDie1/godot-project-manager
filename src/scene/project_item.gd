#============================================================
#    Project Item
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-21 01:07:11
# - version: 4.3.0.stable
#============================================================
class_name ProjectItem
extends MarginContainer


signal selected
signal activated


const SELECTED_STYLE = preload("res://src/assets/selected_panel_style.tres")
const ONE_HOUR_SECOND = 60 * 60


@export var disabled: bool = false:
	set(v):
		if disabled != v:
			disabled = v
			select_status = not select_status
			select_status = not select_status
@export var path: String:
	set(v):
		if path != v:
			path = v
			if not is_node_ready():
				await ready
			var project_file = path.path_join("project.godot")
			var project = ConfigFile.new()
			project.load(project_file)
			var icon_file = str(project.get_value("application", "config/icon", "res://src/assets/icon.svg")).replace(
				"res://", path if path.ends_with("/") else (path + "/")
			)
			var icon_image = FileUtil.load_image(icon_file)
			var icon = ImageTexture.create_from_image(icon_image)
			texture_rect.texture = icon
			project_name = project.get_value("application", "config/name")
			label.text = project_name
			self.tooltip_text = path
			var version = project.get_value("application", "config/features", null)
			if version:
				version_label.text = str(version[0])
			modified_time = FileAccess.get_modified_time(path) + 8 * ONE_HOUR_SECOND
			modified_time_label.text = Time.get_datetime_string_from_unix_time(modified_time, true)
@export var select_status: bool:
	set(v):
		if select_status != v:
			select_status = v and not disabled
			if select_status:
				panel.modulate.a = 1
				panel.add_theme_stylebox_override("panel", SELECTED_STYLE)
				self.selected.emit()
			else:
				panel.remove_theme_stylebox_override("panel")

@onready var texture_rect: TextureRect = %TextureRect
@onready var label: Label = %Label
@onready var panel: Panel = $Panel
@onready var version_label: Label = %VersionLabel
@onready var modified_time_label: Label = %ModifiedTimeLabel

var project_name := ""
var modified_time := 0


func _init() -> void:
	mouse_entered.connect(
		func():
			if not select_status:
				panel.modulate.a = 0.3
	)
	mouse_exited.connect(
		func():
			panel.modulate.a = 1
	)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			select_status = true
			if event.double_click:
				self.activated.emit()
