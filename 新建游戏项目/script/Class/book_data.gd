# res://data/items/BookItemData.gd
@tool
class_name BookItemData
extends ItemData

# 书籍通常是唯一的，不可堆叠 (作为重要物品处理)
@export var is_unique: bool = true

# --- 1. 核心状态 (Runtime State) ---
# 需要 duplicate() 来为每个玩家持有的书本实例存储独立的进度
var current_progress: int = 0
var is_read: bool = false # 是否已完全阅读并解锁效果

# --- 2. 配置 (Static Config) ---
@export_group("Reading Properties")

# 满读进度所需点数 (例如：100点)
@export var max_progress: int = 100 

# 每次阅读行动卡消耗的资源类型
enum StudyResource { ENERGY, TIME, MENTAL_FOCUS } 
@export var resource_type: StudyResource = StudyResource.ENERGY

# 每次阅读行动卡消耗的精力
@export var resource_cost: int = 15

# 每次阅读行动卡可获得的进度点数 (例如：5点/次)
@export var progress_per_study: int = 5 

# --- 3. 效果配置 ---
@export_group("Unlock Effects")

# 这本书进阶的卡牌ID (例如："combat_card_01")
@export var advances_card_id: String = "" 

# 进阶后的新卡牌ID (例如："combat_card_01_advanced")
# GameManager 会将 advances_card_id 替换为 advanced_card_id
@export var advanced_card_id: String = ""

# --- 4. 核心逻辑 ---

# 供日程管理系统或阅读行动卡调用，增加阅读进度
# 返回 true 表示阅读完成并解锁了效果
func advance_progress(progress_gain: int) -> bool:
	if is_read:
		return true # 已经读完
	
	current_progress = min(current_progress + progress_gain, max_progress)
	
	var finished = false
	if current_progress >= max_progress and not is_read:
		is_read = true
		unlock_effect()
		finished = true
		
	return finished

# 解锁效果的逻辑
func unlock_effect():
	# 实际的卡牌替换逻辑仍应由 CardManager 或 GameManager 执行，
	# Book 只需要发出信号或调用 GameManager 接口。
	
	if advances_card_id and advanced_card_id:
		# 发射一个全局信号，通知卡牌管理器进行替换操作
		# GameManager.card_advanced.emit(advances_card_id, advanced_card_id)
		print("书籍 [%s] 阅读完毕，解锁卡牌进阶: %s -> %s" % [name, advances_card_id, advanced_card_id])
	
	# 如果这本书是解锁一个新的 LifeSkillCard，也可以在这里处理
	# GameManager.add_life_skill_card(advanced_card_id)
	
func get_progress_percentage() -> float:
	return float(current_progress) / max_progress
