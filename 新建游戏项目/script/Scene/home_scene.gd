# HomeScene.gd （挂在 HomeScene 根节点上的脚本）
extends BaseScene

# 1. 修正路径：现在 HomeScene 根节点才能正确找到 UI_Layer 下的弹窗
@onready var sleep_ui = $SleepConfirmUI

func _ready():
	# 2. 扫描所有家具，连接它们发出的信号
	var furniture_group = $Furniture.get_children()
	
	for object in furniture_group:
		if object is InteractableObject:
			# 当家具（服务铃）响了，让 HomeScene（经理）来接听
			object.interacted.connect(_on_furniture_interacted)

	# 3. 连接弹窗的信号：当弹窗（服务员）做出决定后，让 HomeScene（经理）来执行
	sleep_ui.confirm_sleep.connect(_on_sleep_confirmed)

# 4. 统一处理所有家具的交互逻辑
func _on_furniture_interacted(type: String):
	match type:
		"bed":
			# 经理听到“床被点击”，知道该打开哪个 UI
			sleep_ui.open()
			
		"weapon_rack":
			print("打开武器柜")
			# 这里调用打开武器柜 UI 的函数
			
		# ... 其他家具 ...

# 5. 玩家确认睡觉后执行的逻辑
func _on_sleep_confirmed():
	print("正在进入梦乡...")
	
	# 播放转场效果...
	
	# 调用全局时间系统推进时间
	if time_manager:
		time_manager.advance_to_next_day() # 注意：这里的方法名我修正为 advance_to_next_day()
	
	# 恢复精力 (根据文档) ...
