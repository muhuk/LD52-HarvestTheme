extends Node2D

onready var base_name: Label = $CenterContainer/PanelContainer/VBoxContainer/BaseName
onready var population_display: Label = $CenterContainer/PanelContainer/VBoxContainer/GridContainer/PopulationDisplay

var base_location_bonus: int
var population: int = 1
var population_cap: int

func _ready():
    base_name.text = self.name
    population_display.text = str(self.population) + "/" + str(self.population_cap)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func init(base_location_bonus:int, population_cap: int):
    self.base_location_bonus = base_location_bonus
    self.population_cap = population_cap
