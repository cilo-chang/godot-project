# res://singletons/GameManager.gd
extends Node
# class_name GameManager # Autoload 不需要 class_name，除非你想在其他脚本做静态引用

# --- 0. 信号定义 ---
# FIX: 添加信号定义，供 ItemData 调用
signal item_used(item_id: String, target_id: String)

# --- 1. 数据持有 ---
@export var player: PlayerData

# --- 2. 战斗状态 ---

var current_deck: Array[CombatCardData] = []
var equipped_weapon: WeaponData = null
# var equipped_accessory: ItemData = null

# --- 3. 物品/货币 (库存系统重构) ---
# FIX: 移除旧的 inventory 数组，提升局部变量为全局变量
var inventory_stacks: Dictionary = {} # 可堆叠物品: { "item_id": quantity }
var inventory_unique_items: Array[ItemData] = [] # 不可堆叠物品: [ItemDataInstance, ...]
var money: int = 0
var solara_coin: int = 0

# --- 4. 行动卡牌 ---
# FIX: 变量声明移到顶部
var available_action_cards: Array[ActionCardData] = []

# --- 初始化 ---
func _ready():
	# 连接自身的信号 (用于处理物品效果分发)
	item_used.connect(_on_item_used)
	
	var player_res = load("res://data/base/player.tres")
	if player_res:
		player = player_res.duplicate() as PlayerData
	else:
		player = PlayerData.new()
	
	load_initial_action_cards()
	print("GameManager 3.0 已就绪！")

# --- 核心逻辑：每日重置 ---
func reset_daily_energy():
	var sleep_quality := randi_range(10, 40)
	var stamina_bonus := player.stamina * 0.5
	player.energy += sleep_quality + stamina_bonus
	player.energy = min(player.energy, 200)
	print("【新的一天】精力恢复至：%d" % player.energy)

# --- 核心逻辑：卡牌与日程 ---
func add_action_card(card_instance: CardData):
	available_action_cards.append(card_instance)
	print("卡牌已添加: ", card_instance.id)

func load_initial_action_cards():
	var db = Databasemanager
	# FIX: 增加 null 检查，防止数据库没加载导致崩溃
	if not db.all_cards: return

	var entertain_res = db.all_cards.get("entertain_read_book")
	var first_quest_res = db.all_cards.get("main_act1_step1")
	
	if entertain_res:
		add_action_card(entertain_res.duplicate())
	if first_quest_res:
		add_action_card(first_quest_res.duplicate())

# --- 核心逻辑：战斗 ---
func build_battle_deck(main_char_id: String, assist_char_ids: Array[String] = []):
	current_deck.clear()
	for card_id in player.base_cards:
		var card_res = Databasemanager.cards.get(card_id)
		if card_res:
			current_deck.append(card_res.duplicate())
	
	for assist_id in assist_char_ids:
		var npc_data = Databasemanager.characters.get(assist_id)
		# FIX: 这里的 60 和 100 最好提取为常量，暂且保留
		if npc_data and player.get_affection(assist_id) >= 60:
			for card_id in npc_data.assist_cards:
				current_deck.append(Databasemanager.cards.get(card_id).duplicate())
			
			if player.get_affection(assist_id) >= 100 and npc_data.awakening_card_id:
				current_deck.append(Databasemanager.cards.get(npc_data.awakening_card_id).duplicate())

	print("战斗牌组构建完成，共 ", current_deck.size(), " 张卡")

# --- 核心逻辑：物品系统 (重写) ---

# 1. 添加物品
func add_item(item_data: ItemData, quantity: int = 1):
	if quantity <= 0: return

	if item_data.stackable:
		var item_id = item_data.id
		# FIX: 直接操作全局变量 inventory_stacks，而不是创建局部变量
		if inventory_stacks.has(item_id):
			inventory_stacks[item_id] += quantity
		else:
			inventory_stacks[item_id] = quantity
	else:
		# FIX: 直接操作全局变量 inventory_unique_items
		for i in range(quantity):
			var new_instance = item_data.duplicate()
			inventory_unique_items.append(new_instance)
			
	print("已添加 %d 个物品 [%s]。" % [quantity, item_data.id])

# 2. 移除物品 (用于消耗品使用)
func remove_item(item_id: String, quantity: int = 1) -> bool:
	# 检查堆叠物品
	if inventory_stacks.has(item_id):
		if inventory_stacks[item_id] >= quantity:
			inventory_stacks[item_id] -= quantity
			if inventory_stacks[item_id] <= 0:
				inventory_stacks.erase(item_id)
			return true
		else:
			print("物品数量不足！")
			return false
	# 检查不可堆叠物品 (逻辑较复杂，通常消耗品都是可堆叠的，这里暂略)
	return false

# 3. 触发物品使用的入口函数 (供 ItemData 调用)
func signal_item_usage(item_id: String, target_id: String):
	# 先尝试扣除物品
	if remove_item(item_id, 1):
		# 扣除成功，发射信号
		item_used.emit(item_id, target_id)
	else:
		print("物品使用失败：库存不足")

# 4. 信号处理逻辑
func _on_item_used(item_id: String, target_id: String):
	var item_data = Databasemanager.items.get(item_id)
	if item_data == null: return
	
	if item_data is ConsumableItemData:
		_apply_life_effect(item_data, target_id)
		
	elif item_data is PotionItemData:
		# FIX: 补充 is_in_battle 函数
		if is_in_battle():
			# BattleManager.apply_potion_effect(item_data, target_id)
			pass
		else:
			print("警告：战斗魔药不能在非战斗状态下使用！")
			add_item(item_data, 1) # 退还物品
			
	elif item_data is GiftItemData:
		var increased = false
		# 假设 player 有 increase_affection(npc_id, value) 方法
		# 如果没有，暂时只打印
		if player.has_method("increase_affection"):
			player.increase_affection(target_id, item_data.base_affection_value)
			increased = true
		else:
			print("GiftManager logic placeholder: Increased affection for %s by %d" % [target_id, item_data.base_affection_value])
			increased = true
			
		if increased:
			print("已赠送礼物 [%s] 给 %s" % [item_data.name, target_id])

# 5. 生活效果应用
func _apply_life_effect(consumable: ConsumableItemData, target_id: String):
	# FIX: 修正变量名 player_data -> player
	match consumable.category:
		ConsumableItemData.ConsumableCategory.GENERAL_RECOVERY:
			if consumable.target_stat == ConsumableItemData.EffectTargetStat.ENERGY:
				player.energy += consumable.effect_value
				print("精力恢复了: ", consumable.effect_value)
			
		ConsumableItemData.ConsumableCategory.PERMANENT_STAT_BOOST:
			var stat_name = ""
			match consumable.target_stat:
				ConsumableItemData.EffectTargetStat.BASE_STR: stat_name = "strength"
				ConsumableItemData.EffectTargetStat.AGILITY: stat_name = "agility"
				ConsumableItemData.EffectTargetStat.MAGIC: stat_name = "magic"
				ConsumableItemData.EffectTargetStat.STAMINA: stat_name = "stamina"
				ConsumableItemData.EffectTargetStat.CHARISMA: stat_name = "charm"
				ConsumableItemData.EffectTargetStat.ELOQUENCE: stat_name = "eloquence"
				ConsumableItemData.EffectTargetStat.INFLUENCE: stat_name = "influence"
				# ConsumableItemData.EffectTargetStat.MOOD: stat_name = "mood" # PlayerData missing mood?
			
			if stat_name != "":
				var current_val = player.get(stat_name)
				if current_val != null:
					player.set(stat_name, current_val + consumable.effect_value)
					print("永久提升 %s : +%d" % [stat_name, consumable.effect_value])
				else:
					print("Error: Player missing property '%s'" % stat_name)

# --- 辅助函数 ---
func is_in_battle() -> bool:
	# 检查 BattleManager 是否存在且处于战斗中
	if has_node("/root/BattleManager"):
		return get_node("/root/BattleManager").is_battling
	return false # 默认不在战斗中
