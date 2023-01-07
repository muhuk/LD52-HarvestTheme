extends Node2D

onready var world_map: Node2D = $Background/WorldMap

var base_marker_scene: PackedScene = load("res://scenes/BaseMarker.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    self.create_bases()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass


func create_bases():
    for pos in world_map.get_children():
        var base: Node2D
        base = base_marker_scene.instance()
        print(pos.position)
        print(base.position)
        base.position = pos.position
        world_map.add_child(base)
