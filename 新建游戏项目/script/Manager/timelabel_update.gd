extends Control
# 时间UI显示控制（优化版）

# 依赖Autoload：需在项目设置中将TimeManager设为自动加载，名称为TimeManager

@onready var month_label = $HBoxContainer/MonthLabel
@onready var day_label = $HBoxContainer/DayLabel
@onready var season_label = $HBoxContainer/SeasonLabel
@onready var advance_button = $VBoxContainer/AdvanceButton

func _ready():
	# 绑定信号（仅时间变化时更新UI，优化性能）
	time_manager.day_advanced.connect(_on_time_updated)
	time_manager.time_advanced.connect(_on_time_updated)
	time_manager.act_changed.connect(_on_time_updated)

	
	# 初始化UI
	update_ui()

# 信号回调：时间相关变化时更新UI
func _on_time_updated(_arg):
	update_ui()

# 更新UI（复用TimeManager的格式化逻辑，减少冗余）
func update_ui():
	if not time_manager:
		print("警告：未找到TimeManager单例")
		return
	
	# 拆分显示（也可直接用get_formatted_date()拼接）
	month_label.text = "%d月" % time_manager.get_month()
	day_label.text = "%d日" % time_manager.get_day_of_month()
	season_label.text = time_manager.get_season_name() # 调用函数获取文字
