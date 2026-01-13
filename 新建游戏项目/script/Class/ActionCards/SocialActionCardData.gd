@tool
class_name SocialActionCardData
extends ActionCardData

# 社交行动卡牌：涉及社交数值提升、好感度、社交场景

@export var charm_gain: int = 0 # 魅力提升
@export var eloquence_gain: int = 0 # 口才提升
@export var influence_gain: int = 0 # 社交影响力提升
@export var social_scene_tier: int = 1 # 社交场景阶级 (1-5, 对应不同品级场景)

func _init():
	action_type = ActionType.SOCIAL
