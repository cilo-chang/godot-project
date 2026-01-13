# res://data/cards/action/ActionCardData.gd
@tool
class_name ActionCardData
extends CardData

enum ActionType {ENTERTAINMENT, SOCIAL, STUDY, EXPLORE, QUEST}


@export var action_type: ActionType = ActionType.ENTERTAINMENT
@export var energy_cost: int = 1 # 精力消耗
@export var duration_periods: int = 1 # 占用时段
@export var efficiency_bonus: float = 1.5
@export_multiline var effect_description: String = "" # 效果描述

# Architecture Advice (架构建议):
# 根据GDD（游戏总策划.md）的描述，行动卡牌有五种类型（娱乐、社交、钻研、探索、任务）。
# 强烈建议为每种类型建立单独的子类，原因如下：
# 1. 数据结构差异：
#    - 娱乐卡牌 (Entertainment): 主要涉及精力恢复。
#    - 钻研卡牌 (Study): 涉及技能熟练度、战斗数值增长进度、书籍阅读进度等。
#    - 社交卡牌 (Social): 涉及社交数值（魅力/口才）增量、好感度等。
#    - 探索卡牌 (Explore): 涉及地点选择逻辑（白天/晚上可去数量不同）。
#    - 任务卡牌 (Quest): 涉及任务状态流转、剧情触发等复杂逻辑。
# 2. 行为逻辑差异：
#    - 它们的 `execute()` 或 `resolve()` 方法会有完全不同的实现。
#    - 使用子类可以避免在基类中写大量的 `match action_type` 判断，符合面向对象设计的“单一职责原则”和“开闭原则”。
