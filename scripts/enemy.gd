extends CharacterBody2D

enum State { PATROL, ATTACK, CHASE }

@onready var health_component: HealthComponent = $HealthComponent
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_sprite: Sprite2D = %HitSprite
@onready var timer: Timer = $Timer

@export var patrol_speed := 100.0
@export var hurt_speed := 180.0

var attack_cooldown_time := 2.0
var current_state: State = State.PATROL:
	set(value):
		current_state = value
		if value not in [State.ATTACK]:
			previous_state = value
		change_state(value)

var is_player_in_apply_area := false
var previous_state: State = State.PATROL
var direction := 0
var damage := randf_range(5, 20)
var current_flip_h := false:
	set(value):
		if current_flip_h != value:
			current_flip_h = value
		animated_sprite.flip_h = value
		hit_sprite.flip_h = value
		
		%HitCollision.position.x = -42.0 if value else 42.0


func _ready() -> void:
	$Timer.timeout.connect(_timeout)
	$ApplyHit.body_entered.connect(_on_player_entered_apply_hit)
	$ApplyHit.body_exited.connect(_on_player_exiting_apply_hit)
	$DetectedArea.body_entered.connect(player_enetered_on_detected_area)
	%HitArea.area_entered.connect(on_area_entered)
	health_component.zero_health.connect(death)
	health_component.damaged.connect(damaged)


func _physics_process(delta: float) -> void:
	velocity.x = direction * patrol_speed
	current_flip_h = velocity.x < 0.0
	update_state(delta)
	move_and_slide()


func update_state(delta: float):
	match current_state:
		State.PATROL:
			direction = 0
		State.ATTACK:
			pass


func change_state(state: State):
	match state:
		State.PATROL:
			_switch_sprite("anim_sprite")
			animated_sprite.play("idle")
		State.ATTACK:
			_switch_sprite("hit_sprite")
			if timer.is_stopped():
				$AnimationPlayer.play("hit")
				timer.start(attack_cooldown_time)


func damaged():
	var tween = get_tree().create_tween()
	tween.tween_property($AnimatedSprite2D, 'modulate', Color.BLACK, 0.15)
	tween.tween_property($AnimatedSprite2D, 'modulate', Color.WHITE, 0.15)
	
	update_health_bar()


func _switch_sprite(what: String):
	match what:
		"anim_sprite": 
			animated_sprite.show()
			hit_sprite.hide()
		"hit_sprite": 
			animated_sprite.hide()
			hit_sprite.show()


func update_health_bar():
	%HPBar.value = health_component.health


func death():
	_switch_sprite("anim_sprite")
	animated_sprite.play("dead")
	await animated_sprite.animation_finished
	queue_free()


func hit(area: DamageAreaComponent):
	area.damage(damage)
	damage = randf_range(5, 20)


func _on_player_entered_apply_hit(body: CharacterBody2D):
	is_player_in_apply_area = true
	current_state = State.ATTACK


func _on_player_exiting_apply_hit(body: CharacterBody2D):
	is_player_in_apply_area = false


func _timeout():
	if is_player_in_apply_area:
		current_state = State.ATTACK
	elif !is_player_in_apply_area and !timer.is_stopped():
		return
	elif !is_player_in_apply_area and timer.is_stopped():
		current_state = State.PATROL


func player_enetered_on_detected_area(body: CharacterBody2D):
	if body == Global.Player:
		pass


func on_area_entered(area: Area2D):
	if area.get_parent() == Global.Player:
		if area is DamageAreaComponent:
			hit(area)
