#============================================================
#    Clipboard
#============================================================
# - author: zhangxuetu
# - datetime: 2025-01-08 22:58:39
# - version: 4.4.0.dev7
#============================================================
## 剪贴板包装器
##
##用于检测剪贴板的当前数据和上次是否一样
class_name ClipboardWrapper

var temp
var last_image_hash: int
var current_data


func _init() -> void:
	if DisplayServer.clipboard_has_image():
		current_data = DisplayServer.clipboard_get_image()
		last_image_hash = current_data.data.hash()
	else:
		current_data = DisplayServer.clipboard_get()


func get_data():
	return current_data


## 更新检测数据。如果返回 true 代表剪贴板内容发生了改变
func update() -> bool:
	# 获取剪贴板内容
	if DisplayServer.clipboard_has_image():
		temp = DisplayServer.clipboard_get_image()
	else:
		temp = DisplayServer.clipboard_get()
	
	# 判断类型并处理
	if temp is String:
		if temp != "" and (current_data is not String or current_data != temp):
			current_data = temp
			last_image_hash = 0
			return true
	
	elif temp is Image:
		if last_image_hash != temp.data.hash():
			current_data = temp
			last_image_hash = temp.data.hash()
			return true
	return false
