extends Node
# 全局时间管理系统（优化版）

# 时段枚举
enum Period {
	MORNING, # 上午
	AFTERNOON, # 下午
	EVENING, # 晚上
	MIDNIGHT # 午夜
}

# 季节枚举
enum Season {
	SPRING, # 春季（3-5月）
	SUMMER, # 夏季（6-8月）
	AUTUMN, # 秋季（9-11月）
	WINTER # 冬季（12-2月）
}

# 核心配置（集中管理，便于修改）
const START_DAY_OF_YEAR = 244 # 9月1日对应一年中的第244天
const DAYS_IN_MONTH = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31] # 平年每月天数

# 状态变量
var current_day: int = 1 # 从第1天（9月1日）开始
var current_period: int = Period.MORNING
var current_act: int = 1
var act_duration_days: Array = [21, 70, 90, 92, 62, 30] # 每幕天数（总计365天）
var act_date_ranges: Array # 预存每幕的[起始天, 结束天]，优化查询

# 信号定义
signal time_advanced(new_period)
signal day_advanced(new_day)
signal act_changed(new_act)

func _ready():
	# 预计算每幕的起始/结束天（仅初始化一次）
	precompute_act_ranges()
	print("时间管理系统初始化完成")
	print("当前状态：%s" % get_formatted_date())

# 预计算每幕的起始和结束天（优化核心）
func precompute_act_ranges():
	act_date_ranges = []
	var accumulated = 0
	for days in act_duration_days:
		act_date_ranges.append([accumulated + 1, accumulated + days])
		accumulated += days

# 公共工具：计算当前日期对应的全年天数（抽取重复逻辑）
func _get_total_day_of_year() -> int:
	var total = current_day + START_DAY_OF_YEAR - 1 # 起始天已算第1天，无需+243
	return total if total <= 365 else total - 365 # 支持跨年容错

# 获取当前月份（1-12）
func get_month() -> int:
	var total_day = _get_total_day_of_year()
	var accumulated = 0
	for month_idx in range(12):
		accumulated += DAYS_IN_MONTH[month_idx]
		if total_day <= accumulated:
			return month_idx + 1
	return 12

# 获取当前日（1-31）
func get_day_of_month() -> int:
	var total_day = _get_total_day_of_year()
	var accumulated = 0
	for month_idx in range(12):
		var month_days = DAYS_IN_MONTH[month_idx]
		if total_day <= accumulated + month_days:
			return total_day - accumulated
		accumulated += month_days
	return 31

# （其余函数逻辑不变，仅优化调用）
func get_season() -> int:
	var current_month = get_month()
	if current_month >= 3 and current_month <= 5:
		return Season.SPRING
	elif current_month >= 6 and current_month <= 8:
		return Season.SUMMER
	elif current_month >= 9 and current_month <= 11:
		return Season.AUTUMN
	else:
		return Season.WINTER

func get_season_name(season: int = -1) -> String:
	if season == -1:
		season = get_season()
	match season:
		Season.SPRING: return "春季"
		Season.SUMMER: return "夏季"
		Season.AUTUMN: return "秋季"
		Season.WINTER: return "冬季"
	return "未知"

func get_period_name(period: int = -1) -> String:
	if period == -1:
		period = current_period
	match period:
		Period.MORNING: return "上午"
		Period.AFTERNOON: return "下午"
		Period.EVENING: return "晚上"
		Period.MIDNIGHT: return "午夜"
	return "未知"

func advance_time():
	current_period += 1
	if current_period > Period.MIDNIGHT:
		advance_day()
		current_period = Period.MORNING
	emit_signal("time_advanced", current_period)
	print("时间推进到：%s" % get_period_name(current_period))

func advance_day():
	current_day += 1
	# 容错：超出全年天数时重置（可选逻辑，根据需求调整）
	if current_day > 365:
		current_day = 1
		current_act = 1
		precompute_act_ranges() # 重置幕区间
		print("全年周期结束，重置至初始状态")
	
	# 检查幕切换（复用预计算的区间，无需循环累加）
	var current_act_range = act_date_ranges[current_act - 1]
	if current_day > current_act_range[1] and current_act < 6:
		current_act += 1
		emit_signal("act_changed", current_act)
		print("进入第%d幕" % current_act)
	
	emit_signal("day_advanced", current_day)
	print("日期推进到：%s" % get_formatted_date())

func get_remaining_days_in_act() -> int:
	var current_act_range = act_date_ranges[current_act - 1]
	return current_act_range[1] - current_day + 1

func get_formatted_date() -> String:
	return "%d月%d日 %s 第%d幕" % [get_month(), get_day_of_month(), get_period_name(), current_act]

# --- 任务系统支持 ---
func is_time_slot_available(slot_name: String) -> bool:
	# 兼容处理：如果传入的是空或 "any"，则允许
	if slot_name == "" or slot_name.to_lower() == "any":
		return true
		
	var target_period = -1
	match slot_name.to_lower():
		"morning", "上午": target_period = Period.MORNING
		"afternoon", "下午": target_period = Period.AFTERNOON
		"evening", "晚上": target_period = Period.EVENING
		"midnight", "午夜": target_period = Period.MIDNIGHT
	
	return current_period == target_period
