#============================================================
#    Project Item Container
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-21 01:03:01
# - version: 4.3.0.stable
#============================================================
class_name ProjectItemContainer
extends Control


signal edit_project(project_dir: String)

var projects := {}
var init_status := false
var shift_select := false
var last_selected_items : Array[ProjectItem] = []

@onready var item_container: HFlowContainer = %ItemContainer


func _ready() -> void:
	var window : Window = Engine.get_main_loop().root
	window.files_dropped.connect(
		func(files):
			for dir in files:
				add_item(dir)
	)
	for dir in Config.Project.projects_dir_list.get_value([]):
		add_item(dir)
	self.init_status = true
	if item_container.get_child_count() > 0:
		item_container.get_child(0).select_status = true


func add_item(dir: String) -> void:
	dir = dir.replace("\\", "/").strip_edges()
	if dir.ends_with("/"):
		dir = dir.substr(0, dir.length()-1)
	if FileUtil.dir_exists(dir) and not projects.has(dir):
		projects[dir] = null
		var project_file = dir.path_join("project.godot")
		if FileUtil.file_exists(project_file):
			const PROJECT_ITEM = preload("res://src/scene/project_item.tscn")
			var item : ProjectItem = PROJECT_ITEM.instantiate()
			item.selected.connect(
				func():
					if shift_select:
						return
					if Input.is_key_pressed(KEY_SHIFT):
						shift_select = true
						if not last_selected_items.is_empty():
							var begin = last_selected_items[0].get_index()
							var end = item.get_index() + 1
							if end < begin:
								var tmp = end
								end = begin
								begin = tmp
							last_selected_items.clear()
							for i in range(begin, end):
								item_container.get_child(i).select_status = true
								last_selected_items.append(item_container.get_child(i))
						shift_select = false
					else:
						for i in get_items():
							if i != item:
								i.select_status = false
						last_selected_items.clear()
						last_selected_items.append(item)
			)
			item.activated.connect(
				func():
					self.edit_project.emit(dir)
			)
			item_container.add_child(item)
			item.path = dir
			if init_status:
				Config.Project.projects_dir_list.get_value().append(dir)


func remove_item(dir: String) -> void:
	if projects.has(dir):
		for child in item_container.get_children():
			if child.path == dir:
				child.queue_free()
				break
		Config.Project.projects_dir_list.get_value().erase(dir)


func select(idx: int) -> void:
	if idx >= item_container.get_child_count():
		idx = item_container.get_child_count() - 1
	elif idx < -1:
		idx = 0
	if idx > -1:
		item_container.get_child(idx).select_status = true


func get_selected_items() -> Array[ProjectItem]:
	var list : Array[ProjectItem] = []
	for child in item_container.get_children():
		if child.select_status:
			list.append(child)
	return list

func get_first_selected_item() -> ProjectItem:
	if last_selected_items.is_empty():
		return null
	return last_selected_items[0]

func get_item_count() -> int:
	return item_container.get_child_count()

func get_items() -> Array[ProjectItem]:
	return Array(item_container.get_children(), TYPE_OBJECT, "MarginContainer", ProjectItem)

## 项目重新排序
func sort_item(callback: Callable):
	var list = item_container.get_children()
	for i in range(get_item_count()-1,-1,-1):
		item_container.remove_child(list[i])
	list.sort_custom(callback)
	for item in list:
		item_container.add_child(item)
