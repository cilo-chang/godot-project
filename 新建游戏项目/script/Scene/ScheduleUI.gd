extends Control

# 信号：开始日程
signal start_schedule

# UI 引用
@onready var panel = $Panel
@onready var close_button = $Panel/CloseButton
@onready var confirm_button = $Panel/ConfirmButton
@onready var time_slot_container = $Panel/TimeSlotContainer
@onready var energy_label = $Panel/InfoPanel/EnergyLabel
@onready var dates_label = $Panel/InfoPanel/DateLabel

# 数据
var current_energy: int = 100

func _ready():
	# 初始化
	hide()
	
	# 设置中心点
	panel.pivot_offset = panel.size / 2
	
	# 按钮连接
	close_button.pressed.connect(_on_close_pressed)
	confirm_button.pressed.connect(_on_confirm_pressed)
	
	# 按钮视觉反馈
	_setup_button_feedback(close_button)
	_setup_button_feedback(confirm_button)
	
	# 初始化时间槽位（示例：根据文档 1.2.7 初始行动槽位只有下午一个）
	_init_time_slots()

# 打开面板
func open():
	show()
	_update_info_display()
	
	# 动画：弹出
	panel.scale = Vector2(0.8, 0.8)
	panel.modulate.a = 0.0
	
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.3)
	tween.parallel().tween_property(panel, "modulate:a", 1.0, 0.2)

# 关闭逻辑
func _on_close_pressed():
	# 动画：关闭
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(panel, "scale", Vector2(0.9, 0.9), 0.15)
	tween.parallel().tween_property(panel, "modulate:a", 0.0, 0.15)
	tween.tween_callback(hide)

# 确认开始日程
func _on_confirm_pressed():
	# 这里可以添加开始日程的逻辑检查
	print("开始执行日程...")
	start_schedule.emit()
	_on_close_pressed()

# 初始化槽位显示
func _init_time_slots():
	# 清空旧槽位
	for child in time_slot_container.get_children():
		child.queue_free()
		
	# 根据 GDD 定义4个时段：上午，下午，晚上，午夜
	var time_periods = ["上午", "下午", "晚上", "午夜"]
	
	for period in time_periods:
		var slot = PanelContainer.new()
		slot.custom_minimum_size = Vector2(0, 50)
		
		var hbox = HBoxContainer.new()
		slot.add_child(hbox)
		
		var label = Label.new()
		label.text = period
		label.custom_minimum_size = Vector2(60, 0)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hbox.add_child(label)
		
		# 占位符：槽位区域
		var content_area = Panel.new()
		content_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		content_area.custom_minimum_size = Vector2(0, 40)
		# 样式设置（可选）
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.1, 0.1, 0.5)
		content_area.add_theme_stylebox_override("panel", style)
		
		hbox.add_child(content_area)
		
		# 根据 GDD，初始只有下午解锁
		if period == "下午":
			var hint = Label.new()
			hint.text = " [可安排行动: 娱乐]"
			hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			content_area.add_child(hint)
			hint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		else:
			content_area.modulate = Color(0.5, 0.5, 0.5, 0.5) # 变暗表示锁定
			
		time_slot_container.add_child(slot)

# 更新信息显示
func _update_info_display():
	# 这里后续应读取 GameManager 或 DocumentData 的数据
	energy_label.text = "精力: %d/100" % current_energy
	# dates_label.text = "9月1日" # 示例

# --- 按钮视觉反馈（复用逻辑） ---
func _setup_button_feedback(btn: Button):
	btn.pivot_offset = btn.size / 2
	
	btn.mouse_entered.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.1)
	)
	
	btn.mouse_exited.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)
	)
	
	btn.button_down.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", Vector2(0.95, 0.95), 0.05)
	)
	
	btn.button_up.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.05)
	)
