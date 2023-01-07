extends Node2D

signal harvested(worker_type)

onready var base_name: Label = $CenterContainer/PanelContainer/VBoxContainer/BaseName
onready var population_display: Label = $CenterContainer/PanelContainer/VBoxContainer/GridContainer/PopulationDisplay

onready var harvest_button: Button = $CenterContainer/PanelContainer/VBoxContainer/HarvestButton

var base_location_bonus: int
var population: int
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
    population = population_cap
    population_cap_base = population_cap

func update():
    match base_location_bonus:
        Constants.LB_LABOR:
            $CenterContainer/PanelContainer/VBoxContainer/GridContainer/LaborChanceDisplay.value = 40
            $CenterContainer/PanelContainer/VBoxContainer/GridContainer/AiChanceDisplay.value = 30
            $CenterContainer/PanelContainer/VBoxContainer/GridContainer/AdminChanceDisplay.value = 30
        Constants.LB_AI:
            $CenterContainer/PanelContainer/VBoxContainer/GridContainer/LaborChanceDisplay.value = 30
            $CenterContainer/PanelContainer/VBoxContainer/GridContainer/AiChanceDisplay.value = 40
            $CenterContainer/PanelContainer/VBoxContainer/GridContainer/AdminChanceDisplay.value = 30
        Constants.LB_ADMIN:
            $CenterContainer/PanelContainer/VBoxContainer/GridContainer/LaborChanceDisplay.value = 30
            $CenterContainer/PanelContainer/VBoxContainer/GridContainer/AiChanceDisplay.value = 30
            $CenterContainer/PanelContainer/VBoxContainer/GridContainer/AdminChanceDisplay.value = 40
    population_display.text = "%d/%d" % [population, population_cap_base]

func _on_HarvestButton_pressed():
    population -= 1
    if population <= 1:
        disable_harvesting()
    emit_signal("harvested", Constants.LB_LABOR)
    call_deferred("update")
