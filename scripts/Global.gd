extends Node

var Player: CharacterBody2D
var WindowManager: CanvasLayer

func get_component(_node: Node, comp_name: String):
	return _node.get_node_or_null(comp_name)
