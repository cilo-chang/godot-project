extends Control

# 定义信号：告诉外部（主场景）玩家做了什么决定
signal confirm_sleep

@onready var panel = $Panel
@onready var yes_btn = $Panel/HBoxContainer/YesButton
@onready var no_btn = $Panel/HBoxContainer/NoButton

func _ready():
	# 初始化时连接按钮信号
	yes_btn.pressed.connect(_on_yes_pressed)
	no_btn.pressed.connect(_on_no_pressed)
	
	# 设置中心点以便缩放动画从中心开始
	# 需要等一帧让 UI 布局完成，或者手动设置一个大概值，这里尝试等待一帧或直接根据设计分辨率计算
	# 通常在 ready 时 size 可能还未完全确定（如果是 Container），但 Panel 通常有固定大小
	call_deferred("_setup_pivot")
	
	# 连接按钮的视觉反馈信号
	_setup_button_feedback(yes_btn)
	_setup_button_feedback(no_btn)
	
	# 确保一开始是隐藏的
	hide()

func _setup_pivot():
	panel.pivot_offset = panel.size / 2

func _setup_button_feedback(btn: Button):
	btn.pivot_offset = btn.size / 2
	
	# 鼠标悬停动画
	btn.mouse_entered.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.1)
	)
	
	btn.mouse_exited.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)
	)
	
	# 点击按下动画
	btn.button_down.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", Vector2(0.95, 0.95), 0.05)
	)
	
	btn.button_up.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.05) # 回到悬停状态
	)

# 显示弹窗的辅助函数
func open():
	show()
	
	# 确保中心点正确
	if panel.pivot_offset == Vector2.ZERO:
		panel.pivot_offset = panel.size / 2
		
	# 类似于 StorageUI 的打开动画
	panel.scale = Vector2(0.8, 0.8)
	panel.modulate.a = 0.0
	
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.3)
	tween.parallel().tween_property(panel, "modulate:a", 1.0, 0.2)
	
	# 可选：这里可以播放一个弹窗音效

# 关闭动画
func _animate_close(callback: Callable):
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(panel, "scale", Vector2(0.9, 0.9), 0.15)
	tween.parallel().tween_property(panel, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func():
		hide()
		if callback.is_valid():
			callback.call()
	)

# 点击“是”
func _on_yes_pressed():
	# 播放关闭动画，动画结束后发送信号
	_animate_close(func():
		confirm_sleep.emit()
	)

# 点击“否”
func _on_no_pressed():
	# 只是单纯隐藏弹窗，不做任何事
	_animate_close(func(): pass )
