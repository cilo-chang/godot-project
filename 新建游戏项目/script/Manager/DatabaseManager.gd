# res://singletons/DatabaseManager.gd
extends Node

# --- 1. 数据存储细分 ---
# 将原本的大杂烩 cards 拆分，但保留一个总索引 all_cards 方便根据ID查找任意卡
var all_cards: Dictionary = {} # 总索引：ID -> Resource
var combat_cards: Dictionary = {} # 战斗卡牌
var action_cards: Dictionary = {} # 行动卡牌
var life_skill_cards: Dictionary = {} # 生活职业卡牌
var quest_cards: Dictionary = {} # 任务卡牌
var explore_card: Dictionary = {} # 探索卡牌

# 其他保持不变
var characters: Dictionary = {}
var weapons: Dictionary = {}
var items: Dictionary = {}
var quests: Dictionary = {}
var heart_forest_nodes: Dictionary = {}

func _ready():
	print("【DatabaseManager】开始加载所有静态数据...")
	load_all_static_data()
	print("【DatabaseManager】加载完成！战斗卡: %d, 行动卡: %d" % [combat_cards.size(), action_cards.size()])

func load_all_static_data():
	# 1. 加载所有卡牌到各自的字典
	# 注意：这里我们加载大的父文件夹，并在加载函数里根据 class_name 自动分拣
	_load_and_sort_cards("res://data/cards/")
	
	# 2. 加载其他数据
	_load_folder_recursive("res://data/characters/", characters)
	_load_folder_recursive("res://data/weapons/", weapons)
	_load_folder_recursive("res://data/items/", items)
	# ... 其他加载 ...

# --- 改进的核心加载函数 ---
# 专门用于加载卡牌并自动归类的函数
func _load_and_sort_cards(path: String):
	# 临时字典，用于接收递归加载的所有卡牌资源
	var temp_dict = {}
	_load_folder_recursive(path, temp_dict)
	
	for id in temp_dict:
		var card_res = temp_dict[id]
		
		# 1. 存入总索引 (带有重复ID检查)
		if all_cards.has(id):
			push_error("【严重错误】发现重复的卡牌ID: %s. 请检查资源文件！" % id)
			continue
		all_cards[id] = card_res
		
		# 2. 根据类型自动分发到子字典
		# 利用 is 关键字检查类型
		if card_res is CombatCardData:
			combat_cards[id] = card_res
		elif card_res is ActionCardData:
			action_cards[id] = card_res
		elif card_res is LifeSkillCardData:
			life_skill_cards[id] = card_res
		else:
			# 未知类型的卡牌，但也存入了 all_cards
			print("警告：ID为 %s 的卡牌未归类到特定子字典" % id)

# 通用递归加载函数 (增加了导出兼容性)
func _load_folder_recursive(path: String, dict: Dictionary):
	var dir = DirAccess.open(path)
	if not dir: return

	if not path.ends_with("/"): path += "/"

	dir.list_dir_begin()
	var file_name := dir.get_next()
	
	while file_name != "":
		# 忽略导航文件夹
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue

		var full_path := path.path_join(file_name)

		if dir.current_is_dir():
			_load_folder_recursive(full_path, dict)
		else:
			# --- 导出兼容性处理 ---
			# 导出后，资源文件可能会变成 .tres.remap，需要去掉 .remap 后缀才能 load
			var load_path = full_path
			if file_name.ends_with(".remap"):
				load_path = full_path.trim_suffix(".remap")
				file_name = file_name.trim_suffix(".remap") # 修正文件名用于后续检查
			
			if file_name.ends_with(".tres") or file_name.ends_with(".res"):
				# 尝试加载
				var res = load(load_path)
				
				# 更加健壮的检查
				if res and "id" in res and res.id != "":
					# 检查当前局部字典是否已有ID
					if dict.has(res.id):
						push_error("【冲突】在路径 %s 发现重复ID: %s" % [path, res.id])
					else:
						dict[res.id] = res
				else:
					# print("警告：文件 %s 加载失败或没有 'id' 属性" % file_name)
					pass
		
		file_name = dir.get_next()
	dir.list_dir_end()
