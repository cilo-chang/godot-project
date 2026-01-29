@tool
class_name CollectiblesData
extends ItemData

# --- 1. 收藏品核心参数 ---
@export_group("Collection Config")

# 收藏品所属的套装ID (用于在怀表界面进行场景切换和进度统计)
@export var set_id: String = "Common"

# 是否已经解锁 (逻辑上存放在背包，但GUI显示其收集状态)
@export var is_unlocked: bool = false

# --- 2. 特殊效果参数 ---
@export_group("Special Effects")

# 收藏品提供的特殊效果描述
@export_multiline var passive_effect_text: String = ""

# 对应的被动效果ID (关联到战斗或生活系统的 Buff 管理器)
@export var effect_id: String = ""

# --- 3. 逻辑覆盖 ---
func _init():
	# 收藏品通常是唯一的，且不可售卖
	self.is_unique = true
	self.salable = false
	self.price = 0

# 收藏品的逻辑：拥有即生效
func apply_passive_effect():
	if is_unlocked and effect_id != "":
		# 这里调用全局效果管理器，施加对应的被动增益
		# EffectManager.apply_passive(effect_id)
		pass
