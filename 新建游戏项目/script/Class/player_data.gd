# res://data/base/PlayerData.gd
@tool
class_name PlayerData
extends GameData

@export var strength: int = 5      # 力量
@export var agility: int = 5       # 灵巧
@export var magic: int = 5         # 魔力
@export var stamina: int = 5       # 体力
@export var energy: int = 100      # 精力（当日上限为200）
@export var charm: int = 5         # 魅力
@export var eloquence: int = 5     # 口才
@export var influence: int = 5     # 社交影响力

# 计算二级属性（2.8公式）
func get_strength_bonus(strength) -> float:
	return strength  # 力量加成

func get_agility_bonus() -> float:
	return agility   #灵巧加成

func get_magic_bonus() -> float:
	return magic     #魔力加成
