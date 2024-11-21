extends CharacterBody2D
	
enum{
	IDLE,
	MOVE,
	JUMP,
	ATTACK,
	ULTIMATE,
	DAMAGE,
	DEATH
}

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const ATTACK_DURATION = 0.3
const ULTIMATE_DURATION = 0.5
@onready var anim = $AnimatedSprite2D
@onready var animPlayer = $AnimationPlayer
@onready var stats=$stats
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var coin = 0
var state = MOVE
var player_pos
var damage_basic=50
var attack_cooldown= false
var key=0
func _ready():
	Signals.connect("enemy_attack",Callable(self,"_on_damage_received"))
func _physics_process(delta):
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		ULTIMATE:
			ultimate_state()
		DAMAGE:
			damage_state()
		DEATH:
			death_state()
		
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		if stats.stamina >= stats.jump_cost:  # Перевірка, чи є достатньо витривалості
			stats.stamina_cost = stats.jump_cost  # Встановлення витрат витривалості
			stats.stamina -= stats.jump_cost  # Зменшення витривалості
			velocity.y = JUMP_VELOCITY
	

	
	move_and_slide()
	player_pos=self.position
	Signals.emit_signal("player_position_update", player_pos)
func move_state():
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if velocity.y == 0:
			animPlayer.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if velocity.x == 0 and velocity.y == 0:
		animPlayer.play("idle")
	if direction == -1:
		anim.flip_h = true
		$AttackDirection.rotation_degrees=180
	elif direction == 1:
		anim.flip_h = false
		$AttackDirection.rotation_degrees= 0
	if Input.is_action_just_pressed("ui_attack"):
		stats.stamina_cost= stats.attack_cost
		if  attack_cooldown== false and stats.stamina>stats.stamina_cost:
			state = ATTACK
	if Input.is_action_just_pressed("ui_ultimate"):
		stats.stamina_cost= stats.ultimate_get
		state = ULTIMATE

func attack_state():
	animPlayer.play("attack")
	await animPlayer.animation_finished
	state = MOVE

func ultimate_state():
	animPlayer.play("ultimate")
	await animPlayer.animation_finished
	state = MOVE

func damage_state():
	velocity.x=0
	animPlayer.play("damage")
	await animPlayer.animation_finished
	state = MOVE

func death_state():
	velocity.x=0
	animPlayer.play("die")
	await animPlayer.animation_finished
	queue_free()
	get_tree().change_scene_to_file("res://levels/level_two.tscn")
# Обробка сигналу з пошкодженням
func _on_hit_box_area_entered(area):
	Signals.emit_signal("player_attack",damage_basic)
func _on_damage_received(enemy_damage):
	state=DAMAGE
	stats.health-=enemy_damage
	if stats.health<=0:
		stats.health=0
		state=DEATH
