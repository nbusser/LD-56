extends Node

const ImageExportScene = preload("res://src/ImageExport/ImageExportScene.tscn")

func create_end_level_image(user_image_texture: Texture2D, level_data: LevelData, grade_text: String):
	var viewport: Viewport = SubViewport.new()
	viewport.size = Vector2i(640, 480)
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	var scene = ImageExportScene.instantiate()
	scene.init(level_data, user_image_texture, grade_text)
	
	viewport.add_child(scene)
	add_child(viewport)
	
	# we need to wait for 2 frames to finish rendering
	await get_tree().process_frame
	await get_tree().process_frame
	
	# viewport is rendered, dump image
	var image = viewport.get_texture().get_image()
	
	# clean tree
	remove_child(viewport)
	viewport.queue_free()
	
	return image

static func save_image(image: Image, filename: String = 'test'):
	if not filename.ends_with('.png'):
		filename += '.png'
	
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
