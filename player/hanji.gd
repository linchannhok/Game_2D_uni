extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const ATTACK_DURATION = 0.3  # Тривалість анімації атаки
const ULTIMATE_DURATION = 0.5  # Тривалість ультимативної анімації

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim = $AnimatedSprite2D  # Reference to the AnimatedSprite2D node

# Змінні для зберігання часу атаки та ультимативної атаки
var attack_timer = 0.0
var ultimate_timer = 0.0
var is_attacking = false  # Змінна для перевірки, чи виконується атака
var is_ultimating = false  # Змінна для перевірки, чи виконується ультимативна атака

func _physics_process(delta):
	# Додати гравітацію.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Обробка стрибка.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Анімація атаки може бути запущена з будь-якого стану
	if Input.is_action_just_pressed("ui_attack") and not is_attacking and not is_ultimating:
		print("Attack button pressed!")  # Додати для діагностики
		anim.play("attack")
		is_attacking = true  # Встановлюємо, що атака активна
		attack_timer = 0.0  # Скидаємо таймер

	# Обробка таймера атаки
	if is_attacking:
		attack_timer += delta  # Збільшуємо таймер
		if attack_timer >= ATTACK_DURATION:
			is_attacking = false  # Завершення атаки
			if is_on_floor():  # Повертаємося до idle, якщо на землі
				anim.play("idle")

	# Обробка ультимативної атаки
	if Input.is_action_just_pressed("ui_ultimate") and not is_attacking and not is_ultimating:
		print("Ultimate button pressed!")  # Додати для діагностики
		anim.play("ultimate")
		is_ultimating = true  # Встановлюємо, що ультимативна атака активна
		ultimate_timer = 0.0  # Скидаємо таймер

	# Обробка таймера ультимативної атаки
	if is_ultimating:
		ultimate_timer += delta  # Збільшуємо таймер
		if ultimate_timer >= ULTIMATE_DURATION:
			is_ultimating = false  # Завершення ультимативної атаки
			if is_on_floor():  # Повертаємося до idle, якщо на землі
				anim.play("idle")

	# Обробка напрямку руху
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if not is_attacking and not is_ultimating:  # Не відтворювати інші анімації під час атаки або ультимативної атаки
			if is_on_floor():
				anim.play("run")  # Відтворюємо анімацію бігу, коли на землі
				anim.flip_h = direction == -1  # Перевертаємо спрайт для руху вліво
			else:
				# Якщо у повітрі, відтворюємо idle, якщо не атакуємо або не ультиматуємо
				if not is_attacking and not is_ultimating:
					anim.play("idle")  # Відтворюємо анімацію простою, якщо у повітрі
				anim.play("jump")  # Відтворюємо анімацію стрибка, коли в повітрі
				# Додати поворот персонажа під час стрибка
				anim.flip_h = direction == -1  # Перевертаємо спрайт для руху вліво
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() and not is_attacking and not is_ultimating:
			anim.play("idle")  # Відтворюємо анімацію простою, якщо немає введення

	move_and_slide()  # Рухаємо персонажа
