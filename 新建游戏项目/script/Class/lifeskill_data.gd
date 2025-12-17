# res://data/cards/LifeSkillCardData.gd
@tool
class_name LifeSkillCardData
extends CardData

# --- 1. 核心状态 ---
# 运行时状态 (通过 duplicate() 后的实例会独立持有这些值)
var current_xp: int = 0

# --- 2. 成长配置 (配置表) ---
@export_group("Progression Config")

# 升级所需的经验阈值 (0 -> 1, 1 -> 2, 2 -> 3)
# 对应文档: 初心->熟手(50), 熟手->精通(500), 精通->大师(5000) [cite: 417]
@export var xp_thresholds: Array[int] = [50, 500, 5000]

# --- 3. 打工属性 (随等级变化) ---
# 对应文档: 经济效益 & 精力消耗 
# 数组索引对应 Proficiency 枚举 (0, 1, 2, 3)

# 每次打工获得的金钱 (例如: [200, 350, 600, 3000])
@export var money_reward_per_level: Array[int] = [200, 350, 600, 3000]

# 每次打工消耗的精力 (例如: [20, 15, 10, 5])
@export var energy_cost_per_level: Array[int] = [20, 15, 10, 5]

# 每次打工获得的熟练度 (例如: [10, 15, 20, 0]) - 大师级通常不再获得XP
@export var xp_gain_per_level: Array[int] = [10, 15, 20, 0]

# --- 4. 社交属性 (兴趣矩阵) ---
# 对应文档表格 
# 对方对该技能的兴趣程度
enum InterestLevel { INDIFFERENT, INTERESTED, ENTHUSIASTIC } # 兴趣缺缺, 颇有兴趣, 十分热衷

# 社交收益矩阵 (好感度加成)
# 这是一个嵌套数组，或者简单的硬编码逻辑，为了配置灵活，这里使用导出变量
# 默认值参考文档:
# 初心: [1, 3, 5]
# 熟手: [2, 5, 7]
# 精通: [3, 7, 10]
# 大师: [5, 10, 15]
@export var social_bonus_table: Array[Array] = [
	[1, 3, 5], 
	[2, 5, 7], 
	[3, 7, 10], 
	[5, 10, 15]
]
# --- 5. 核心逻辑函数修正 ---

# 修正 1: 获取当前等级的打工收益
func get_work_rewards() -> Dictionary:
	# 直接使用继承的 self.rarity (Rarity.GREEN, BLUE, etc.) 作为数组索引 0, 1, 2, 3
	var level_index = self.rarity # 这里的 rarity 0=初心, 1=熟手, 2=精通, 3=大师
	
	return {
		"money": money_reward_per_level[level_index],
		"energy_cost": energy_cost_per_level[level_index],
		"xp_gain": xp_gain_per_level[level_index]
	}

# 修正 2: 增加经验值并尝试升级
func add_xp(amount: int):
	# FIX: 大师级的判定，使用基类 Rarity 枚举的最大值 (通常是 PRISMATIC=3)
	if self.rarity == CardRarity.LEGENDARY:
		return 

	current_xp += amount
	
	if self.rarity < xp_thresholds.size():
		var threshold = xp_thresholds[self.rarity]
		if current_xp >= threshold:
			_level_up()

func _level_up():
	# 检查是否已达到最高级
	if self.rarity == CardRarity.LEGENDARY: 
		return

	current_xp -= xp_thresholds[self.rarity]
	
	# FIX: 升级操作 - 直接修改基类的 rarity 属性
	self.rarity += 1 
	
	print("生活技能 [%s] 升级了！当前等级: %d" % [id, self.rarity])
	
	# 检查多级连升
	if self.rarity < CardRarity.LEGENDARY and current_xp >= xp_thresholds[self.rarity]:
		_level_up()
		
# 修正 3: 获取社交/约会时的好感加成
func get_social_bonus(npc_interest: InterestLevel) -> int:
	var level_index = self.rarity
	
	if level_index < social_bonus_table.size():
		var level_bonuses = social_bonus_table[level_index]
		if npc_interest < level_bonuses.size():
			return level_bonuses[npc_interest]
	return 0
