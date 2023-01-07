extends Node
class_name GameState

signal game_state_changed
signal game_state_workers_changed(worker_type, new_value)
signal game_state_phase_changed
signal game_state_strength_changed

var labor_available: int = 0 setget set_labor_available
var ai_available: int = 0 setget set_ai_available
var admin_available: int = 0 setget set_admin_available

var current_phase: int = Constants.PHASE_GATHER

var ships: int = 0

func set_labor_available(new_value):
    labor_available = new_value
    emit_signal("game_state_changed")
    emit_signal("game_state_workers_changed", Constants.LB_LABOR, new_value)

func set_ai_available(new_value):
    labor_available = new_value
    emit_signal("game_state_changed")
    emit_signal("game_state_workers_changed", Constants.LB_AI, new_value)

func set_admin_available(new_value):
    labor_available = new_value
    emit_signal("game_state_changed")
    emit_signal("game_state_workers_changed", Constants.LB_ADMIN, new_value)
