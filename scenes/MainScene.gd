extends Node3D

@onready var pause_menu = $PauseMenu
@onready var player = $Player
var paused = false

func _ready():
	pause_menu.hide()
	Engine.time_scale = 1
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.unfreeze()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
		
func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		player.unfreeze()
	else:
		pause_menu.show()
		Engine.time_scale = 0
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		player.freeze()
	paused = !paused
