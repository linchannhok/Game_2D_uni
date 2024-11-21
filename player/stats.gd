extends CanvasLayer
@onready var health_bar=$HealthBar
@onready var stamina_bar=$Stamina
var stamina_cost
var max_health=100
var stamina=50
var attack_cost=20
var jump_cost=15
var run_cost=1
var ultimate_get=-25
var health:
	set(value):
		health=value
		health_bar.value=health
	
func _ready():
	health=max_health
	health_bar.max_value=health
	health_bar.value=health

func _process(delta):
	stamina_bar.value=stamina
	if stamina<=100:
		stamina +=10*delta
func stamina_consuption ():
	stamina -=stamina_cost
