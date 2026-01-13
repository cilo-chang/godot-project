@tool
class_name QuestActionCardData
extends ActionCardData

# 任务行动卡牌：涉及主线/支线/好感/约会剧情推进

enum QuestType {
	MAIN, # 主线任务
	SIDE, # 支线任务
	DATE, # 约会剧情
	AFFECTION # 好感剧情
}

@export var quest_type: QuestType = QuestType.MAIN
@export var quest_id: String = "" # 关联的任务ID
@export var quest_stage_id: String = "" # 关联的任务阶段ID
@export var required_location_id: String = "" # 任务触发地点ID

func _init():
	action_type = ActionType.QUEST
