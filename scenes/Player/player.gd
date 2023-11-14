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
var currPickedObject = null
var currPickedObjectPosition = null
var currPickedObjectRotation = Quaternion()
var pullPower = 20
var InteractionTextGlobal = null
var animation_pullup_count = 0

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

	#InteractionTextGlobal = find_node_by_script("InteractionText") as RichTextLabel

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if pickedUp:
		Global.CurrentInteractionText = "Click to release object"
	elif doingExercise:
		Global.CurrentInteractionText = "Keep pressing [E] to continue doing exercise!"
	else:
		if gunRay.get_collider() is PickableObject:
			Global.CurrentInteractionText = "Click to pick up object"
		elif gunRay.get_collider() is InteractableObject:
			Global.CurrentInteractionText = "Press [E] to interact"
		else:
			Global.CurrentInteractionText = ""
		
	if Input.is_action_just_pressed("interact"):
		interact()
		
	if doingExercise:
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
		pass
	
	if not gunRay.is_colliding():
			return
			
	if gunRay.get_collider() is PullUp:
		print("do pull up now")
		AnimPlayer.play("Pull up")
		my_timer.start()
		doingExercise = true
		
		
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Pull up":  # Replace with your specific animation name
		animation_pullup_count += 1
		print("Animation has looped ", animation_pullup_count, " times") 
		AnimPlayer.play("Pull up")

func _on_Timer_timeout():
	print("Timer finished!")
	AnimPlayer.play("Idle")
	doingExercise = false
