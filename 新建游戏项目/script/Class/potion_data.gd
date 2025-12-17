# res://data/items/PotionItemData.gd (魔药/战斗类)
@tool
class_name PotionItemData
extends ItemData

# 魔药通常是可堆叠的
# --- 效果分类：纯粹战斗增益/伤害 ---
enum PotionCategory { 
	INSTANT_HEAL,     # 瞬时治疗/资源恢复
	TEMPORARY_BUFF,   # 临时增益 Buff
	TEMPORARY_DEBUFF, # 临时减益 DeBuff (投掷型魔药)
	INSTANT_DAMAGE    # 瞬间伤害 (酸液瓶等)
}
@export var category: PotionCategory = PotionCategory.INSTANT_HEAL

# --- 效果定义 ---
enum CombatEffectType { HEAL_HP, RESTORE_ACTION, BOOST_STR, BOOST_DEX, APPLY_STATUS }
@export var effect_type: CombatEffectType = CombatEffectType.HEAL_HP

@export var effect_value: float = 0.0     # 效果数值/治疗量/伤害量
@export var duration_turns: int = 1       # 持续回合数 (对于 Buff/DeBuff 必须大于0)
@export var status_id: String = ""        # 关联的状态效果ID (如果 effect_type 是 APPLY_STATUS)

# --- 核心函数：使用逻辑 ---
func use(target_id: String):
	# 仅用于通知 GameManager，逻辑执行应该转发给 BattleManager
	gamemanager.signal_item_usage(id, target_id) 
	print("正在使用战斗魔药 [%s]..." % name)
	# 逻辑执行由监听 GameManager.item_used 信号的 BattleManager 负责
