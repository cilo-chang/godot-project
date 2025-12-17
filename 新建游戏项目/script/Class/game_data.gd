# res://data/base/GameData.gd
#游戏数据基类
@tool
class_name GameData
extends Resource

@export var id: String = ""  # 唯一ID，如 "mika_001"
@export var name: String = ""  # 显示名
@export var icon: Texture2D  # 图标/立绘缩略
@export var description: String = ""  # 描述
@export var tags: Array[String] = []  # 标签，如 ["character", "female"]
