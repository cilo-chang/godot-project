class_name CombatCardData extends CardData

enum BattleType { MELEE, RANGED, MAGIC, BUFF, SPECIAL }

@export_group("Combat Stats") # Godot 4 新特性，让检查器更整洁
@export var battle_type: BattleType = BattleType.MELEE
@export var damage_value: int = 10
@export var cost_action: int = 1
@export var cost_mana: int = 0
@export var distance_min: int = 1
@export var distance_max: int = 5
@export var block_level_bonus: int = 0
