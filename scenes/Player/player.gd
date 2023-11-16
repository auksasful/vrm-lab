extends CharacterBody3D

@onready var gunRay = $Head/Camera3d/RayCast3d as RayCast3D
@onready var Cam = $Head/Camera3d as Camera3D
@onready var Hand = $Head/Camera3d/Hand
@onready var AnimPlayer = $AnimationPlayer
@onready var my_timer = Timer.new()
@export var _bullet_scene : PackedScene
var mouseSensibility = 1200
var mouse_relative_x = 0
var mouse_relative_y = 0
const SPEED = 2.0
const JUMP_VELOCITY = 4.5

var pickedUp = false
var doingExercise = false
var sitting = false
var drinking = false
var currPickedObject = null
var currPickedObjectPosition = null
var currPickedObjectRotation = Quaternion()
var pullPower = 20
var InteractionTextGlobal = null

var BigWeightParentObject = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#Captures mouse and stops rgun from hitting yourself
	gunRay.add_exception(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	AnimPlayer.connect("animation_finished", Callable(self, "_on_AnimationPlayer_animation_finished"))
	my_timer.wait_time = 1  # 1 second
	my_timer.one_shot = true
	add_child(my_timer)
	my_timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
	AnimPlayer.play("Idle")
	Global.CheckTaskDone()

	#InteractionTextGlobal = find_node_by_script("InteractionText") as RichTextLabel

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	var interactingObject = null
	if gunRay.get_collider() is InteractableObject:
		interactingObject = gunRay.get_collider() as InteractableObject
	
	if gunRay.get_collider() is PickableObject:
		interactingObject = gunRay.get_collider() as PickableObject
	
	if not drinking:
		if pickedUp:
			Global.CurrentInteractionText = "Click to release object (" + currPickedObject.GetExerciseName() + ")"
			if currPickedObject is WaterBottle:
				Global.CurrentInteractionText += " or press [E] to drink"
			elif doingExercise:
				Global.CurrentInteractionText = "Keep pressing [E] to continue doing exercise!"
			else:
				Global.CurrentInteractionText += " or press [E] to do exercise (" + currPickedObject.GetExerciseName() + ")"
				if interactingObject is InclineBench:
					Global.CurrentInteractionText = "Press [E] to interact (" + interactingObject.GetExerciseName() + ")"
		elif doingExercise:
			Global.CurrentInteractionText = "Keep pressing [E] to continue doing exercise!"
		elif sitting:
			Global.CurrentInteractionText = "Press [E] to stop resting"
		else:
			if interactingObject is PickableObject:
				Global.CurrentInteractionText = "Click to pick up object (" + interactingObject.GetExerciseName() + ")"
			elif interactingObject is InteractableObject:
				if not interactingObject is InclineBench:
					Global.CurrentInteractionText = "Press [E] to interact (" + interactingObject.GetExerciseName() + ")"
				else:
					Global.CurrentInteractionText = ""
			else:
				Global.CurrentInteractionText = ""
	else:
		Global.CurrentInteractionText = ""
			
	if Input.is_action_just_pressed("interact"):
		interact()
		
	if doingExercise or sitting:
		return
	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Handle Shooting
	if Input.is_action_just_pressed("Shoot"):
		pickup()
		#shoot()
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
 
	move_and_slide()
	
	#pull picked object
	if pickedUp and currPickedObject != null:
		#print("pull obj")
		var a = currPickedObject.global_transform.origin
		var b = Hand.global_transform.origin
		currPickedObject.set_linear_velocity((b-a) * pullPower)
		currPickedObject.look_at(global_transform.origin , Vector3.UP)

func _input(event):
	if event is InputEventMouseMotion:
		if doingExercise:
			return
		rotation.y -= event.relative.x / mouseSensibility
		$Head/Camera3d.rotation.x -= event.relative.y / mouseSensibility
		$Head/Camera3d.rotation.x = clamp($Head/Camera3d.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		#$Head/HoldObjectPosition.rotation.x -= event.relative.y / mouseSensibility
		#$Head/HoldObjectPosition.rotation.x = clamp($Head/Camera3d.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)

func shoot():
	if not gunRay.is_colliding():
		return
	var bulletInst = _bullet_scene.instantiate() as Node3D
	bulletInst.set_as_top_level(true)
	get_parent().add_child(bulletInst)
	bulletInst.global_transform.origin = gunRay.get_collision_point() as Vector3
	bulletInst.look_at((gunRay.get_collision_point()+gunRay.get_collision_normal()),Vector3.BACK)
	print(gunRay.get_collision_point())
	print(gunRay.get_collision_point()+gunRay.get_collision_normal())
	
func pickup():
	if not pickedUp:
		if not gunRay.is_colliding():
			return
		print("Pickup 1!")
		print("Pickedup: " + str(pickedUp))
		if gunRay.get_collider() is PickableObject:
			print("Pickup 2!")
			currPickedObject = gunRay.get_collider() as RigidBody3D
			#currPickedObject.get_parent().remove_child(currPickedObject)
			currPickedObjectRotation = Quaternion(currPickedObject.global_transform.basis)  # Store the initial rotation
			currPickedObject.freeze = false
			#currPickedObject.collision_layer &= ~(1 << 0)
			currPickedObject.collision_layer = 0
			currPickedObject.collision_mask = 0
			#set_collision_masks(currPickedObject, false)
			currPickedObject.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
			currPickedObjectPosition = Vector3(currPickedObject.transform.origin.x, currPickedObject.transform.origin.y, currPickedObject.transform.origin.z)
			#$Head/Camera3d.add_child(currPickedObject)
			
			#currPickedObject.transform.origin = Vector3($Head/HoldObjectPosition.transform.origin.x, $Head/HoldObjectPosition.transform.origin.y, $Head/HoldObjectPosition.transform.origin.z)
			pickedUp = true
	else:
		pickedUp = false
		#currPickedObject.global_transform.basis = Basis(currPickedObjectRotation)
		currPickedObject.freeze = true
		var new_rotation = Quaternion(Vector3(0, 1, 0), PI / 2)  # Rotate 90 degrees around Y axis
		var new_transform = Transform3D(currPickedObjectRotation, currPickedObjectPosition)
		
		currPickedObject.transform = new_transform
		currPickedObject.collision_layer = 1
		currPickedObject.collision_layer = 2
		currPickedObject.collision_mask = 1
		#set_collision_masks(currPickedObject, true)
		pass
		
func interact():
	print("interact button pressed")
	if doingExercise:
		my_timer.stop()
		my_timer.start()
		print("timer reset")	
		return
	
	if sitting:
		AnimPlayer.play("Idle")
		sitting = false
		return
		
	if pickedUp:
		if currPickedObject is WaterBottle:
			print("drink water now")
			drinking = true
			currPickedObject.visible = false
			AnimPlayer.play("Drink")
		if currPickedObject is Dumbells:
			print("lift dumbells")
			doingExercise = true
			if gunRay.is_colliding():
				if gunRay.get_collider() is InclineBench:
					print("Dumbell press")
					currPickedObject.visible = false
					AnimPlayer.play("Dumbell press")
					my_timer.start()
					doingExercise = true
					return
			print("Bicep curl")
			currPickedObject.visible = false
			AnimPlayer.play("Bicep curl")
			my_timer.start()
			doingExercise = true
		return
	
	if not gunRay.is_colliding():
			return
		
	if gunRay.get_collider() is PullUp:
		print("do pull up now")
		AnimPlayer.play("Pull up")
		my_timer.start()
		doingExercise = true
	elif gunRay.get_collider() is Dip:
		print("do dip now")
		AnimPlayer.play("Dip")
		my_timer.start()
		doingExercise = true
	elif gunRay.get_collider() is PushUpMat:
		print("do push up now")
		AnimPlayer.play("Push up")
		my_timer.start()
		doingExercise = true
	elif gunRay.get_collider() is TreadMill:
		print("do running now")
		AnimPlayer.play("Run")
		my_timer.start()
		doingExercise = true
	elif gunRay.get_collider() is Bench:
		print("do sitting now")
		AnimPlayer.play("Sit")
		sitting = true
	elif gunRay.get_collider() is BenchPress:
		print("do bench press now")
		AnimPlayer.play("bench press")
		my_timer.start()
		doingExercise = true
	elif gunRay.get_collider() is BigWeightParent:
		print("do deadlift press now")
		AnimPlayer.play("Deadlift")
		my_timer.start()
		doingExercise = true
		BigWeightParentObject = gunRay.get_collider() as InteractableObject
		BigWeightParentObject.visible = false
		
		
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Pull up":  # Replace with your specific animation name
		Global.animation_pullup_count += 1
		#print("Animation pullup has looped ", animation_pullup_count, " times") 
		AnimPlayer.play("Pull up")
	if anim_name == "Dip":  # Replace with your specific animation name
		Global.animation_dip_count += 1
		#print("Animation dip has looped ", animation_dip_count, " times") 
		AnimPlayer.play("Dip")
	if anim_name == "Push up":  # Replace with your specific animation name
		Global.animation_pushup_count += 1
		#print("Animation has looped ", animation_pushup_count, " times") 
		AnimPlayer.play("Push up")
	if anim_name == "bench press":  # Replace with your specific animation name
		Global.animation_benchpress_count += 1
		#print("Animation has looped ", animation_benchpress_count, " times") 
		AnimPlayer.play("bench press")
	if anim_name == "Deadlift":  # Replace with your specific animation name
		Global.animation_deadlift_count += 1
		#print("Animation has looped ", animation_deadlift_count, " times") 
		AnimPlayer.play("Deadlift")
	if anim_name == "Run":  # Replace with your specific animation name
		Global.animation_run_seconds += 0.7
		#print("Animation has looped ", animation_run_seconds, " seconds") 
		AnimPlayer.play("Run")
	if anim_name == "Sit":
		Global.animation_sit_seconds += 1
		#print("Animation has looped ", animation_sit_seconds, " seconds") 
		AnimPlayer.play("Sit")
	if anim_name == "Drink":
		Global.animation_drink_count += 1
		#print("Animation has looped ", animation_drink_count, " seconds") 
		drinking = false
		currPickedObject.visible = true
		AnimPlayer.play("Idle")
	if anim_name == "Dumbell press":
		Global.animation_dumbellpress_count += 1
		#print("Animation has looped ", animation_dumbellpress_count, " times") 
		currPickedObject.visible = true
		AnimPlayer.play("Dumbell press")
	if anim_name == "Bicep curl":
		Global.animation_bicepcurl_count += 1
		#print("Animation has looped ", animation_bicepcurl_count, " times") 
		currPickedObject.visible = true
		AnimPlayer.play("Bicep curl")
	if anim_name != "Idle":
		Global.CheckTaskDone()

func _on_Timer_timeout():
	print("Timer finished!")
	AnimPlayer.play("Idle")
	doingExercise = false
	if BigWeightParentObject != null:
		BigWeightParentObject.visible = true
	if currPickedObject != null:
		currPickedObject.visible = true
