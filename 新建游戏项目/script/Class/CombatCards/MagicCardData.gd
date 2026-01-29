@tool
class_name MagicCardData
extends CombatCardData

@export var damage_value: int = 10
@export var damage_type: DamageType = DamageType.MAGIC
@export var mana_cost: int = 1
@export var min_range: int = 1
@export var max_range: int = 3

func _init():
	is_attack = true
	battle_type = BattleType.MAGIC
	damage_type = DamageType.MAGIC