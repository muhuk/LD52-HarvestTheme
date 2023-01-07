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

func calculate_worker_chances() -> Array:
    var result: Array
    match base_location_bonus:
        Constants.LB_LABOR:
            result = [0.5, 0.25, 0.25]
        Constants.LB_AI:
            result = [0.25, 0.5, 0.25]
        Constants.LB_ADMIN:
            result = [0.25, 0.25, 0.5]
    return result

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
    var worker_chances: Array = calculate_worker_chances()
    $CenterContainer/PanelContainer/VBoxContainer/GridContainer/LaborChanceDisplay.value = worker_chances[0] * 100
    $CenterContainer/PanelContainer/VBoxContainer/GridContainer/AiChanceDisplay.value = worker_chances[1] * 100
    $CenterContainer/PanelContainer/VBoxContainer/GridContainer/AdminChanceDisplay.value = worker_chances[2] * 100
    population_display.text = "%d/%d" % [population, population_cap_base]

func _on_HarvestButton_pressed():
    population -= 1
    if population <= 1:
        disable_harvesting()
    var worker_chances: Array = calculate_worker_chances()
    var worker_type: int
    var r = randf()
    if r < worker_chances[0]:
        worker_type = Constants.LB_LABOR
    elif r < worker_chances[0] + worker_chances[1]:
        worker_type = Constants.LB_AI
    else:
        worker_type = Constants.LB_ADMIN
    emit_signal("harvested", worker_type)
    call_deferred("update")
