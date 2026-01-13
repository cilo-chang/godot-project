@tool
class_name ExploreActionCardData
extends ActionCardData

# 探索行动卡牌：涉及地点和时间段选择

@export var is_long_exploration: bool = false # 是否为长时探索 (白天可去3个点，晚上2个)
@export var target_location_ids: Array[String] = [] # 可选的目标地点ID列表 (如果为空则可能打开大地图自由选择)

func _init():
	action_type = ActionType.EXPLORE
