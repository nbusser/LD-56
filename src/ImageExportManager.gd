extends Node

const _1_MALEKITSCH = preload("res://assets/sprites/models/1-malekitsch.png")

#func _ready() -> void:
#	save_image(_1_MALEKITSCH.get_image())

static func save_image(image: Image, filename: String = 'test.png'):
	if OS.has_feature('web'):
		JavaScriptBridge.download_buffer(image.save_png_to_buffer(), filename)
		
	elif OS.has_feature('pc'):
		var fd = FileDialog.new()
		fd.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		fd.access = FileDialog.ACCESS_FILESYSTEM
		fd.use_native_dialog = true
		fd.add_filter("*.png", "PNG image")
		fd.current_file = filename
		fd.popup()
		
		var path = await fd.file_selected
		print(path)
		
		image.save_png(path)
