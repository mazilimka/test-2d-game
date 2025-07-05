extends CharacterBody2D

enum State { PATROL, ATTACK, CHASE, DEAD }

@onready var health_component: HealthComponent = $HealthComponent
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_sprite: Sprite2D = %HitSprite
@onready var timer: Timer = $Timer
@onready var ray_cast_forward: RayCast2D = $RayCastForward
@onready var ray_cast_down: RayCast2D = $RayCastDown

@export var patrol_speed := 100.0
@export var chase_speed := 180.0

var attack_cooldown_time := 2.0
var current_state: State:
	set(value):
		current_state = value
		if value not in [State.ATTACK]:
			previous_state = value
		change_state(value)

var prev_dir = null
var is_player_in_apply_area := false
var is_player_in_detected_area := false
var previous_state: State
var direction := 0
var damage := randf_range(5, 7)
var current_flip_h := false:
	set(value):
		if current_flip_h != value:
			current_flip_h = value
		animated_sprite.flip_h = value
		hit_sprite.flip_h = value
		
		%HitCollision.position.x = -42.0 if value else 42.0
		%ApplyHitCollision.position.x = -33.0 if value else 33.0


func _ready() -> void:
	$Timer.timeout.connect(_timeout)
	$ApplyHit.body_entered.connect(_on_player_entered_apply_hit)
	$ApplyHit.body_exited.connect(_on_player_exiting_apply_hit)
	$DetectedArea.body_entered.connect(player_enetered_on_detected_area)
	$DetectedArea.body_exited.connect(player_exited_detected_area)
	%HitArea.area_entered.connect(on_area_entered)
	health_component.zero_health.connect(death)
	health_component.damaged.connect(damaged)
	
	current_state = State.PATROL


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if ray_cast_forward.is_colliding() or not ray_cast_down.is_colliding():
		direction = -direction
		ray_cast_forward.target_position.x = -ray_cast_forward.target_position.x
	
	match current_state:
		State.PATROL:
			velocity.x = direction * patrol_speed
		State.CHASE:
			if is_player_in_detected_area and Global.Player:
				var player_direction = sign(Global.Player.global_position.x - global_position.x)
				velocity.x = player_direction * chase_speed
				current_flip_h = player_direction < 0
				#if is_player_in_apply_area:
					#current_state = State.ATTACK
			else:
				current_state = State.PATROL
		State.ATTACK:
			velocity.x = 0
	
	if velocity.x != 0.0: 
		current_flip_h = velocity.x < 0.0
	
	move_and_slide()


func change_state(state: State):
	match state:
		State.PATROL:
			_switch_sprite("anim_sprite")
			direction = prev_dir if prev_dir else 1
			animated_sprite.play("run")
		State.ATTACK:
			prev_dir = direction
			direction = 0
			_switch_sprite("hit_sprite")
			if timer.is_stopped():
				$AnimationPlayer.play("hit")
				timer.start(attack_cooldown_time)
		State.CHASE:
			pass
			#velocity.direction_to(Global.Player.global_position)
		State.DEAD:
			timer.stop()
			_switch_sprite("anim_sprite")
			animated_sprite.play("dead")
			await animated_sprite.animation_finished
			queue_free()


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
	change_state(State.DEAD)


func hit(area: DamageAreaComponent):
	area.damage(damage)
	damage = randf_range(5, 7)


func _on_player_entered_apply_hit(body: CharacterBody2D):
	if body != Global.Player:
		return
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
		current_state = previous_state


func player_enetered_on_detected_area(body: CharacterBody2D):
	if body == Global.Player:
		is_player_in_detected_area = true
		current_state = State.CHASE


func player_exited_detected_area(body: CharacterBody2D):
	if body == Global.Player:
		is_player_in_detected_area = false
		if current_state == State.CHASE:
			current_state = State.PATROL


func on_area_entered(area: Area2D):
	if area.get_parent() == Global.Player:
		if area is DamageAreaComponent:
			hit(area)
