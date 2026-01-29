class_name CombatCardData extends CardData

enum BattleType {POWER, SWIFT, MAGIC, BUFF, DEBUFF, SPECIAL, PRISM}
enum DamageType {POWER_PHYSICAL, SWIFT_PHYSICAL, MAGIC}

@export_group("Combat Stats") # Godot 4 新特性，让检查器更整洁
@export var battle_type: BattleType = BattleType.POWER
@export var is_attack: bool = true # 是否为攻击
@export var special_tag: String = "" # 特殊标签
