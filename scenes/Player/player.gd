extends CharacterBody3D

@onready var gunRay = $Head/Camera3d/RayCast3d as RayCast3D
@onready var Cam = $Head/Camera3d as Camera3D
@onready var Hand = $Head/Camera3d/Hand
@export var _bullet_scene : PackedScene
var mouseSensibility = 1200
var mouse_relative_x = 0
var mouse_relative_y = 0
const SPEED = 2.0
const JUMP_VELOCITY = 4.5

var pickedUp = false
var currPickedObject = null
var pullPower = 20
var InteractionTextGlobal = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#Captures mouse and stops rgun from hitting yourself
	gunRay.add_exception(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#InteractionTextGlobal = find_node_by_script("InteractionText") as RichTextLabel

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

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
	if pickedUp:
		var a = currPickedObject.global_transform.origin
		var b = Hand.global_transform.origin
		currPickedObject.set_linear_velocity((b-a) * pullPower)

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
		if gunRay.get_collider() is PickableObject:
			print("Pickup 2!")
			currPickedObject = gunRay.get_collider() as RigidBody3D
			#currPickedObject.get_parent().remove_child(currPickedObject)
			#currPickedObject.freeze = true
			#currPickedObject.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
			#$Head/Camera3d.add_child(currPickedObject)
			
			#currPickedObject.transform.origin = Vector3($Head/HoldObjectPosition.transform.origin.x, $Head/HoldObjectPosition.transform.origin.y, $Head/HoldObjectPosition.transform.origin.z)
			pickedUp = true
	else:
		pickedUp = false
		pass
		
		
		
func find_node_by_script(script_class_name, root = null):
	if not root:
		root = get_tree().get_root()
	for child in root.get_children():
		if child.get_script():
			if child.get_script().class_name == script_class_name:
				return child
		var deeper_search = find_node_by_script(script_class_name, child)
		if deeper_search:
			return deeper_search
	return null
