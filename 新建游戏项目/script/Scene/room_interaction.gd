# InteractableObject.gd （挂在床、武器柜等家具上的脚本）

class_name InteractableObject extends Area2D

signal interacted(type: String) # 只需要这一个信号！

# --- 导出变量 (保留) ---
@export var interaction_id: String = "generic"
@export var highlight_node: CanvasItem
@export var hover_cursor: Input.CursorShape = Input.CURSOR_POINTING_HAND

# --- REMOVE: @onready var sleep_ui = $SleepConfirmUI

var _original_modulate: Color

func _ready():
	# 连接 Area2D 自带的鼠标信号
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)
	
	# --- REMOVE: sleep_ui.confirm_sleep.connect(_on_sleep_confirmed)
	
	# 自动查找高亮节点...（保留）
	if not highlight_node:
		var child = get_node_or_null("Highlight")
		if child is CanvasItem:
			highlight_node = child
	
	if highlight_node:
		highlight_node.hide()

# ... (_on_mouse_entered 和 _on_mouse_exited 保留不变) ...

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# 核心：只发信号，不做其他事
			interacted.emit(interaction_id)
			
			# 可选：点击时的微小缩放反馈 (保留)
			var tween = create_tween()
			tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.1)
			tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

# --- REMOVE: func _on_furniture_interacted(type: String):
# --- REMOVE: func _on_sleep_confirmed():


func _on_mouse_entered():
	# 1. 显示高亮图片
	if highlight_node:
		highlight_node.show()
	else:
		# 如果没有高亮图片，就简单的把本体变亮一点 (备用方案)
		_original_modulate = modulate
		modulate = Color(1.2, 1.2, 1.2, 1.0) 
	
	# 2. 更改鼠标光标形状，提示可点击
	Input.set_default_cursor_shape(hover_cursor)

# 鼠标离开区域
func _on_mouse_exited():
	# 1. 隐藏高亮
	if highlight_node:
		highlight_node.hide()
	else:
		modulate = _original_modulate

	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


			
