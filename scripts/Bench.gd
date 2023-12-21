extends InteractableObject

class_name Bench

# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer3D.connect("finished", Callable(self, "_on_AudioStreamPlayer3D_finished"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func GetExerciseName():
	return "sitting"

func PlaySound():
	if !$AudioStreamPlayer3D.playing:
		$AudioStreamPlayer3D.play()
	else:
		$AudioStreamPlayer3D.stop()
		
func _on_AudioStreamPlayer3D_finished():
	$AudioStreamPlayer3D.play()
