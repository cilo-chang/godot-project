extends Control

# 定义信号：告诉外部（主场景）玩家做了什么决定
signal confirm_sleep

func _ready():
	# 初始化时连接按钮信号
	$Panel/HBoxContainer/YesButton.pressed.connect(_on_yes_pressed)
	$Panel/HBoxContainer/NoButton.pressed.connect(_on_no_pressed)
	
	# 确保一开始是隐藏的
	hide()

# 显示弹窗的辅助函数
func open():
	show()
	# 可选：这里可以播放一个弹窗音效

# 点击“是”
func _on_yes_pressed():
	# 隐藏弹窗
	hide()
	# 发送信号告诉主场景：玩家确认要睡觉了
	confirm_sleep.emit()

# 点击“否”
func _on_no_pressed():
	# 只是单纯隐藏弹窗，不做任何事
	hide()
