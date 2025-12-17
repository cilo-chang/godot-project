extends Node

# 假设 time_manager 和 gamemanager 是全局 Autoload

func check_quest_eligibility(quest_data: QuestData) -> bool:
	# 1. 检查基础触发条件 (所有任务类型都适用)
	if time_manager.current_day < quest_data.start_day:
		return false
		
	# 1.2 检查玩家属性需求
	for attr_name in quest_data.required_player_attr:
		var required_val = quest_data.required_player_attr[attr_name]
		if not check_attribute_threshold(attr_name, required_val):
			return false

	# 2. 根据任务类型检查特殊条件
	match quest_data.type:
		QuestData.QuestType.MAIN:
			# 2.1 主线任务的特殊限制：检查截止日期
			if time_manager.current_day > quest_data.deadline_day:
				# 主线任务失败：触发失败结局或惩罚
				handle_quest_failure(quest_data, "deadline_missed")
				return false
			# 主线逻辑：可能需要检查前置幕是否已完成 (例如：Act 1 必须完成后才能开始 Act 2 的任务)
			if not is_previous_act_completed(quest_data.act):
				return false
		
		QuestData.QuestType.DATE:
			# 2.2 约会任务的特殊限制：检查时间槽位是否可用
			# 注意：使用 autoload 实例 time_manager 而不是类名 TimeManager
			# 假设 time_manager 有 is_time_slot_available 方法，如果没有需要自行实现
			if time_manager.has_method("is_time_slot_available"):
				if not time_manager.is_time_slot_available(quest_data.required_time_slot):
					return false
			
			# 检查约会地点是否对角色开放
			if not check_location_affinity(quest_data.required_character_id, quest_data.required_location_id):
				return false
				
		QuestData.QuestType.AFFECTION:
			# 2.3 好感任务的特殊限制：检查好感度是否达到门槛
			# 遍历 required_affection 字典 { char_id: level }
			for char_id in quest_data.required_affection:
				var min_level = quest_data.required_affection[char_id]
				if not check_affection_threshold(char_id, min_level):
					return false
		
		# BRANCH 支线任务通常只受基础条件限制，无需额外处理。
		_:
			pass

	return true

# --- 辅助检查函数 ---

func check_attribute_threshold(attribute_name: String, required_value: int) -> bool:
	#修正: 使用全局 gamemanager 获取 player，而不是不存在的 PlayerManager
	var player = gamemanager.player
	
	if not player:
		push_error("Attribute check failed: Player data not found.")
		return false
		
	# 使用 get_indexed() 或 [] 访问动态属性
	# 注意：GDScript 中属性名必须拼写和大小写完全匹配
	var actual_value = player.get(attribute_name)
	
	if actual_value == null:
		push_error("Attribute check failed: Attribute '" + attribute_name + "' not found on player.")
		return false
		
	# 检定：实际值是否大于或等于所需值
	return actual_value >= required_value

func check_affection_threshold(character_id: String, required_value: int) -> bool:
	var player = gamemanager.player
	if not player: return false
	
	# 假设 player 有 get_affection 方法
	if player.has_method("get_affection"):
		return player.get_affection(character_id) >= required_value
	return false

# --- 占位/待实现逻辑 ---

func handle_quest_failure(quest_data: QuestData, reason: String):
	print("任务失败 [%s]: %s" % [quest_data.id if "id" in quest_data else "Unknown", reason])

func is_previous_act_completed(current_act: int) -> bool:
	# 简单逻辑：如果当前时间在当前幕或之后，说明前置幕完成了（基于 TimeManager 的自然流逝）
	# 这里可能需要更复杂的逻辑，比如检查特定 Event Flag
	return time_manager.current_act >= current_act

func check_location_affinity(char_id: String, location_id: String) -> bool:
	# 占位：检查角色是否愿意去某地
	# TODO: 未来对接 CharacterData 的 location_preferences
	# 目前默认所有地点都开放
	return true
