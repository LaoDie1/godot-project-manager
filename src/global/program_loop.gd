#============================================================
#    Program Loop
#============================================================
# - author: zhangxuetu
# - datetime: 2024-12-01 12:49:16
# - version: 4.3.0.stable
#============================================================
class_name ProgramLoop
extends SceneTree

var resume : bool = true

func _initialize() -> void:
	if not OS.has_feature("editor") and SystemUtil.current_is_running():
		resume = false
		quit()
		push_error("已经正在执行了")
