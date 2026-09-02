class_name WeaponController
extends Node2D

signal primary_pressed(definition: Resource)
signal primary_released(definition: Resource, power: float, direction: Vector2)
signal charge_started(definition: Resource)
signal charge_changed(definition: Resource, ratio: float)
signal charge_cancelled(definition: Resource)
signal equipped_changed(definition: Resource)
signal input_enabled_changed(enabled: bool)
signal holstered_changed(holstered: bool, definition: Resource)

## Liste des WeaponDefinition disponibles pour ce personnage. L'ordre correspond aux secteurs de la roue.
@export var inventory: Array[Resource] = []
## Arme équipée au démarrage, indexée à partir de zéro. 0 désigne la première ressource de l'inventaire.
@export var equipped_index := 0
## Action InputMap utilisée pour tirer ou activer l'équipement courant. La touche se règle dans le Plan des entrées.
@export var primary_action := &"weapon_primary"
## Action InputMap qui range l'équipement visible ou ressort le dernier équipement mémorisé. La touche se règle dans le Plan des entrées.
@export var holster_action := &"weapon_holster"

var equipped_weapon: Resource
var primary_was_down := false
var cooldown_left := 0.0
var aim_direction := Vector2.RIGHT
var weapon_sprite: Sprite2D
var weapon_audio: AudioStreamPlayer2D
var input_enabled := true
var is_charging := false
var charge_elapsed := 0.0
var charge_ratio := 0.0
var charge_direction := Vector2.RIGHT
var is_holstered := false


func _ready() -> void:
	weapon_sprite = Sprite2D.new()
	weapon_sprite.name = "WeaponSprite"
	weapon_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(weapon_sprite)
	weapon_audio = AudioStreamPlayer2D.new()
	weapon_audio.name = "WeaponAudio"
	weapon_audio.bus = &"Weapons"
	weapon_audio.max_distance = 1200.0
	add_child(weapon_audio)
	equip(equipped_index)


func _process(delta: float) -> void:
	cooldown_left = maxf(0.0, cooldown_left - delta)
	_poll_holster_input()
	_update_aim()
	_update_charge(delta)
	_poll_primary_input()


func _update_aim() -> void:
	if is_charging:
		return
	var mouse_offset := get_global_mouse_position() - global_position
	if mouse_offset.length_squared() > 4.0:
		aim_direction = mouse_offset.normalized()
	rotation = aim_direction.angle()
	if weapon_sprite:
		weapon_sprite.flip_v = aim_direction.x < 0.0


func _poll_primary_input() -> void:
	if not input_enabled or is_holstered:
		primary_was_down = Input.is_action_pressed(primary_action)
		return
	var primary_down := Input.is_action_pressed(primary_action)
	if primary_down and not primary_was_down and equipped_weapon and cooldown_left <= 0.0:
		if bool(equipped_weapon.get("charge_enabled")):
			_begin_charge()
		else:
			primary_pressed.emit(equipped_weapon)
			_play_fire_audio(equipped_weapon)
			cooldown_left = float(equipped_weapon.get("cooldown"))
	elif not primary_down and primary_was_down and equipped_weapon:
		if is_charging:
			_release_charge()
	primary_was_down = primary_down


func _begin_charge() -> void:
	is_charging = true
	charge_elapsed = 0.0
	charge_ratio = 0.0
	charge_direction = aim_direction
	_set_visual_charge(0.0)
	charge_started.emit(equipped_weapon)


func _update_charge(delta: float) -> void:
	if not is_charging or equipped_weapon == null:
		return
	var duration := maxf(float(equipped_weapon.get("charge_duration")), 0.01)
	charge_elapsed = minf(charge_elapsed + delta, duration)
	var next_ratio := charge_elapsed / duration
	if not is_equal_approx(next_ratio, charge_ratio):
		charge_ratio = next_ratio
		_set_visual_charge(charge_ratio)
		charge_changed.emit(equipped_weapon, charge_ratio)


func _release_charge() -> void:
	var definition := equipped_weapon
	var minimum := clampf(float(definition.get("minimum_power")), 0.0, 1.0)
	var power := lerpf(minimum, 1.0, charge_ratio)
	is_charging = false
	_set_visual_charge(0.0)
	primary_released.emit(definition, power, charge_direction)
	_play_fire_audio(definition)
	cooldown_left = float(definition.get("cooldown"))
	charge_elapsed = 0.0
	charge_ratio = 0.0


func cancel_charge() -> void:
	if not is_charging:
		return
	var definition := equipped_weapon
	is_charging = false
	charge_elapsed = 0.0
	charge_ratio = 0.0
	_set_visual_charge(0.0)
	charge_cancelled.emit(definition)


func equip(index: int) -> bool:
	cancel_charge()
	if inventory.is_empty() or index < 0 or index >= inventory.size():
		equipped_weapon = null
		if weapon_sprite:
			weapon_sprite.texture = null
		return false
	equipped_index = index
	equipped_weapon = inventory[index]
	is_holstered = false
	if weapon_sprite:
		weapon_sprite.visible = true
		weapon_sprite.texture = equipped_weapon.get("texture")
		weapon_sprite.position = equipped_weapon.get("visual_offset")
		weapon_sprite.scale = equipped_weapon.get("visual_scale")
		weapon_sprite.material = _make_charge_material(equipped_weapon) if bool(equipped_weapon.get("charge_enabled")) else null
	equipped_changed.emit(equipped_weapon)
	holstered_changed.emit(false, equipped_weapon)
	return true


func _poll_holster_input() -> void:
	if input_enabled and Input.is_action_just_pressed(holster_action):
		toggle_holster()


func toggle_holster() -> bool:
	if equipped_weapon == null:
		return false
	if is_holstered:
		unholster()
	else:
		holster()
	return true


func holster() -> void:
	if is_holstered or equipped_weapon == null:
		return
	cancel_charge()
	is_holstered = true
	primary_was_down = Input.is_action_pressed(primary_action)
	if weapon_sprite:
		weapon_sprite.visible = false
	holstered_changed.emit(true, equipped_weapon)


func unholster() -> void:
	if not is_holstered or equipped_weapon == null:
		return
	is_holstered = false
	primary_was_down = Input.is_action_pressed(primary_action)
	if weapon_sprite:
		weapon_sprite.visible = true
	holstered_changed.emit(false, equipped_weapon)


func equip_next() -> bool:
	if inventory.is_empty():
		return false
	return equip((equipped_index + 1) % inventory.size())


func set_input_enabled(enabled: bool) -> void:
	if input_enabled == enabled:
		return
	input_enabled = enabled
	if not enabled:
		cancel_charge()
	primary_was_down = Input.is_action_pressed(primary_action)
	input_enabled_changed.emit(input_enabled)


func get_aim_direction() -> Vector2:
	return aim_direction


func get_muzzle_global_position() -> Vector2:
	if equipped_weapon == null:
		return global_position
	return to_global(equipped_weapon.get("muzzle_offset"))


func _make_charge_material(definition: Resource) -> Material:
	var source := definition.get("charge_material") as Material
	if source == null:
		return null
	var material := source.duplicate() as Material
	if material is ShaderMaterial:
		(material as ShaderMaterial).set_shader_parameter("charge_ratio", 0.0)
	return material


func _set_visual_charge(ratio: float) -> void:
	if weapon_sprite == null or not (weapon_sprite.material is ShaderMaterial):
		return
	(weapon_sprite.material as ShaderMaterial).set_shader_parameter("charge_ratio", clampf(ratio, 0.0, 1.0))


func _play_fire_audio(definition: Resource) -> void:
	if weapon_audio == null:
		return
	var stream := definition.get("fire_audio") as AudioStream
	if stream == null:
		return
	weapon_audio.stream = stream
	weapon_audio.volume_db = float(definition.get("fire_volume_db"))
	weapon_audio.pitch_scale = float(definition.get("fire_pitch_scale"))
	weapon_audio.play()
