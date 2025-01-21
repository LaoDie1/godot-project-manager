#============================================================
#    Ffmpeg Util
#============================================================
# - author: zhangxuetu
# - datetime: 2024-12-02 14:56:08
# - version: 4.3.0.stable
#============================================================
class_name FFMpegUtil

## ffmpeg.exe 文件路径 
static var ffmpeg_path: String = ""

static var enabled_print_command: bool = false


static func _execute_command(params: Array) -> Dictionary:
	assert(ffmpeg_path != "", "没有置 ffmpeg 的路径")
	var p : Array = ["/C"]
	p.append_array(params)
	var output: Array = []
	var err = OS.execute("CMD.exe", p, output, true)
	if enabled_print_command:
		print("CMD.exe /C ", " ".join(params))
	return {
		"command": " ".join(params),
		"error": err,
		"output": output[0]
	}

## 生成预览图片
static func get_video_preview_image(video_path: String) -> Image:
	assert(ffmpeg_path != "", "没有设置 ffmpeg_path 属性")
	var file_name : String = FileUtil.get_file_md5(video_path, false) + ".png"
	var path : String = OS.get_cache_dir() + "/Temp".path_join(file_name)
	if not FileAccess.file_exists(path):
		_execute_command([ffmpeg_path, "-i", '"%s"' % video_path, "-ss", "00:00:10", "-vframes", "1", '"%s"' % path])
	if FileAccess.file_exists(path):
		return Image.load_from_file(path)
	return null

## 转为 mp3 文件
static func convert_to_mp3(video_path: String, new_path: String) -> int:
	var result : Dictionary = _execute_command([ffmpeg_path, '-i', '"%s"' % video_path, '"%s"' % new_path])
	return result["error"]


# 编码速度和质量
const Preset = {
	ULTRAFAST = "ultrafast",
	SUPERFAST = "superfast",
	VERYFAST = "veryfast",
	FASTER = "faster",
	FAST = "fast",
	MEDIUM = "medium",
	SLOW = "slow",
	SLOWER = "slower",
	VERYSLOW = "veryslow",
}

## 压缩视频
static func compress_video(video_path: String, new_path: String, preset: String = "medium") -> int:
	var result : Dictionary = _execute_command([
		ffmpeg_path, 
		'-i', '"%s"' % video_path, 
		"-c:v", "libx264",
		"-preset", preset,
		'"%s"' % new_path
	])
	return result["error"]
