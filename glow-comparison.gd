extends Node

@onready var world_environment: WorldEnvironment = %WorldEnvironment


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var env := world_environment.environment
	
	get_window().use_hdr_2d = true;
	await get_tree().create_timer(0).timeout
	await RenderingServer.frame_post_draw
	
	print("| Mobile HDR 2D (this PR) | Mobile HDR 2D (4.5) | Forward+ HDR 2D (4.5)\n| --- | --- | ---")
	for level in range(7):
		for l in range(7):
			if l ==  level:
				env.set_glow_level(l, 1)
			else:
				env.set_glow_level(l, 0)
		
		await get_tree().create_timer(0).timeout
		await RenderingServer.frame_post_draw
		var folder_path: String = "glow_comparison/level_%d/" % (level + 1)
		DirAccess.make_dir_recursive_absolute("user://%s" % folder_path)
		_save_image("%s4.5_forward-hdr2d" % folder_path)

		var table_line: String = ""
		table_line += " | ![mobile-hdr2d]"
		table_line += "(https://github.com/allenwp/godot-glow-comparison/raw/refs/heads/main/%s/update_mobile-hdr2d.webp)" % [folder_path]
		table_line += " | ![4.5_mobile-hdr2d]"
		table_line += "(https://github.com/allenwp/godot-glow-comparison/raw/refs/heads/main/%s/4.5_mobile-hdr2d.webp)" % [folder_path]
		table_line += " | ![4.5_forward-hdr2d]"
		table_line += "(https://github.com/allenwp/godot-glow-comparison/raw/refs/heads/main/%s/4.5_forward-hdr2d.webp)" % [folder_path]
		print(table_line)
	

	get_window().use_hdr_2d = false;
	await get_tree().create_timer(0).timeout
	await RenderingServer.frame_post_draw
	
	print("\n| Mobile (this PR) | Mobile (4.5) | Forward+ (4.5)\n| --- | --- | ---")
	for level in range(7):
		for l in range(7):
			if l ==  level:
				env.set_glow_level(l, 1)
			else:
				env.set_glow_level(l, 0)
		
		await get_tree().create_timer(0).timeout
		await RenderingServer.frame_post_draw
		var folder_path: String = "glow_comparison/level_%d/" % (level + 1)
		DirAccess.make_dir_recursive_absolute("%s" % folder_path)
		_save_image("%s4.5_forward" % folder_path)

		var table_line: String = ""
		table_line += " | ![mobile]"
		table_line += "(https://github.com/allenwp/godot-glow-comparison/raw/refs/heads/main/%s/update_mobile.webp)" % [folder_path]
		table_line += " | ![4.5_mobile]"
		table_line += "(https://github.com/allenwp/godot-glow-comparison/raw/refs/heads/main/%s/4.5_mobile.webp)" % [folder_path]
		table_line += " | ![4.5_forward]"
		table_line += "(https://github.com/allenwp/godot-glow-comparison/raw/refs/heads/main/%s/4.5_forward.webp)" % [folder_path]
		print(table_line)

	OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://"))


func _save_image(path: String) -> void:
	# PNG does not save color profile in a way that Firefox plays nicely with
	# get_tree().root.get_viewport().get_texture().get_image().save_png(path + ".png")
	# Save lossless webp instead:
	get_tree().root.get_viewport().get_texture().get_image().save_webp("user://" + path + ".webp")
