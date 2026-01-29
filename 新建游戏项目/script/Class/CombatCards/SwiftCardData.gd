@tool
class_name SwiftCardData
extends CombatCardData

@export var damage_value: int = 10
@export var damage_type: DamageType = DamageType.SWIFT_PHYSICAL
@export var douqi_cost: int = 1
@export var min_range: int = 1
@export var max_range: int = 1

func _init():
	is_attack = true
	# Default type, can be changed in editor
	battle_type = BattleType.SWIFT
	damage_type = DamageType.SWIFT_PHYSICAL