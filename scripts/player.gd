extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_sprite: Sprite2D = $HitSprite
@onready var health_component: HealthComponent = $HealthComponent

@export var speed = 300.0
@export var jump_velocity = -300.0

var is_die := false
var damage := randf_range(15, 25)
var direction: float
var is_jumping := false
var is_hitting := false
var switch_sprite := "anim_sprite":
	set(value):
		if value == "hit_sprite":
			sprite.hide(); hit_sprite.show()
		else: 
			sprite.show(); hit_sprite.hide()
var current_flip_h := false:
	set(value):
		sprite.flip_h = value
		hit_sprite.flip_h = value
		
		%HitCollision.position.x = -10 if value else 10


func _ready() -> void:
	%HitArea.area_entered.connect(enemy_entered_on_hit_area)
	health_component.damaged.connect(damaged)
	Global.Player = self
	%HPBar.max_value = health_component.max_health


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		if not is_jumping and not is_die:
			sprite.play("blinking")
		velocity += get_gravity() * delta
	else: is_jumping = false

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_hitting:
		is_jumping = true
		velocity.y = jump_velocity

	direction = Input.get_axis("move_left", "move_right")
	if direction and not is_hitting and not is_die:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	update_animation()
	move_and_slide()
	
	%HPBar.value = health_component.health
	#print(direction)

func discarding():
	var discarding_tween = get_tree().create_tween()
	discarding_tween.tween_property(self, "global_position", Vector2(global_position.x - 30, global_position.y - 20), 0.1)


func update_animation():
	if velocity.x != 0.0: 
		current_flip_h = velocity.x < 0.0
	if is_die:
		return
	if is_jumping: 
		sprite.play("jumping")
		return
	
	if direction == 0.0 and not is_hitting: 
		sprite.play("idle")
	elif direction != 0.0 and not is_hitting:
		sprite.play("run")
	
	if Input.is_action_just_pressed("hit"):
		is_hitting = true
		switch_sprite = "hit_sprite"
		animation_player.play("hit")
		await animation_player.animation_finished
		is_hitting = false
		switch_sprite = "anim_sprite"; sprite.play("idle")


func hit(area: DamageAreaComponent):
	area.damage(damage)
	damage = randf_range(15, 25)


func damaged():
	discarding()
	
	var tween = get_tree().create_tween()
	tween.tween_property($AnimatedSprite2D, 'modulate', Color.BLACK, 0.15)
	tween.tween_property($AnimatedSprite2D, 'modulate', Color.WHITE, 0.15)


func death():
	switch_sprite = "anim_sprite"; sprite.play("die")
	is_die = true
	await sprite.animation_finished
	queue_free()
	Global.WindowManager.death_window.open()


func enemy_entered_on_hit_area(area: Area2D):
	if area.get_parent().is_in_group("Enemies"):
		if area is DamageAreaComponent:
			hit(area)
