# res://logic/GiftCalculator.gd
class_name GiftCalculator

# 定义配置表 (根据补充设定2)
# 结构：{ Rarity: { "base": int, "like_bonus": int, "dislike_penalty": int } }
const CALCULATOR_CONFIG = {
	CardData.CardRarity.COMMON:     { "base": 3,  "like_bonus": 3,  "like_penalty": 3 },
	CardData.CardRarity.UNCOMMON:      { "base": 6,  "like_bonus": 4,  "like_penalty": 3 },
	CardData.CardRarity.EPIC:      { "base": 10, "like_bonus": 5,  "like_penalty": 2 },
	CardData.CardRarity.LEGENDARY: { "base": 20, "like_bonus": 10, "like_penalty": 0 } # 异彩不减分
}

# 计算最终好感度
static func calculate_affection(gift: GiftItemData, npc: CharacterData) -> int:
	# 1. 获取该品级的配置参数
	var config = CALCULATOR_CONFIG.get(gift.rarity)
	if not config:
		push_error("未定义的礼物稀有度配置！")
		return 0
		
	var final_score = config.base
	
	# 2. 遍历标签进行加减分
	for tag in gift.gift_tags:
		# 命中喜好标签
		if tag in npc.liked_tags:
			final_score += config.like_bonus
			print("命中喜好标签 [%s]: +%d" % [tag, config.like_bonus])
			
		# 命中厌恶标签
		elif tag in npc.disliked_tags:
			final_score -= config.like_penalty
			print("命中厌恶标签 [%s]: -%d" % [tag, config.like_penalty])
	
	
	return max(0, final_score)
