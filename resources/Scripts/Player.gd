extends KinematicBody2D

class_name Player


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var x_input := 0.0
var y_input := 0.0
export var player_speed := 200.0
export var dash_multiplier := 2.0
var is_dashing := false
var player_velocity := Vector2()

#enum Direction{UP, DOWN, LEFT, RIGHT, UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT}
#var current_direction = Direction.UP

#var player_angle := 0

export var default_health = 10
export(int) onready var player_health = default_health

export var default_shield := 10
export(int) onready var shield_health := default_shield
var shield_pressed := false

var is_shooting := false
var gun_direction := Vector2()
#var special_pressed := false

#var melee_pressed := false

enum States{IDLE, WALK, DASH} #ONLY ALLOWED TO HAVE ONE STATE AT A TIME
var current_state = States.IDLE

onready var current_gun := get_node("Gun")

# Called when the node enters the scene tree for the first time.
func _ready():
	set_gun_rotation()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_input(delta)
	set_movement(delta)
	#set_direction()
	set_gun_rotation()
	set_state(delta)
	do_attack(delta)
	pass

func get_input(delta):
	x_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	y_input = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	#print("X-Input: ", x_input, " Y-Input: ", y_input)
	#player_angle = atan2(y_input, x_input)
	#print(rad2deg(player_angle))
	
	shield_pressed = Input.is_action_pressed("shield")
	
	is_dashing = Input.is_action_pressed("dash_button")
	
	is_shooting = Input.is_action_pressed("shoot")
	
	#special_pressed = Input.is_action_pressed("special_move")
	
	#melee_pressed = Input.is_action_pressed("interact_melee")
	
	pass



func set_movement(delta):
	player_velocity = player_speed * Vector2(x_input,y_input)
	
	if(player_velocity != Vector2.ZERO):
		if(is_dashing):
			current_state = States.DASH
		else:
			current_state = States.WALK
	pass


func set_gun_rotation():
	#current_gun.rotation_degrees = rad2deg(player_angle)
	gun_direction = get_position().direction_to(get_global_mouse_position()) # getting direction to mouse
	current_gun.rotation_degrees = rad2deg(gun_direction.angle())
	pass

func set_state(delta):
	#basic state machine
	match(current_state):
		States.IDLE:
			do_during_idle(delta)
		States.WALK: 
			do_during_walk(delta)
		States.DASH:
			do_during_dash(delta)

func do_during_idle(delta):
	pass

func do_during_walk(delta):
	move_and_collide(player_velocity * delta)

func do_during_dash(delta):
	move_and_collide(dash_multiplier * player_velocity * delta)

func do_attack(delta):
	if(is_shooting):
		current_gun.shoot(gun_direction, 5)
		pass
	pass

func on_hit(damage):
	if(shield_health > 0):
		shield_health -= damage
	elif (player_health > 0):
		player_health -= damage
	else:
		death()
	pass

func death():
	#RESPAWN
	shield_health = default_shield
	player_health = default_health
	global_position = get_parent().get_node("LevelWarps/RespawnPoint").global_position
	pass

func _to_string():
	var player_string := ""
	player_string += "Current State: "
	
	match(current_state):
		States.IDLE:
			player_string += "IDLE"
		States.WALK: 
			player_string += "WALK"
		States.DASH:
			player_string += "DASH"
	
	player_string += "\n"
	
#	player_string += "Player Direction: "
#
#	match(current_direction):
#		Direction.RIGHT:
#			player_string += "RIGHT"
#		Direction.UP_RIGHT:
#			player_string += "UP_RIGHT"
#		Direction.UP:
#			player_string += "UP"
#		Direction.UP_LEFT:
#			player_string += "UP_LEFT"
#		Direction.LEFT:
#			player_string += "LEFT"
#		Direction.DOWN_LEFT:
#			player_string += "DOWN_LEFT"
#		Direction.DOWN:
#			player_string += "DOWN"
#		Direction.DOWN_RIGHT:
#			player_string += "DOWN_RIGHT"
	
	player_string += "\n"
	
	#player_string += "Angle: " + str(rad2deg(player_angle)) + "\n"
	
	player_string += "Health:" + str(player_health) + "\n"
	
	player_string += "Shield: " + str(shield_pressed) + "\nShield Health: " + str(shield_health) + "\n"
	
	player_string += "Shooting: " + str(is_shooting) + "\n"
	
	player_string += "Time till Next Bullet: " + str(current_gun.get_time_till_next_bullet()) + "\n"
	
	#player_string += "Special: " + str(special_pressed) + "\n"
	
	#player_string += "Melee: " + str(melee_pressed) + "\n"
	
	return player_string
