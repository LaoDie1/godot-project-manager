#============================================================
#    Multi Split Container
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-27 23:37:27
# - version: 4.3.0.dev5
#============================================================
## 多节点排列
##
##对添加的节点进行多行排列.
class_name MultiSplitContainer
extends Control


signal newly_item(item: Control)

@export var horizontal : bool = true ## 水平排列，如果为 [code]false[/code] 则为垂直排列
@export var separation : int = 8 ## 间隔距离
@export var right_expand_width : int = 16 ## 右侧扩展宽度


var item_list : DoubleLinkList = DoubleLinkList.new()


func _ready() -> void:
	resized.connect(
		func():
			if item_list.get_count() > 0:
				var axis : int = (Vector2.AXIS_Y if horizontal else Vector2.AXIS_X)
				item_list.for_next(item_list.get_first(), func(item: Control):
					item.size[axis] = self.size[axis]
					, 
					true
				)
	)


func _update_mini_width():
	var last : Control = item_list.get_last()
	var axis : int = (Vector2.AXIS_X if horizontal else Vector2.AXIS_Y)
	if last:
		await Engine.get_main_loop().process_frame
		self.custom_minimum_size[axis] = (
			last.size[axis] 
			+ last.position[axis] 
			+ separation
		) + right_expand_width
		self.size[axis] = self.custom_minimum_size[axis]
	else:
		self.custom_minimum_size[axis] = 0
		self.size[axis] = 0


func get_items() -> Array:
	return item_list.get_list()

func add_item(item: Control):
	self.add_child(item)
	if item_list.size() > 0:
		var last : Control = item_list.get_last()
		if is_instance_valid(last):
			var axis : int = (Vector2.AXIS_X if horizontal else Vector2.AXIS_Y)
			item.position[axis] = last.position[axis] + last.size[axis] + separation
	# 其他
	item_list.append(item)
	item.resized.connect(update_after.bind(item))
	item.tree_exited.connect(remove_item.bind(item))
	newly_item.emit(item)
	_update_mini_width()

func remove_item(item: Control):
	var previous : Control = item_list.get_previous(item)
	var next : Control = item_list.get_next(item)
	item_list.erase(item)
	if next:
		var axis : int = (Vector2.AXIS_X if horizontal else Vector2.AXIS_Y)
		if previous != null:
			next.position[axis] = previous.position[axis] + previous.size[axis] + separation
		else:
			next.position[axis] = 0
	if item.is_inside_tree():
		remove_child(item)
	update_after.call_deferred(previous)
	_update_mini_width.call_deferred()

func update_after(node: Control) -> void:
	var axis : int = (Vector2.AXIS_X if horizontal else Vector2.AXIS_Y)
	var last = [node]
	item_list.find_next(node, func(item: Control):
		item.position[axis] = last[0].position[axis] + last[0].size[axis]
		last[0] = item
	)
