@tool
class_name StudyActionCardData
extends ActionCardData

# 钻研行动卡牌：涉及技能熟练度、属性成长、书籍阅读

@export var target_skill_id: String = "" # 目标技能ID (如 "skill_sword_slash")
@export var skill_proficiency_gain: int = 10 # 技能熟练累积值提升
@export var attribute_growth_points: int = 5 # 基础属性(力量/灵巧/魔力)增长进度提升
@export var linked_book_id: String = "" # 关联书籍ID (如果是读书行动)

func _init():
	action_type = ActionType.STUDY
