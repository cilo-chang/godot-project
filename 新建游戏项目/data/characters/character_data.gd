@tool
class_name CharacterData
extends GameData

# --- 核心信息 ---
@export var portrait: Texture2D # 立绘
@export var base_affection: int = 0 # 初始好感度
@export var social_position: String = "neutral" # "high", "low", "neutral"（上下位关系）

# --- 剧情与战斗关联 ---
@export var affection_events: Array[Resource] = [] # 好感剧情（DialogResource，按好感度阶段排序）
@export var awakening_card_id: String = "" # 觉醒卡牌ID (ID用于在 DatabaseManager.cards 中查找)

# --- 社交：礼物偏好 (使用 ItemData 的 ID) ---
# 用于计算送礼时的好感度增益或减益。

@export var eager_skills: Array[String] = [] # +++ 热衷的生活职业技能ID (高效率/好感度增益)
@export var disliked_skills: Array[String] = [] # -- 兴趣缺缺的职业技能ID (低效率/好感度减益)
@export_group("Gifting System")
@export var liked_tags: Array[String] = [] # +++ 喜欢的礼物ID (高好感度增益)
@export var disliked_tags: Array[String] = [] # -- 不喜欢的礼物ID (好感度减益)

# 回礼配置表
# 键：礼物品级 (Rarity Enum)
# 值：回礼物品的ID (String, 指向 items 数据库)
# 对应设定：特色回礼仅根据赠送物品的品级不同而不同
@export var return_gift_table: Dictionary = {
	CardData.CardRarity.COMMON: "item_cookie_01",      # 送绿色礼物，回小饼干
	CardData.CardRarity.UNCOMMON:  "item_potion_mp_01",   # 送蓝色礼物，回魔力药水
	CardData.CardRarity.EPIC:  "item_book_history_02",# 送金色礼物，回历史书
	CardData.CardRarity.LEGENDARY: "item_rare_gem"    # 送异彩礼物，回稀有宝石
}
