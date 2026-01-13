extends Control

# 信号：开始日程
signal start_schedule

# --- Inner Classes for Drag & Drop ---

class DraggableActionCard extends PanelContainer:
	var card_data: ActionCardData
	var is_library_source: bool = true
	var is_affordable: bool = true
	
	# External references
	# Removed unused signals
	
	func _init(data: ActionCardData, is_lib: bool = true):
		card_data = data
		is_library_source = is_lib
		custom_minimum_size = Vector2(110, 150)
		
		mouse_filter = Control.MOUSE_FILTER_STOP
		
		# Base Style
		var style = StyleBoxFlat.new()
		style.bg_color = _get_color_by_type(data.action_type)
		style.border_width_bottom = 4
		style.border_color = style.bg_color.darkened(0.2)
		style.corner_radius_top_left = 6
		style.corner_radius_top_right = 6
		style.corner_radius_bottom_left = 6
		style.corner_radius_bottom_right = 6
		add_theme_stylebox_override("panel", style)
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		add_child(vbox)
		
		# Icon (Placeholder)
		var icon_rect = ColorRect.new()
		icon_rect.color = Color(1, 1, 1, 0.2)
		icon_rect.custom_minimum_size = Vector2(60, 60)
		icon_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		vbox.add_child(icon_rect)
		
		var name_label = Label.new()
		name_label.text = data.name
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(name_label)
		
		var cost_label = Label.new()
		cost_label.text = "-%d 精力" % data.energy_cost
		cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cost_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
		vbox.add_child(cost_label)
		
		var type_label = Label.new()
		type_label.text = _get_type_name(data.action_type)
		type_label.add_theme_font_size_override("font_size", 10)
		type_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
		type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(type_label)
		
		self.mouse_entered.connect(_on_mouse_entered)
		self.mouse_exited.connect(_on_mouse_exited)

	func update_state(current_energy: int):
		if not is_library_source: return
		
		if card_data.energy_cost > current_energy:
			is_affordable = false
			modulate = Color(0.4, 0.4, 0.4, 0.8) # Dimmed
			tooltip_text = "精力不足"
		else:
			is_affordable = true
			modulate = Color.WHITE
			tooltip_text = ""

	func _get_color_by_type(type) -> Color:
		match type:
			ActionCardData.ActionType.ENTERTAINMENT: return Color(0.2, 0.6, 0.8) # Blue
			ActionCardData.ActionType.SOCIAL: return Color(0.8, 0.4, 0.6) # Pink
			ActionCardData.ActionType.STUDY: return Color(0.3, 0.7, 0.4) # Green
			ActionCardData.ActionType.EXPLORE: return Color(0.8, 0.6, 0.2) # Orange
			ActionCardData.ActionType.QUEST: return Color(0.7, 0.2, 0.2) # Red
			_: return Color.GRAY

	func _get_type_name(type) -> String:
		match type:
			ActionCardData.ActionType.ENTERTAINMENT: return "娱乐"
			ActionCardData.ActionType.SOCIAL: return "钻研" # Wait, Social is Social, Study is Study.
			ActionCardData.ActionType.STUDY: return "钻研"
			ActionCardData.ActionType.EXPLORE: return "探索"
			ActionCardData.ActionType.QUEST: return "任务"
			_: return "未知"

	func _get_drag_data(_at_position):
		if not is_affordable and is_library_source: return null
		
		var preview = self.duplicate()
		preview.modulate.a = 0.8
		preview.rotation_degrees = 5
		
		var preview_control = Control.new()
		preview_control.add_child(preview)
		preview.position = - preview.size / 2
		
		set_drag_preview(preview_control)
		
		return {"card": card_data, "source": self}
		
	func _on_mouse_entered():
		# Emit signal to parent/manager if connected, or use group
		# For now, we rely on the container to connect or bubbling
		# Actually, easy way: get_tree().call_group("ScheduleUI", "_on_card_hovered", card_data)
		# But we are inside ScheduleUI script, just inner class. 
		# Inner classes don't automatically have access to outer class instance methods efficiently without passing ref.
		pass

	func _on_mouse_exited():
		pass

class DroppableTimeSlot extends PanelContainer:
	var period_name: String
	var is_locked: bool = false
	var current_card: ActionCardData = null
	
	signal card_dropped(card_data, period)
	signal slot_hovered(card_data, period) # Signal to update details panel
	
	var content_area: Panel
	var card_container: MarginContainer
	var label: Label
	var feedback_rect: ColorRect # For color matching feedback
	
	func _init(period: String, locked: bool):
		period_name = period
		is_locked = locked
		custom_minimum_size = Vector2(0, 100) # Increased height
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.1, 0.1, 0.5)
		if locked:
			style.bg_color = Color(0.05, 0.05, 0.05, 0.8)
		add_theme_stylebox_override("panel", style)
		
		# Feedback overlay
		feedback_rect = ColorRect.new()
		feedback_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		feedback_rect.color = Color.TRANSPARENT
		feedback_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(feedback_rect)
		
		var hbox = HBoxContainer.new()
		add_child(hbox)
		
		# Time Label Area
		var label_container = MarginContainer.new()
		label_container.custom_minimum_size = Vector2(120, 0)
		label_container.add_theme_constant_override("margin_left", 10)
		hbox.add_child(label_container)
		
		label = Label.new()
		label.text = period
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 20)
		label_container.add_child(label)
		
		# Drop Area
		content_area = Panel.new()
		content_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		content_area.mouse_filter = Control.MOUSE_FILTER_PASS
		
		var area_style = StyleBoxFlat.new()
		area_style.bg_color = Color(0, 0, 0, 0.3)
		area_style.border_width_bottom = 2
		area_style.border_color = Color(0.3, 0.3, 0.3)
		content_area.add_theme_stylebox_override("panel", area_style)
		
		hbox.add_child(content_area)
		
		# Container for the card when dropped
		card_container = MarginContainer.new()
		card_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		card_container.add_theme_constant_override("margin_top", 4)
		card_container.add_theme_constant_override("margin_bottom", 4)
		card_container.add_theme_constant_override("margin_left", 4)
		card_container.add_theme_constant_override("margin_right", 4)
		card_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content_area.add_child(card_container)
		
		if locked:
			modulate = Color(0.5, 0.5, 0.5, 0.5)
			
			var lock_lbl = Label.new()
			lock_lbl.text = "Locked"
			lock_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lock_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lock_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			content_area.add_child(lock_lbl)
		else:
			# Hint text if empty
			var hint = Label.new()
			hint.text = "拖拽行动卡牌至此"
			hint.name = "HintLabel"
			hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.3))
			hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			hint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			content_area.add_child(hint)
			
		# Connect signals for Details Panel
		self.mouse_entered.connect(_on_mouse_entered)
		self.mouse_exited.connect(_on_mouse_exited)

	func _can_drop_data(_at_position, data):
		if is_locked: return false
		if data is Dictionary and data.has("card"):
			# Visual feedback when dragging over
			var card_type = data["card"].action_type
			_show_matching_feedback(card_type)
			return true
		return false
		
	func _drop_data(_at_position, data):
		_clear_feedback()
		if is_locked: return
		var card = data["card"]
		set_card(card)
		card_dropped.emit(card, period_name)
		
	func set_card(card: ActionCardData):
		current_card = card
		# Clear existing
		for child in card_container.get_children():
			child.queue_free()
		
		# Hide Hint
		var hint = content_area.get_node_or_null("HintLabel")
		if hint: hint.hide()
			
		# Create mini representation - Just text for now in slot, or simple icon
		var display = HBoxContainer.new()
		display.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		display.alignment = BoxContainer.ALIGNMENT_CENTER
		
		var name_lbl = Label.new()
		name_lbl.text = card.name
		name_lbl.add_theme_font_size_override("font_size", 18)
		display.add_child(name_lbl)
		
		card_container.add_child(display)
		
		# Change slot border color based on type
		var style = content_area.get_theme_stylebox("panel").duplicate()
		style.border_color = _get_color_by_type(card.action_type)
		style.border_width_top = 2
		style.border_width_left = 2
		style.border_width_right = 2
		content_area.add_theme_stylebox_override("panel", style)

	func _show_matching_feedback(card_type):
		# Golden glow or particles
		# Simple implementation: Golden border or background tint
		feedback_rect.color = _get_color_by_type(card_type)
		feedback_rect.color.a = 0.2

	func _clear_feedback():
		feedback_rect.color = Color.TRANSPARENT

	func _on_mouse_entered():
		slot_hovered.emit(current_card, period_name)
		
	func _on_mouse_exited():
		slot_hovered.emit(null, period_name)
		_clear_feedback() # Ensure cleared if dragged out without drop

	func _get_color_by_type(type) -> Color:
		match type:
			ActionCardData.ActionType.ENTERTAINMENT: return Color(0.2, 0.6, 0.8)
			ActionCardData.ActionType.SOCIAL: return Color(0.8, 0.4, 0.6)
			ActionCardData.ActionType.STUDY: return Color(0.3, 0.7, 0.4)
			ActionCardData.ActionType.EXPLORE: return Color(0.8, 0.6, 0.2)
			ActionCardData.ActionType.QUEST: return Color(0.7, 0.2, 0.2)
			_: return Color.GRAY


# UI 引用
@onready var panel = $Panel
# Temporary nodes from scene file (will be reparented or removed)
@onready var close_button = $Panel/CloseButton
@onready var confirm_button = $Panel/ConfirmButton

# New UI References
var header_container: PanelContainer
var energy_bar: ProgressBar
var date_label: Label
var currency_label: Label

var split_container: HSplitContainer
var left_panel: VBoxContainer # Decision Area
var right_panel: VBoxContainer # Resource Browsing

var time_slots_container: VBoxContainer # 4 Vertical Slots
var inspector_panel: PanelContainer # Bottom Left Details

var library_tab_container: TabContainer # Right Side

# Data
var current_energy: int = 85
var max_energy: int = 100
var assigned_cards: Dictionary = {} # period -> card_id

func _ready():
	# Initialize Base UI
	_init_layout_structure()
	_init_header()
	_init_left_panel()
	_init_right_panel()
	
	# Connect Buttons
	close_button.pressed.connect(_on_close_pressed) # Re-connected in header if moved
	
	# Hide initially
	hide()

# --- 1. Top-Level Layout ---
func _init_layout_structure():
	# Full Screen Background
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.08, 0.08, 0.1, 0.98) # Deep dark blue/gray
	panel.add_theme_stylebox_override("panel", bg)
	
	# Clear existing children of panel except the ones we need to specificly move referenced by @onready
	# Actually, easier to just create a new root VBox and reparent everything into it
	var root_vbox = VBoxContainer.new()
	root_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_vbox.add_theme_constant_override("separation", 0)
	panel.add_child(root_vbox)
	
	# 1. Header (Fixed Height)
	header_container = PanelContainer.new()
	header_container.custom_minimum_size.y = 80
	root_vbox.add_child(header_container)
	
	# 2. Main Content (Split View)
	split_container = HSplitContainer.new()
	split_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split_container.split_offset = 400 # Initial split position
	root_vbox.add_child(split_container)
	
	# Left Side (Decision) - Fixed width preferred or ratio? 
	# HSplitContainer allows resizing. Let's make Left side the "decision" side.
	left_panel = VBoxContainer.new()
	left_panel.name = "LeftPanel_Decision"
	split_container.add_child(left_panel)
	
	# Right Side (Library)
	right_panel = VBoxContainer.new()
	right_panel.name = "RightPanel_Library"
	split_container.add_child(right_panel)

# --- 2. Header Bar ---
func _init_header():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2)
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.3, 0.4)
	header_container.add_theme_stylebox_override("panel", style)
	
	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 20)
	header_container.add_child(hbox)
	
	# Left: Date & Season
	var date_box = HBoxContainer.new()
	date_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	date_box.size_flags_stretch_ratio = 0.3
	
	date_label = Label.new()
	date_label.text = "4001年9月1日 [秋]"
	date_label.add_theme_font_size_override("font_size", 24)
	date_box.add_child(date_label)
	hbox.add_child(date_box)
	
	# Middle: Energy Bar
	var energy_box = VBoxContainer.new()
	energy_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	energy_box.alignment = BoxContainer.ALIGNMENT_CENTER
	
	energy_bar = ProgressBar.new()
	energy_bar.custom_minimum_size = Vector2(300, 30)
	energy_bar.max_value = max_energy
	energy_bar.value = current_energy
	energy_bar.show_percentage = false
	
	# Custom style for energy bar
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2)
	bg_style.corner_radius_top_left = 15
	bg_style.corner_radius_bottom_left = 15
	bg_style.corner_radius_top_right = 15
	bg_style.corner_radius_bottom_right = 15
	energy_bar.add_theme_stylebox_override("background", bg_style)
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.2, 0.8, 0.4) # Green/Energy color
	fill_style.corner_radius_top_left = 15
	fill_style.corner_radius_bottom_left = 15
	fill_style.corner_radius_top_right = 15
	fill_style.corner_radius_bottom_right = 15
	energy_bar.add_theme_stylebox_override("fill", fill_style)
	
	# Overlay Label
	var e_lbl = Label.new()
	e_lbl.text = "%d / %d" % [current_energy, max_energy]
	e_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	e_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	energy_bar.add_child(e_lbl)
	
	energy_box.add_child(energy_bar)
	hbox.add_child(energy_box)
	
	# Right: Currency & Close
	var right_box = HBoxContainer.new()
	right_box.alignment = BoxContainer.ALIGNMENT_END
	right_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_box.size_flags_stretch_ratio = 0.3
	
	currency_label = Label.new()
	currency_label.text = "金币: 1200 | 索拉: 50"
	right_box.add_child(currency_label)
	
	# Reparent existing close button
	if close_button.get_parent():
		close_button.reparent(right_box)
	close_button.custom_minimum_size = Vector2(40, 40)
	close_button.text = "X"
	
	hbox.add_child(right_box)

# --- 3. Left Panel (Slots & Details) ---
func _init_left_panel():
	left_panel.add_theme_constant_override("separation", 20)
	
	# 3.1 Action Slots Area (Top, taking most space)
	time_slots_container = VBoxContainer.new()
	time_slots_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	time_slots_container.size_flags_stretch_ratio = 0.7 # 70% height
	time_slots_container.alignment = BoxContainer.ALIGNMENT_CENTER
	left_panel.add_child(time_slots_container)
	
	_create_time_slots()
	
	# 3.2 Inspector/Details Panel (Bottom)
	inspector_panel = PanelContainer.new()
	inspector_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inspector_panel.size_flags_stretch_ratio = 0.3 # 30% height
	left_panel.add_child(inspector_panel)
	
	var insp_style = StyleBoxFlat.new()
	insp_style.bg_color = Color(0.1, 0.1, 0.15)
	inspector_panel.add_theme_stylebox_override("panel", insp_style)
	
	# Initial Inspector Content
	_update_inspector(null)

func _create_time_slots():
	var periods = ["上午", "下午", "晚上", "午夜"]
	for p in periods:
		var slot = DroppableTimeSlot.new(p, p == "午夜") # Default lock midnight
		slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
		time_slots_container.add_child(slot)
		
		# Connect Signals
		slot.card_dropped.connect(_on_card_dropped_in_slot)
		slot.slot_hovered.connect(_on_slot_hovered)

# --- 4. Right Panel (Library) ---
func _init_right_panel():
	# Tab Controller
	library_tab_container = TabContainer.new()
	library_tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	library_tab_container.tab_alignment = TabBar.ALIGNMENT_CENTER
	right_panel.add_child(library_tab_container)
	
	# Define Categories
	var categories = [
		{"key": "All", "label": "全部"},
		{"key": "Entertainment", "label": "娱乐", "type": ActionCardData.ActionType.ENTERTAINMENT},
		{"key": "Social", "label": "社交", "type": ActionCardData.ActionType.SOCIAL},
		{"key": "Study", "label": "钻研", "type": ActionCardData.ActionType.STUDY},
		{"key": "Explore", "label": "探索", "type": ActionCardData.ActionType.EXPLORE},
		{"key": "Quest", "label": "任务", "type": ActionCardData.ActionType.QUEST}
	]
	
	for cat in categories:
		var page = MarginContainer.new()
		page.name = cat["label"]
		page.set_meta("category_type", cat.get("type", -1)) # -1 for All
		
		page.add_theme_constant_override("margin_top", 10)
		page.add_theme_constant_override("margin_left", 10)
		page.add_theme_constant_override("margin_right", 10)
		page.add_theme_constant_override("margin_bottom", 10)
		library_tab_container.add_child(page)
		
		var scroll = ScrollContainer.new()
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		page.add_child(scroll)
		
		# Using GridContainer for cleaner layout, or HFlow
		var grid = HFlowContainer.new()
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll.add_child(grid)

# --- Helper Logic ---
func open():
	show()
	_update_header_data()
	_populate_card_library()
	
	# Simple animation
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

func _on_close_pressed():
	hide()

func _update_header_data():
	# In real implementation, pull from GameManager
	energy_bar.value = current_energy
	
	# Update all library items availability
	_update_library_items_state()

func _update_library_items_state():
	# Recursively find all DraggableActionCard and update them
	# Or just iterate known containers
	for i in range(library_tab_container.get_tab_count()):
		var page = library_tab_container.get_tab_control(i)
		var grid = page.get_child(0).get_child(0) # Scroll -> Grid
		for child in grid.get_children():
			if child is DraggableActionCard:
				child.update_state(current_energy)

func _populate_card_library():
	# Clear all grids
	for i in range(library_tab_container.get_tab_count()):
		var page = library_tab_container.get_tab_control(i)
		var grid = page.get_child(0).get_child(0)
		for child in grid.get_children():
			child.queue_free()
	
	var game_manager = get_node_or_null("/root/GameManager")
	var cards = []
	if game_manager:
		cards = game_manager.available_action_cards
	else:
		# Dummy data for testing if no manager
		_add_dummy_cards(cards)

	for card_data in cards:
		# Create card instance
		# We need to add to "All" and specific category
		_add_card_to_tab("全部", card_data)
		
		var type_name = _get_type_name_cn(card_data.action_type)
		_add_card_to_tab(type_name, card_data)
	
	_update_library_items_state()

func _add_card_to_tab(tab_name: String, card_data: ActionCardData):
	var target_tab = null
	for i in range(library_tab_container.get_tab_count()):
		if library_tab_container.get_tab_title(i) == tab_name:
			target_tab = library_tab_container.get_tab_control(i)
			break
	
	if target_tab:
		var grid = target_tab.get_child(0).get_child(0)
		var item = DraggableActionCard.new(card_data, true)
		
		# Connect hover for inspector
		item.mouse_entered.connect(func(): _on_card_hovered(card_data))
		item.mouse_exited.connect(func(): _on_card_hovered(null))
		
		grid.add_child(item)

func _get_type_name_cn(type) -> String:
	match type:
		ActionCardData.ActionType.ENTERTAINMENT: return "娱乐"
		ActionCardData.ActionType.SOCIAL: return "社交"
		ActionCardData.ActionType.STUDY: return "钻研"
		ActionCardData.ActionType.EXPLORE: return "探索"
		ActionCardData.ActionType.QUEST: return "任务"
		_: return "未知"

func _add_dummy_cards(list: Array):
	# Create some fake cards for visual testing
	for i in range(10):
		var c = ActionCardData.new()
		c.name = "Test Card " + str(i)
		c.energy_cost = 10 + i * 5
		c.action_type = i % 5
		c.effect_description = "Increases stats by %d" % (i + 1)
		list.append(c)

# --- Interaction Handlers ---

func _on_card_dropped_in_slot(card: ActionCardData, period: String):
	print("Card %s dropped in %s" % [card.name, period])
	assigned_cards[period] = card.id
	
	# Simulate energy cost prediction/deduction logic here
	# For now just update UI
	
	# Trigger sound?
	pass

func _on_card_hovered(card: ActionCardData):
	_update_inspector(card)

func _on_slot_hovered(card: ActionCardData, period: String):
	# If slot has a card, show it. If not, show "Empty Slot" text?
	# Implementation: If card is null, maybe clear inspector or show slot details
	if card:
		_update_inspector(card, period)
	else:
		if period:
			_update_inspector(null, period)
		else:
			_update_inspector(null)

func _update_inspector(card: ActionCardData, slot_context: String = ""):
	# Clear current
	for child in inspector_panel.get_children():
		child.queue_free()
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	inspector_panel.add_child(vbox)
	
	if card:
		var title = Label.new()
		title.text = card.name
		title.add_theme_font_size_override("font_size", 22)
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(title)
		
		var info_box = HBoxContainer.new()
		vbox.add_child(info_box)
		
		var attr_lbl = Label.new()
		attr_lbl.text = "Type: " + _get_type_name_cn(card.action_type)
		attr_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_box.add_child(attr_lbl)
		
		var cost_lbl = Label.new()
		cost_lbl.text = "Cost: " + str(card.energy_cost)
		cost_lbl.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
		info_box.add_child(cost_lbl)
		
		var desc = RichTextLabel.new()
		desc.text = card.effect_description if card.effect_description else "No description available."
		desc.fit_content = true
		desc.custom_minimum_size = Vector2(0, 100)
		vbox.add_child(desc)
		
		if slot_context:
			var loc_lbl = Label.new()
			loc_lbl.text = "Placed in: " + slot_context
			loc_lbl.add_theme_color_override("font_color", Color(0.6, 1, 0.6))
			vbox.add_child(loc_lbl)
			
	else:
		var hint = Label.new()
		if slot_context:
			hint.text = "Slot: " + slot_context + "\n(Empty)"
		else:
			hint.text = "Select or Hover a card \nto view details"
			
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		inspector_panel.add_child(hint)
