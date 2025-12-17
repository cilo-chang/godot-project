# res://managers/GiftManager.gd
extends Node

# 用于存储待发送的回礼队列
# 结构： [ { "npc_name": String, "item_id": String, "deliver_date": int } ]
var pending_return_gifts: Array = []

func _ready():
	# 监听时间变化，用于发放回礼
	time_manager.day_advanced.connect(_on_day_advanced)

# --- 主动送礼函数 ---
func process_gift_giving(player: PlayerData, npc: CharacterData, gift: GiftItemData):
	# 1. 计算并应用好感度
	var affection_gain = GiftCalculator.calculate_affection(gift, npc)
	player.change_affection(npc.id, affection_gain)
	print("送礼结束，好感度增加: ", affection_gain)
	
	# 2. 消耗物品
	gamemanager.remove_item(gift.id, 1)
	
	# 3. 记录送礼历史（防止重复送同一种，参考上一轮讨论）
	player.record_gift_history(npc.id, gift.id)
	
	# 4. 处理回礼逻辑 (补充设定3)
	_handle_return_gift_logic(player, npc, gift)

# --- 回礼判定逻辑 ---
func _handle_return_gift_logic(player: PlayerData, npc: CharacterData, gift: GiftItemData):
	# 判定条件：若所赠送角色不处于“社交上位”
	# 假设 CharacterData 里有 social_position 属性 ("HIGH", "EQUAL", "LOW")
	# 如果 NPC 是 HIGH (上位)，则不回礼
	if npc.social_position == "HIGH":
		print(npc.name + " 处于社交上位，不屑于回礼。")
		return
		
	# 获取对应的回礼物品ID
	var return_item_id = npc.return_gift_table.get(gift.rarity)
	
	if return_item_id:
		# 加入到待发送队列，设定为“明天”送达
		var delivery_info = {
			"npc_name": npc.name,
			"item_id": return_item_id,
			"deliver_date": time_manager.current_day + 1 # 明天
		}
		pending_return_gifts.append(delivery_info)
		print("已触发回礼机制，将于明天收到 [%s]" % return_item_id)

# --- 每日结算：发放回礼 ---
func _on_day_advanced(new_day: int):
	# 倒序遍历以便安全删除
	for i in range(pending_return_gifts.size() - 1, -1, -1):
		var gift_info = pending_return_gifts[i]
		
		if gift_info["deliver_date"] <= new_day:
			# 发放奖励
			gamemanager.add_item(gift_info["item_id"], 1)
			
			# 可以在这里弹出一个UI提示：“早上起来，你在信箱里发现了XX寄来的回礼！”
			print("收到来自 %s 的回礼！" % gift_info["npc_name"])
			
			# 从队列移除
			pending_return_gifts.remove_at(i)
