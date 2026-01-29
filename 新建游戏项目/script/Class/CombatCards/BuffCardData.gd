@tool
class_name BuffCardData
extends CombatCardData

@export var douqi_cost: int = 0
@export var mana_cost: int = 0
@export var damage_boost: int = 0
@export var speed_boost: int = 0
@export var shield_generation: int = 0
@export var duration_periods: int = 1
# Buffs are usually self-cast or single target ally, user said "no effective range (affects self)"

func _init():
	is_attack = false
	battle_type = BattleType.BUFF
