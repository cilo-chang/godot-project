extends Node

var current_scene = null

# 切换场景的通用函数
func change_scene(scene_path: String, params: Dictionary = {}):
	# 1. 播放转场黑屏动画
	# 2. current_scene.queue_free() (卸载当前场景)
	# 3. 实例化新场景并 add_child 到 Main 节点
	# 4. 调用新场景的 setup(params) 方法传递数据
	pass
