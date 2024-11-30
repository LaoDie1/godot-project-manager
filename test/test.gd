@tool
extends EditorScript


func _run() -> void:
	pass
	
	var output = []
	OS.execute("git", ["push"], output, true)
	print(output)
