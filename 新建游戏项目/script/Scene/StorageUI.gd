extends Control

# UI 引用
@onready var panel = $Panel # 需要引用 Panel 进行动画
@onready var title_label = $Panel/TitleLabel
@onready var item_grid = $Panel/ScrollContainer/ItemGrid
@onready var close_button = $Panel/CloseButton
@onready var scroll_container = $Panel/ScrollContainer

# 动态创建的 UI
var category_container: HBoxContainer # 物品分类（消耗品、礼物等）
var main_tab_container: HBoxContainer # 主分页（属性、背包）
var attributes_panel: VBoxContainer # 属性面板容器
var empty_label: Label # 空状态提示

var current_category_filter: int = -1 # -1 表示全部
var is_backpack_mode: bool = false # 是否为背包模式（显示属性面板）
var active_tab_index: int = 0 # 当前主分页索引

# 数据
var current_filter: Array = []

# 分类定义
const CATEGORY_MAP = {
	"全部": - 1,
	"重要物品": ItemData.ItemType.QUEST_ITEM,
	"消耗品": ItemData.ItemType.CONSUMABLE,
	"收藏品": ItemData.ItemType.COLLECTIBLE,
	"礼物": ItemData.ItemType.GIFT
}

# 排序分类按钮顺序
const CATEGORY_ORDER = ["全部", "重要物品", "消耗品", "收藏品", "礼物"]

func _ready():
	# 确保中心点在中间，以便缩放动画从中心开始
	panel.pivot_offset = panel.size / 2
	
	close_button.pressed.connect(_on_close_pressed)
	# 添加按钮交互视觉反馈
	_setup_button_feedback(close_button)
	
	_setup_ui()
	hide()

# --- 按钮视觉反馈逻辑 ---
func _setup_button_feedback(btn: Button):
	# 确保按钮缩放中心在正中间
	btn.pivot_offset = btn.size / 2
	
	# 鼠标悬停：放大
	btn.mouse_entered.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.1)
	)
	
	# 鼠标移出：恢复
	btn.mouse_exited.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)
	)
	
	# 鼠标按下：缩小
	btn.button_down.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", Vector2(0.95, 0.95), 0.05)
	)
	
	# 鼠标松开：弹回悬停状态
	btn.button_up.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.05)
	)

func _setup_ui():
	# 1. 创建主分页按钮容器 (属性 | 背包)
	main_tab_container = HBoxContainer.new()
	$Panel.add_child(main_tab_container)
	main_tab_container.layout_mode = 1
	main_tab_container.anchors_preset = 10
	main_tab_container.anchor_right = 1.0
	main_tab_container.offset_top = 70
	main_tab_container.offset_bottom = 100
	main_tab_container.alignment = BoxContainer.ALIGNMENT_CENTER
	main_tab_container.add_theme_constant_override("separation", 20)
	
	var attr_btn = Button.new()
	attr_btn.text = "属性"
	attr_btn.name = "BtnAttributes" # 命名以便查找
	attr_btn.pressed.connect(_on_main_tab_changed.bind(0))
	main_tab_container.add_child(attr_btn)
	
	var inv_btn = Button.new()
	inv_btn.text = "背包"
	inv_btn.name = "BtnInventory"
	inv_btn.pressed.connect(_on_main_tab_changed.bind(1))
	main_tab_container.add_child(inv_btn)
	
	main_tab_container.hide()
	
	# 2. 创建属性面板容器
	attributes_panel = VBoxContainer.new()
	$Panel.add_child(attributes_panel)
	attributes_panel.layout_mode = 1
	attributes_panel.anchors_preset = 15
	attributes_panel.anchor_right = 1.0
	attributes_panel.anchor_bottom = 1.0
	attributes_panel.offset_left = 50
	attributes_panel.offset_top = 120
	attributes_panel.offset_right = -50
	attributes_panel.offset_bottom = -50
	attributes_panel.hide()

	# 3. 创建物品分类按钮容器
	category_container = HBoxContainer.new()
	$Panel.add_child(category_container)
	category_container.layout_mode = 1
	category_container.anchors_preset = 10
	category_container.anchor_right = 1.0
	category_container.offset_top = 110
	category_container.offset_bottom = 140
	category_container.alignment = BoxContainer.ALIGNMENT_CENTER
	category_container.add_theme_constant_override("separation", 10)
	category_container.hide()
	
	# 4. 创建空状态提示
	empty_label = Label.new()
	empty_label.text = "背包里空空如也..."
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	empty_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.5)) # 半透明灰色
	$Panel.add_child(empty_label)
	empty_label.layout_mode = 1
	empty_label.anchors_preset = 8 # Center
	empty_label.anchor_left = 0.5
	empty_label.anchor_top = 0.5
	empty_label.anchor_right = 0.5
	empty_label.anchor_bottom = 0.5
	empty_label.offset_top = 80 # 稍微偏移避开 Tab
	empty_label.hide()

func open(title: String, allowed_types: Array):
	title_label.text = title
	current_filter = allowed_types
	
	# 动画：打开
	show()
	panel.scale = Vector2(0.8, 0.8)
	panel.modulate.a = 0.0
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.3)
	tween.parallel().tween_property(panel, "modulate:a", 1.0, 0.2)
	
	if allowed_types.size() > 1:
		is_backpack_mode = true
		main_tab_container.show()
		_on_main_tab_changed(0) # 默认属性页
		_setup_category_tabs_content()
	else:
		is_backpack_mode = false
		main_tab_container.hide()
		_show_inventory_view()
		current_category_filter = -1
		category_container.hide()
		scroll_container.offset_top = 80
		refresh_items()

func _on_close_pressed():
	# 动画：关闭
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(panel, "scale", Vector2(0.9, 0.9), 0.15)
	tween.parallel().tween_property(panel, "modulate:a", 0.0, 0.15)
	tween.tween_callback(hide)

# --- 视觉更新逻辑 ---
func _update_tab_visuals():
	# 1. 更新主分页按钮
	for child in main_tab_container.get_children():
		if child is Button:
			if (child.name == "BtnAttributes" and active_tab_index == 0) or \
			   (child.name == "BtnInventory" and active_tab_index == 1):
				child.modulate = Color(1, 1, 0) # 高亮黄色
				child.disabled = true # 禁用当前选中的按钮，防止重复点击
			else:
				child.modulate = Color(1, 1, 1) # 普通白色
				child.disabled = false
	
	# 2. 更新分类按钮
	for child in category_container.get_children():
		if child is Button:
			# 通过绑定的 meta 找回 type，或者无法直接获取，
			# 这里依赖我们之前绑定的 pressed 信号，但无法简单反查。
			# 简单的做法：通过 text 反查 CATEGORY_MAP
			var is_selected = false
			if CATEGORY_MAP.has(child.text):
				if CATEGORY_MAP[child.text] == current_category_filter:
					is_selected = true
			
			if is_selected:
				child.modulate = Color(1, 1, 0)
				child.disabled = true
			else:
				child.modulate = Color(1, 1, 1)
				child.disabled = false

# --- 主分页逻辑 ---
func _on_main_tab_changed(index: int):
	active_tab_index = index
	_update_tab_visuals() # 更新视觉
	
	if index == 0:
		_show_attributes_view()
	else:
		_show_inventory_view(true)

func _show_attributes_view():
	item_grid.get_parent().hide()
	category_container.hide()
	empty_label.hide()
	attributes_panel.show()
	_update_attributes_display()

func _show_inventory_view(_show_categories: bool = false):
	attributes_panel.hide()
	item_grid.get_parent().show()
	
	if is_backpack_mode:
		category_container.show()
		scroll_container.offset_top = 150
		# 如果是第一次切过来，初始化一下显示
		if current_category_filter == -1 and item_grid.get_child_count() == 0:
			refresh_items()
	else:
		category_container.hide()
		scroll_container.offset_top = 110
	
	_update_tab_visuals() # 确保分类标签视觉正确

func _update_attributes_display():
	# 清空旧内容
	for child in attributes_panel.get_children():
		child.queue_free()
	
	var p = gamemanager.player
	if not p:
		return
		
	# 辅助函数：创建属性行
	var create_stat_label = func(text: String):
		var lbl = Label.new()
		lbl.text = text
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 20)
		attributes_panel.add_child(lbl)
	
	# 战斗属性
	create_stat_label.call("=== 战斗属性 ===")
	create_stat_label.call("力量: %d" % p.strength)
	create_stat_label.call("灵巧: %d" % p.agility)
	create_stat_label.call("魔力: %d" % p.magic)
	
	# 社交属性
	create_stat_label.call("\n=== 社交属性 ===")
	create_stat_label.call("魅力: %d" % p.charm)
	create_stat_label.call("口才: %d" % p.eloquence)
	create_stat_label.call("社交影响力: %d" % p.influence)
	
	# 货币
	create_stat_label.call("\n=== 资产 ===")
	create_stat_label.call("赫斯提亚通币: %d" % gamemanager.money)
	create_stat_label.call("索拉金币: %d" % gamemanager.solara_coin)

# --- 物品分类逻辑 ---
func _setup_category_tabs_content():
	for child in category_container.get_children():
		child.queue_free()
	
	for category_name in CATEGORY_ORDER:
		var btn = Button.new()
		btn.text = category_name
		var type = CATEGORY_MAP[category_name]
		
		# 检查可用性
		if type != -1 and not (type in current_filter):
			continue
			
		btn.pressed.connect(_on_category_selected.bind(type))
		btn.custom_minimum_size = Vector2(80, 30)
		category_container.add_child(btn)
	
	_update_tab_visuals()

func _on_category_selected(type: int):
	current_category_filter = type
	refresh_items()
	_update_tab_visuals() # 点击后更新视觉

func refresh_items():
	# 1. 清除现有物品
	for child in item_grid.get_children():
		child.queue_free()
	
	# 2. 获取全局库存数据
	var unique_items = gamemanager.inventory_unique_items
	var stack_items = gamemanager.inventory_stacks
	
	var count = 0
	
	# 3. 筛选并显示不可堆叠物品
	for item in unique_items:
		if _is_allowed(item.type):
			_add_item_slot(item, 1)
			count += 1

	# 4. 筛选并显示可堆叠物品
	for item_id in stack_items.keys():
		var item_data = Databasemanager.items.get(item_id)
		if item_data and _is_allowed(item_data.type):
			_add_item_slot(item_data, stack_items[item_id])
			count += 1
			
	# 空状态检查
	if count == 0:
		empty_label.show()
	else:
		empty_label.hide()

func _is_allowed(type) -> bool:
	var is_in_base_filter = false
	if current_filter.is_empty():
		is_in_base_filter = true
	else:
		is_in_base_filter = type in current_filter
		
	if not is_in_base_filter:
		return false
		
	if current_category_filter == -1:
		return true
	
	return type == current_category_filter

func _add_item_slot(item_data, quantity):
	var slot = Button.new()
	slot.custom_minimum_size = Vector2(80, 80)
	slot.text = item_data.name
	
	if quantity > 1:
		slot.text += "\nx%d" % quantity
		
	slot.tooltip_text = item_data.description
	item_grid.add_child(slot)
