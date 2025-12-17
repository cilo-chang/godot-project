# res://data/items/ItemData.gd
@tool
class_name ItemData
extends CardData

enum ItemType { GIFT, CONSUMABLE, COLLECTIBLE,BOOK,WEAPON,POTION,QUEST_ITEM}
@export var type: ItemType = ItemType.GIFT
@export var price: int = 100  # 金钱价格
@export var stackable: bool = true  # 可叠性
