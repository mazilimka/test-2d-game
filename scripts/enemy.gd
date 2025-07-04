extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_sprite: Sprite2D = $HitSprite

@export var patrol_speed := 100.0
@export var harassment_speed := 180.0

var direction := 1
var damage := randf_range(5, 20)
var switch_sprite := "anim_sprite":
	set(value):
		if value == "hit_sprite":
			animated_sprite.hide(); hit_sprite.show()
		else: 
			animated_sprite.show(); hit_sprite.hide()
var current_flip_h := false:
	set(value):
		if current_flip_h != value:
			current_flip_h = value
		animated_sprite.flip_h = value
		hit_sprite.flip_h = value
		
		if value:
			%HitCollision.position.x = -42.0
		else: 
			%HitCollision.position.x = 42.0
			


func _ready() -> void:
	$ApplyHit.body_entered.connect(_on_player_entered_apply_hit)
	$ApplyHit.body_exited.connect(_on_player_exiting_apply_hit)
	$DetectedArea.body_entered.connect(player_enetered_on_detected_area)
	%HitArea.area_entered.connect(on_area_entered)
	health_component.zero_health.connect(death)
	health_component.damaged.connect(damaged)


func _physics_process(delta: float) -> void:
	#velocity.x = direction * patrol_speed
	current_flip_h = velocity.x < 0.0
	
	move_and_slide()


func damaged():
	var tween = get_tree().create_tween()
	tween.tween_property($AnimatedSprite2D, 'modulate', Color.BLACK, 0.15)
	tween.tween_property($AnimatedSprite2D, 'modulate', Color.WHITE, 0.15)
	
	update_health_bar()


func update_health_bar():
	%HPBar.value = health_component.health


func death():
	pass


func hit(area: DamageAreaComponent):
	area.damage(damage)
	damage = randf_range(5, 20)


func _on_player_entered_apply_hit(body: CharacterBody2D):
	if body != Global.Player:
		return
	switch_sprite = "hit_sprite"
	playing_hit_anim()

# WARNING: Рекурсивная функция
func playing_hit_anim():
	$AnimationPlayer.play("hit")
	await $AnimationPlayer.animation_finished
	await get_tree().create_timer(2.0).timeout
	playing_hit_anim()
	print("hit")


func _on_player_exiting_apply_hit(body: CharacterBody2D):
	switch_sprite = "anim_sprite"
	animated_sprite.play("idle")


func player_enetered_on_detected_area(body: CharacterBody2D):
	if body == Global.Player:
		pass


func on_area_entered(area: Area2D):
	if area.get_parent() == Global.Player:
		if area is DamageAreaComponent:
			hit(area)
