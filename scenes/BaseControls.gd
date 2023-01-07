extends Node2D

onready var base_name: Label = $CenterContainer/PanelContainer/VBoxContainer/BaseName
onready var population_display: Label = $CenterContainer/PanelContainer/VBoxContainer/GridContainer/PopulationDisplay

var base_location_bonus: int
var population: int = 1
var population_cap_base: int

func _ready():
    base_name.text = self.name
    call_deferred("update")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass


func init(base_location_bonus_: int, population_cap: int):
    base_location_bonus = base_location_bonus_
    population_cap_base = population_cap

func update():
    population_display.text = "%d/%d" % [population, population_cap_base]
