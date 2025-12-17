# res://data/items/GiftItemData.gd
@tool
class_name GiftItemData
extends ItemData  # 继承自你已经建立的 ItemData 基类

# --- 礼物专属属性 ---
@export var gift_tags: Array[String] = []
var base_affection_value: int = 10
