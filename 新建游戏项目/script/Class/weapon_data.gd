@tool
class_name WeaponData
extends ItemData

# 武器尺寸（决定格挡加成 + 力量需求）
enum WeaponSize { SMALL, MEDIUM, LARGE, HUGE }

# 使用 setget 关联 size 的改变
@export var size: WeaponSize:
	set(value):
		size = value
		_update_block_bonus() # 调用私有函数更新加成

# 格挡等级加成（不再需要 @export，因为它是由 size 决定的内部数据）
var block_bonus: int = 0 

# 乘区加成（保持不变）
@export var melee_bonus: float = 0.0
# ... (其他乘区加成保持不变) ...

# 装备需求（保持不变）
@export var required_strength: int = 0
@export var required_level: int = 1
# --- 核心更新函数：确保在任何情况下尺寸改变，格挡都更新 ---
func _update_block_bonus():
	match size:
		WeaponSize.SMALL: 
			block_bonus = -1
		WeaponSize.MEDIUM: 
			block_bonus = 0
		WeaponSize.LARGE: 
			block_bonus = 1
		WeaponSize.HUGE: 
			block_bonus = 2
	
	# 【重要】如果您希望这个值在编辑器中仍然可见：
	if Engine.is_editor_hint():
		pass 
		
# 确保在资源加载时（运行时）block_bonus 被初始化
func _init():
	_update_block_bonus()

# 可选：移除 _get_configuration_warnings()，因为它不再用于计算。
