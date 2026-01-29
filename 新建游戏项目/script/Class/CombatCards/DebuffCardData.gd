@tool
class_name DebuffCardData
extends CombatCardData

@export var douqi_cost: int = 0
@export var mana_cost: int = 0
@export var min_range: int = 1
@export var max_range: int = 3
@export var attack_debuff: int = 0 # 攻击力削弱
@export var damage_debuff: int = 0 # 易伤
@export var dizziness_debuff_rate: int = 0 # 眩晕等级
@export var duration_periods: int = 1 # 持续回合数

func _init():
	is_attack = false
	battle_type = BattleType.DEBUFF
