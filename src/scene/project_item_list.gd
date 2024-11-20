#============================================================
#    Project Item List
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-20 22:40:00
# - version: 4.3.0.stable
#============================================================
extends ItemList

signal edit_project(project_dir: String)

var projects := {}
var init_status := false


func _init() -> void:
	item_activated.connect(
		func(idx):
			var path = self.get_item_metadata(idx)
			self.edit_project.emit(path)
	)

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


func add_file(dir: String):
	if FileUtil.dir_exists(dir) and not projects.has(dir):
		var project_file = dir.path_join("project.godot")
		if FileUtil.file_exists(project_file):
			var project = ConfigFile.new()
			project.load(project_file)
			var icon_file = str(project.get_value("application", "config/icon", "res://src/assets/icon.svg")).replace(
				"res://", dir if dir.ends_with("/") else (dir + "/")
			)
			var icon_image = FileUtil.load_image(icon_file)
			var icon = ImageTexture.create_from_image(icon_image)
			var project_name = project.get_value("application", "config/name")
			self.add_item(project_name, icon)
			self.set_item_metadata(self.item_count - 1, dir)
			self.set_item_tooltip(self.item_count - 1, dir)
			projects[dir] = null
			if init_status:
				Config.Hide.godot_projects_dir_list.get_value().append(dir)
