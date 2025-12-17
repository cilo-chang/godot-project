# BaseScene.gd
class_name BaseScene extends Node2D

signal scene_finished(next_scene_path, params)

# 初始化数据，由SceneManager调用
func setup(params: Dictionary):
	pass

# 场景进入时的动画
func enter_anim():
	pass

# 场景退出前的清理
func exit_anim():
	pass
