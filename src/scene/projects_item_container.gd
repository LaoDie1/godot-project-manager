#============================================================
#    Projects Item Container
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-21 01:03:01
# - version: 4.3.0.stable
#============================================================
extends Control

signal edit_project(project_dir: String)

var projects := {}
var init_status := false
var last_selected_item = null

@onready var item_container: HFlowContainer = %ItemContainer



func _ready() -> void:
	var window : Window = Engine.get_main_loop().root
	window.files_dropped.connect(
		func(files):
			for dir in files:
				add_file(dir)
	)
	for dir in Config.Hide.godot_projects_dir_list.get_value([]):
		add_file(dir)
	self.init_status = true
	if item_container.get_child_count() > 0:
		item_container.get_child(0).select_status = true


func add_file(dir: String):
	if FileUtil.dir_exists(dir) and not projects.has(dir):
		var project_file = dir.path_join("project.godot")
		if FileUtil.file_exists(project_file):
			const PROJECT_ITEM = preload("res://src/scene/project_item.tscn")
			var item = PROJECT_ITEM.instantiate()
			item_container.add_child(item)
			item.path = dir
			item.selected.connect(
				func():
					if last_selected_item:
						last_selected_item.select_status = false
					last_selected_item = item
			)
			item.double_clicked.connect(
				func():
					self.edit_project.emit(dir)
			)
			projects[dir] = null
			if init_status:
				Config.Hide.godot_projects_dir_list.get_value().append(dir)
