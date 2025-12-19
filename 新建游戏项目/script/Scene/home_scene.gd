# HomeScene.gd （挂在 HomeScene 根节点上的脚本）
extends BaseScene

# 1. 修正路径：现在 HomeScene 根节点才能正确找到 UI_Layer 下的弹窗
@onready var sleep_ui = $SleepConfirmUI
@onready var storage_ui = $StorageUI # Added Storage UI reference
@onready var schedule_ui = $ScheduleUI # 日程 UI 引用
@onready var backpack_btn = $Control/BackpackButton # Reference to Backpack Button
@onready var schedule_btn = $Control/ScheduleButton # 日程按钮引用

func _ready():
	# 2. 扫描所有家具，连接它们发出的信号
	var furniture_group = $Furniture.get_children()
	
	for object in furniture_group:
		if object is InteractableObject:
			# 当家具（服务铃）响了，让 HomeScene（经理）来接听
			object.interacted.connect(_on_furniture_interacted)

	# 3. 连接弹窗的信号：当弹窗（服务员）做出决定后，让 HomeScene（经理）来执行
	sleep_ui.confirm_sleep.connect(_on_sleep_confirmed)
	
	# 连接其他 UI 信号
	if backpack_btn:
		backpack_btn.pressed.connect(_on_backpack_pressed)
		
	if schedule_btn:
		schedule_btn.pressed.connect(func():
			if schedule_ui:
				schedule_ui.open()
		)

# 4. 统一处理所有家具的交互逻辑
func _on_furniture_interacted(type: String):
	match type:
		"bed":
			sleep_ui.open()
		"weapon_rack":
			storage_ui.open("Weapon Rack", [ItemData.ItemType.WEAPON])
		"potion_cabinet":
			storage_ui.open("Potion Cabinet", [ItemData.ItemType.POTION])
		"bookshelf":
			storage_ui.open("Bookshelf", [ItemData.ItemType.BOOK])
		# ... 其他家具 ...

func _on_backpack_pressed():
	# Backpack shows everything except what's in specialized storage (conceptually, or just these specific types)
	# Based on GDD: Gift, Consumable, Collectible, Quest Item
	storage_ui.open("Backpack", [
		ItemData.ItemType.GIFT,
		ItemData.ItemType.CONSUMABLE,
		ItemData.ItemType.COLLECTIBLE,
		ItemData.ItemType.QUEST_ITEM
	])

# 5. 玩家确认睡觉后执行的逻辑
func _on_sleep_confirmed():
	print("正在进入梦乡...")
	
	# 播放转场效果...
	
	# 调用全局时间系统推进时间
	if time_manager:
		time_manager.advance_day() # 注意：这里的方法名我修正为 advance_to_next_day()
	
	# 恢复精力 (根据文档) ...
