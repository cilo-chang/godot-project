@tool
class_name EntertainmentActionCardData
extends ActionCardData

# 娱乐行动卡牌：主要涉及精力恢复
# 根据GDD，娱乐卡牌是唯一会恢复精力的行动卡卡牌

@export var energy_recovery: int = 20 # 精力恢复量
@export var mood_boost: int = 0 # 心情提升（预留）

func _init():
	action_type = ActionType.ENTERTAINMENT
