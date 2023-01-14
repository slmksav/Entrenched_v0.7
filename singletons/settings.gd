extends Node

signal change_fps_target(target)
signal change_fullscreen(value)


enum FPS_TARGET {
	TARGET_30,
	TARGET_60
}

func full_screen(value: bool):
	OS.set_window_fullscreen(value)
	emit_signal("change_fullscreen", value)

func is_fullscreen() -> bool:
	return OS.is_window_fullscreen()

func set_fps_target(mode: int):
	match mode:
		FPS_TARGET.TARGET_30:
			Engine.set_target_fps(30)
			emit_signal("change_fps_target", 30)
		FPS_TARGET.TARGET_60:
			Engine.set_target_fps(60)
			emit_signal("change_fps_target", 60)
		_:
			printerr("Target FPS are not available")
