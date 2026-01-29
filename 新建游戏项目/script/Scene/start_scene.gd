extends Control

# 预留场景路径，之后我们会用到
const EXPERIENCE_SCENE = "res://scenes/experience_selection.tscn"

func _ready():
	# 初始化版本号显示
	$version.text = "3999年9月1日 | Demo v0.1"
	
	# 逻辑检查：如果没有存档，就把“继续记录”按钮禁用掉
	# $continue.disabled = true # 暂时手动禁用，等写好存档系统再取消

# --- 按钮逻辑区域 ---

func _on_start_pressed():
	print("开启回忆：正在初始化数据...")
	# 1. 初始化基础数值
	# 注意：这些变量通常应该存在一个 Autoload 单例里，我们先用 print 模拟
	var initial_gold = randi_range(10000, 15000)
	var initial_stamina_rec = randi_range(10, 40)
	
	print("初始金钱: ", initial_gold)
	print("初始精力恢复: ", initial_stamina_rec)
	
	# 2. 跳转到经历选择系统（策划案 8.6）
	# get_tree().change_scene_to_file(EXPERIENCE_SCENE)
	# 老师，因为你还没做下一个场景，先用打印代替，不然程序会崩溃哦！

func _on_continue_pressed():
	# 读档逻辑，后续对接存档系统
	print("正在加载存档记录...")

func _on_collection_pressed():
	# 跳转到银色怀表收藏界面
	print("打开银色怀表...")

func _on_exit_pressed():
	# 退出游戏
	print("安全退出游戏。下次见，Sensei。")
	get_tree().quit()
