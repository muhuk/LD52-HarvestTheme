extends Node2D

onready var camp_marker_positions: Node2D = $Background/CampMarkerPositions
onready var camp_controls_positions: Node2D = $Background/CampControlsPositions
onready var world_map: Node2D = $Background/WorldMap

onready var base_info_layer: CanvasLayer = $BaseInfo

var base_marker_scene: PackedScene = load("res://scenes/BaseMarker.tscn")
var base_controls_scene: PackedScene = load("res://scenes/CampControls.tscn")

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
    for pos in camp_marker_positions.get_children():
        var base_marker: Node2D
        base_marker = base_marker_scene.instance()
        base_marker.name = pos.name
        base_marker.position = pos.position
        world_map.add_child(base_marker)
    for pos in camp_controls_positions.get_children():
        var base_controls: Node2D
        base_controls = base_controls_scene.instance()
        base_controls.name = pos.name
        base_controls.position = pos.position
        base_info_layer.add_child(base_controls)
