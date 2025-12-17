@tool
class_name CardData
extends GameData
# 只保留所有卡牌共有的属性
enum CardRarity { COMMON, UNCOMMON, EPIC, LEGENDARY }
@export var unlocks: Array[String] = []  # 解锁内容
@export var unique: bool = false         # 是否唯一
@export var rarity: CardRarity = CardRarity.COMMON
