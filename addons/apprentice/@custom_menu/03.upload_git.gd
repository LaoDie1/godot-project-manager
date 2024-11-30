#============================================================
#    03.upload Git
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-30 22:08:55
# - version: 4.3.0.stable
#============================================================
## 上传到 Git 上
extends AbstractCustomMenu

var dialog : ConfirmationDialog
var text_edit : TextEdit

func _enter():
	dialog = ConfirmationDialog.new()
	dialog.size = Vector2(700, 400)
	text_edit = TextEdit.new()
	text_edit.placeholder_text = "git 提交描述"
	dialog.add_child(text_edit)
	var root := EditorInterface.get_base_control()
	root.add_child.call_deferred(dialog)
	dialog.get_ok_button().pressed.connect(
		func():
			var commit_text = text_edit.text.strip_edges()
			if commit_text.is_empty():
				commit_text = "update " + Time.get_datetime_string_from_system(false, true)
			var thread := Thread.new()
			thread.start(
				func():
					OS.execute("CMD.exe", ["/C", "git add ."])
					OS.execute("CMD.exe", ["/C", "git", "commit", "-m", '"%s"' % commit_text])
					for i in 3:
						var output = []
						OS.execute("CMD.exe", ["/C", "git push"], output)
						var text := str(output[0])
						if text.contains("Enumerating objects") or text.contains("Everything up-to-date"):
							break
						else:
							if i < 2:
								push_warning("上传失败，重新上传： ", text)
			)
	)

func _exit():
	dialog.queue_free()

func _get_menu_name():
	return "上传到 git"

func _execute():
	dialog.popup_centered()
	text_edit.grab_focus.call_deferred()