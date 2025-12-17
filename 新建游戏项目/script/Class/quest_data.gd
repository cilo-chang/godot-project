@tool
class_name QuestData
extends GameData # 假设 GameData 继承 Resource 且包含 id 字段

# --- 核心类型 ---
enum QuestType { MAIN, BRANCH, AFFECTION, DATE }

@export var type: QuestType = QuestType.BRANCH

# --- 时间与触发约束 ---
@export var act: int = 1 # 所属幕（仅主线用）
@export var start_day: int = 1 # 任务开始天（首次可获得卡牌的天数）
@export var deadline_day: int = 365 # 任务截止天（未完成可能触发失败结局）

# --- 触发条件 (由 QuestManager 检查) ---
@export var required_affection: Dictionary = {}# 好感需求 {char_id: min_level}
@export var required_player_attr: Dictionary = {} # 属性需求: {"mind": 20}

# --- 任务内容与流程 ---
@export var intro_event: DialogicTimeline#导入剧情（任务激活时播放，或首次执行任务卡时播放）

# --- 关键序列化字段 (新增强化点) ---
@export var next_quest_card_id: String = "" # 任务成功后，奖励的下一张任务行动卡牌ID
@export var full_success_rewards: Array[String] = [] # 额外的奖励ID (如物品/心相点)

# --- 约会任务专属约束 (DATE) ---
@export var required_character_id: String = ""
@export var required_location_id: String = ""
@export var required_time_slot: String = "evening"
