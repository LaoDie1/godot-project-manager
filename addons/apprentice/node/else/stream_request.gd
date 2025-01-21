#============================================================
#    Stream Request
#============================================================
# - author: zhangxuetu
# - datetime: 2025-01-06 17:47:33
# - version: 4.3.0.stable
#============================================================
## 流式获取数据请求
class_name StreamRequest
extends Node


signal responsed(body_chunk: PackedByteArray)
signal connected  ## 已连接
signal connect_closed  ##连接关闭


var http_client : HTTPClient = HTTPClient.new()
var is_connected : bool = false


func request(url: String, headers: PackedStringArray = PackedStringArray(), method: HTTPClient.Method = 0, request_body: String = "") -> void:
	var url_parts = url.split("://")
	var protocol : String = url_parts[0]  # "https" 或 "http"
	var host_and_path = url_parts[1].split("/", true, 1)
	var host : String = host_and_path[0]  # "api.deepseek.com"
	var path : String = ("/" + host_and_path[1] if host_and_path.size() > 1 else "/")  # "/chat/completions"
	
	# 设置端口和 SSL
	var port : int = 443 if protocol == "https" else 80
	var tls_options = TLSOptions.client() if protocol == "https" else null
	
	# 连接到主机
	var error : int = http_client.connect_to_host(host, port, tls_options)
	if error != OK:
		push_error("Failed to connect to host: ", error)
		return

	# 等待连接完成
	while http_client.get_status() == HTTPClient.STATUS_CONNECTING or http_client.get_status() == HTTPClient.STATUS_RESOLVING:
		http_client.poll()
		OS.delay_msec(100)

	if http_client.get_status() != HTTPClient.STATUS_CONNECTED:
		push_error("Failed to connect to host. Status: ", http_client.get_status())
		return
	
	error = http_client.request(method, path, headers, request_body)
	if error != OK:
		push_error("Failed to send request: ", error, "  ", error_string(error))
		return
	
	# 开始读取流式响应
	is_connected = true
	set_process(true)
	connected.emit()


func _ready() -> void:
	set_process(false)

func _process(delta):
	if not is_connected:
		return
	
	# 检查是否有新数据
	http_client.poll()
	match http_client.get_status():
		HTTPClient.STATUS_BODY:
			# 读取分块数据
			var chunk = http_client.read_response_body_chunk()
			if chunk.size() > 0:
				responsed.emit(chunk)
		HTTPClient.STATUS_DISCONNECTED, HTTPClient.STATUS_CONNECTED:
			close()


func close():
	# 连接关闭
	is_connected = false
	connect_closed.emit()
	http_client.close()
