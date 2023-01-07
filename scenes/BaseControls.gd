extends Node2D

signal harvested(worker_type)

onready var base_name: Label = $CenterContainer/PanelContainer/VBoxContainer/BaseName
onready var population_display: Label = $CenterContainer/PanelContainer/VBoxContainer/GridContainer/PopulationDisplay

onready var harvest_button: Button = $CenterContainer/PanelContainer/VBoxContainer/HarvestButton

var base_location_bonus: int
var population: int = 1
var population_cap_base: int

func _ready():
    base_name.text = self.name
    disable_harvesting()
    call_deferred("update")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func enable_harvesting():
    if population > 1:
        harvest_button.disabled = false

func disable_harvesting():
    harvest_button.disabled = true

func init(base_location_bonus_: int, population_cap: int):
    base_location_bonus = base_location_bonus_
    population_cap_base = population_cap

func update():
    population_display.text = "%d/%d" % [population, population_cap_base]

func _on_HarvestButton_pressed():
    population -= 1
    if population <= 1:
        disable_harvesting()
    emit_signal("harvested", Constants.LB_LABOR)
    call_deferred("update")
