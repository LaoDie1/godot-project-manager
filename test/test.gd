@tool
extends EditorScript


func _run() -> void:
	CMDUtil.current_is_running()
	return
	
	#print( OS.get_executable_path())
	
	var pid_to_check = "godot" # 这里替换为你要检查的实际PID
	for line in CMDUtil.find_running_program("Godot"):
		print(line)
	
