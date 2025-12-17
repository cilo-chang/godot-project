# res://data/items/ConsumableItemData.gd (生活/永久类)
@tool
class_name ConsumableItemData
extends ItemData

# 注意：生活类消耗品通常是可堆叠的
# --- 效果分类：纯粹非战斗增益 ---
enum ConsumableCategory {
	GENERAL_RECOVERY, # 恢复精力/心情
	PERMANENT_STAT_BOOST, # 永久基础属性提升
	SOCIAL_BOOST # 临时提高社交属性，用于日程
}
@export var category: ConsumableCategory = ConsumableCategory.GENERAL_RECOVERY

# --- 效果定义 ---
enum EffectTargetStat {ENERGY, MOOD, CHARISMA, ELOQUENCE, STAMINA, BASE_STR, AGILITY, MAGIC, INFLUENCE}
@export var target_stat: EffectTargetStat = EffectTargetStat.ENERGY

@export var effect_value: float = 1.0 # 效果的数值 (如：+10点精力)
@export var duration_days: int = 0 # 持续天数 (仅用于 SOCIAL_BOOST 或其他短期增益)
@export var is_permanent: bool = false # 若为 PERMANENT_STAT_BOOST，则此项为 true

# --- 核心函数：使用逻辑 ---
func use(target_id: String):
	# 仅用于通知 GameManager 进行非战斗内处理
	gamemanager.signal_item_usage(id, target_id)
	print("正在使用生活消耗品 [%s]..." % name)
	# 逻辑执行由监听 GameManager.item_used 信号的 PlayerStatusManager 负责
