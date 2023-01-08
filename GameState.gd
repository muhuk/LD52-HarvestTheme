extends Node
class_name GameState

signal game_state_changed
signal game_state_workers_changed(worker_type, new_value)
signal game_state_phase_changed
signal game_state_strength_changed

var labor_available: int = Constants.STARTING_LABOR setget set_labor_available
var ai_available: int = Constants.STARTING_AI setget set_ai_available
var admin_available: int = Constants.STARTING_ADMIN setget set_admin_available

var current_phase: int = Constants.PHASE_GATHER setget set_current_phase

var ships: int = Constants.STARTING_SHIPS setget set_ships

var efficiency: float = 1.0 setget set_efficiency

func set_labor_available(new_value):
    labor_available = new_value
    emit_signal("game_state_changed")
    emit_signal("game_state_workers_changed", Constants.LB_LABOR, new_value)

func set_ai_available(new_value):
    ai_available = new_value
    emit_signal("game_state_changed")
    emit_signal("game_state_workers_changed", Constants.LB_AI, new_value)

func set_admin_available(new_value):
    admin_available = new_value
    emit_signal("game_state_changed")
    emit_signal("game_state_workers_changed", Constants.LB_ADMIN, new_value)

func set_current_phase(new_value):
    current_phase = new_value
    emit_signal("game_state_changed")
    emit_signal("game_state_phase_changed")

func set_ships(new_value):
    ships = new_value
    emit_signal("game_state_changed")
    emit_signal("game_state_strength_changed")

func set_efficiency(new_value):
    efficiency = new_value
    emit_signal("game_state_changed")
    emit_signal("game_state_strength_changed")

