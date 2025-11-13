extends Area2D

@export var top_speed = 400 #m/s
@export var max_thrust = 5000000 #N
@export var dry_mass = 100000 #kg
@export var fuel_capacity = 200000 #kg, originally 360000
@export var fuel_rate = 5000 #kg/s
@export var drag_coefficient = 0.01 #Cd
#make this variable in the future so you can go to space and not have air
@export var air_density = 1.225 # kg/m^3
@export var rotation_rate = PI # rad/s
@export var pixels_per_meter = 100 # number of pixels equal to one meter

signal engine_started
signal engine_stopped 
signal fuel_depleted
signal fuel_updated
signal hit
signal rocket_crashed

var screen_size
var acceleration
var thrust_direction = Vector2.ZERO
var engine_burning = false
var fuel_mass
var rocket_mass
var velocity = Vector2.ZERO

func _ready():
	screen_size = get_viewport_rect().size
	# Start with full tank, maybe change later
	fuel_mass = fuel_capacity
	
func _process(delta):
	# Reset acceleration
	var acceleration = Vector2.ZERO
	if Input.is_action_pressed("rotate_cw"):
		rotate(rotation_rate * delta)
	elif Input.is_action_pressed("rotate_ccw"):
		rotate(-rotation_rate * delta)
	# Apply engine thrust and decrement propellant
	if Input.is_action_pressed("engine"):
		if burn_fuel(fuel_rate * delta):
			thrust_direction = Vector2.from_angle(rotation - PI/2 )
			acceleration =  max_thrust / rocket_mass * pixels_per_meter * thrust_direction
			if not engine_burning:
				engine_started.emit()
				engine_burning = true
	else:
		if engine_burning:
			engine_stopped.emit()
			engine_burning = false
			
	# Update rocket mass
	rocket_mass = dry_mass + fuel_mass
	
	# Apply gravity. using gravity direction so that can be changed if wanted
	acceleration += gravity * gravity_direction
	
	# Apply acceleration to rocket velocity
	velocity += acceleration * delta

	print("acceleration x: " + str(acceleration.x) + "y: " + str(acceleration.y))
	
	print("velocity x: " + str(velocity.x) + "y: " + str(velocity.y))
	
	# Apply velocity to position
	translate(velocity * delta)
	
	print("position x: " + str(position.x) + "y: " + str(position.y))

# Returns false if the operation results in propellant depletion, true otherwise
func burn_fuel(amount):
	fuel_mass -= amount
	print("Fuel: " + str(fuel_mass))
	if fuel_mass <= 0:
		fuel_depleted.emit()
		fuel_mass = 0
		fuel_updated.emit(0)
		return false
	else:
		fuel_updated.emit(100*fuel_mass/fuel_capacity)
		return true

func add_propellant(amount):
	fuel_mass += amount
	if fuel_mass > fuel_capacity:
		fuel_mass = fuel_capacity
	fuel_updated.emit(100*fuel_mass/fuel_capacity)
