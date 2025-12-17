# res://data/cards/action/ActionCardData.gd
@tool
class_name ActionCardData
extends CardData

enum ActionType { ENTERTAINMENT, SOCIAL, STUDY, EXPLORE, QUEST }


@export var action_type: ActionType = ActionType.ENTERTAINMENT
@export var energy_cost: int = 1  # 精力消耗
@export var duration_periods: int = 1  # 占用时段
@export var efficiency_bonus: float = 1.5
