extends Node2D

onready var camp_marker_positions: Node2D = $Background/CampMarkerPositions
onready var camp_controls_positions: Node2D = $Background/CampControlsPositions
onready var world_map: Node2D = $Background/WorldMap

onready var base_info_container: Control = $HUD/BaseInfo
onready var build_menu_container: Control = $HUD/BuildMenu
onready var combat_overlay: Control = $HUD/CombatOverlay
onready var game_over_overlay: Node2D = $GameOverOverlay/GameOverOverlay

onready var end_turn_button: Button = $HUD/HudContainer/MarginContainer/EndTurnButton
onready var build_ship_button: Button = $HUD/BuildMenu/CenterContainer/PanelContainer/VBoxContainer/BuildShipButton
onready var ship_cost_info: Label = $HUD/BuildMenu/CenterContainer/PanelContainer/VBoxContainer/ShipCostInfo

export var gather_color_inactive: Color
export var gather_color_active: Color
export var execute_color_inactive: Color
export var execute_color_active: Color
export var defend_color_inactive: Color
export var defend_color_active: Color

var menu_screen: String = "res://scenes/Menu.tscn"

var base_marker_scene: PackedScene = load("res://scenes/BaseMarker.tscn")
var base_controls_scene: PackedScene = load("res://scenes/BaseControls.tscn")

var turn: int = 0
var game_state: GameState
var phase_phase: float = 0.0
var phase_phase_speed: float = 2.0
var combat_state: CombatState
var combat_countdown: float = 0.0


func _ready():
    randomize()
    setup_game_state()
    create_bases()
    ship_cost_info.text = "Ship cost %d labor, %d AI, %d admin." % Constants.SHIP_COST
    call_deferred("on_workers_changed", Constants.LB_LABOR, game_state.labor_available)
    call_deferred("on_workers_changed", Constants.LB_AI, game_state.ai_available)
    call_deferred("on_workers_changed", Constants.LB_ADMIN, game_state.admin_available)
    call_deferred("on_phase_changed")
    call_deferred("on_strength_changed")


func _process(delta):
    pulse_phase(delta)
    if combat_state != null:
        process_combat(delta)


func process_combat(delta: float) -> void:
    combat_countdown -= delta
    if combat_countdown < 0.0:
        match combat_state.battle_state():
            Constants.BATTLE_CONTINUE:
                var tick_result: int = combat_state.fight_tick()
                var msg: String
                match tick_result:
                    Constants.BATTLE_WE_HIT:
                        msg = "We hit!"
                        $ExplosionSound1.play()
                    Constants.BATTLE_WE_MISSED:
                        msg = "We missed."
                        $ShootSound1.play()
                    Constants.BATTLE_ENEMY_HIT:
                        msg = "Enemy hit!"
                        $ExplosionSound2.play()
                    Constants.BATTLE_ENEMY_MISSED:
                        msg = "Enemy missed."
                        $ShootSound2.play()
                $HUD/CombatOverlay/CenterContainer/PanelContainer/VBoxContainer/CombatLog.text = msg
                $HUD/CombatOverlay/CenterContainer/PanelContainer/VBoxContainer/GridContainer/OurShipsDisplay.text = str(combat_state.our_ships())
                $HUD/CombatOverlay/CenterContainer/PanelContainer/VBoxContainer/GridContainer/EnemyShipsDisplay.text = str(combat_state.enemy_ships())
            Constants.BATTLE_LOST:
                $HUD/CombatOverlay/CenterContainer/PanelContainer/VBoxContainer/CombatLog.text = "WE LOST"
                show_game_over_overlay()
            Constants.BATTLE_WON:
                game_state.ships = combat_state.our_ships()
                combat_state.free()
                combat_state = null
                turn += 1
                $HUD/CombatOverlay/CenterContainer/PanelContainer/VBoxContainer/CombatLog.text = "WE WON"
                $Music.play()
                unfreeze_end_turn_button()
        combat_countdown += 0.25


func show_game_over_overlay() -> void:
    yield(get_tree().create_timer(0.2), "timeout")
    game_over_overlay.show()
    var tween: SceneTreeTween = get_tree().create_tween()
    tween.set_loops()
    tween.tween_property(game_over_overlay, "scale", Vector2(1.2, 1.2), 0.55).set_trans(Tween.TRANS_SINE)
    tween.chain().tween_property(game_over_overlay, "scale", Vector2(1.0, 1.0), 0.35).set_trans(Tween.TRANS_SINE)
    yield(get_tree().create_timer(1.5), "timeout")
    get_tree().change_scene(menu_screen)


func can_build_ship():
    return game_state.labor_available >= Constants.SHIP_COST[0] and \
        game_state.ai_available >= Constants.SHIP_COST[1] and \
        game_state.admin_available >= Constants.SHIP_COST[2]


func create_bases():
    for pos in camp_marker_positions.get_children():
        var base_marker: Node2D
        base_marker = base_marker_scene.instance()
        base_marker.name = pos.name
        base_marker.position = pos.position
        world_map.add_child(base_marker)
    var location_bonus_bag: Array = [
        Constants.LB_LABOR,
        Constants.LB_LABOR,
        Constants.LB_LABOR,
        Constants.LB_LABOR,
        Constants.LB_AI,
        Constants.LB_ADMIN,
       ]
    location_bonus_bag.shuffle()
    var population_cap_bag: Array = [3, 3, 3, 4, 4, 5]
    population_cap_bag.shuffle()
    for idx in camp_controls_positions.get_child_count():
        var pos: Node2D = camp_controls_positions.get_child(idx)
        var base_controls: Node2D
        base_controls = base_controls_scene.instance()
        base_controls.name = pos.name
        base_controls.global_position = pos.global_position
        base_controls.init(location_bonus_bag[idx], population_cap_bag[idx])
        base_controls.connect("harvested", self, "on_harvest")
        base_info_container.add_child(base_controls)


func pulse_phase(delta: float):
    phase_phase += delta * phase_phase_speed
    var lerp_amount: float = fmod(phase_phase, 2.0) - 1.0
    if lerp_amount < 0.0:
        lerp_amount = abs(lerp_amount)
    lerp_amount = lerp_amount / 2.0 + 0.5
    match game_state.current_phase:
        Constants.PHASE_GATHER:
            var color: Color = gather_color_inactive.linear_interpolate(gather_color_active, lerp_amount)
            $HUD/HudContainer/PhasePanel/PanelContainer/VBoxContainer/PhaseGather.self_modulate = color
        Constants.PHASE_EXECUTE:
            var color: Color = execute_color_inactive.linear_interpolate(execute_color_active, lerp_amount)
            $HUD/HudContainer/PhasePanel/PanelContainer/VBoxContainer/PhaseExecute.self_modulate = color
        Constants.PHASE_DEFEND:
            var color: Color = defend_color_inactive.linear_interpolate(defend_color_active, lerp_amount)
            $HUD/HudContainer/PhasePanel/PanelContainer/VBoxContainer/PhaseDefend.self_modulate = color


func setup_game_state():
    game_state = GameState.new()
    game_state.name = "GameState"
    add_child(game_state)
    game_state.connect("game_state_strength_changed", self, "on_strength_changed")
    game_state.connect("game_state_phase_changed", self, "on_phase_changed")
    game_state.connect("game_state_workers_changed", self, "on_workers_changed")


func on_harvest(worker_type: int):
    match worker_type:
        Constants.LB_LABOR:
            game_state.labor_available += 1
        Constants.LB_AI:
            game_state.ai_available += 1
        Constants.LB_ADMIN:
            game_state.admin_available += 1


func on_phase_changed():
    match game_state.current_phase:
        Constants.PHASE_GATHER:
            for base in base_info_container.get_children():
                base.grow_population()
                base.enable_harvesting()
            $HUD/HudContainer/PhasePanel/PanelContainer/VBoxContainer/PhaseGather.self_modulate = gather_color_active
            $HUD/HudContainer/PhasePanel/PanelContainer/VBoxContainer/PhaseExecute.self_modulate = execute_color_inactive
            $HUD/HudContainer/PhasePanel/PanelContainer/VBoxContainer/PhaseDefend.self_modulate = defend_color_inactive
            end_turn_button.disabled = true
            unfreeze_end_turn_button()
            base_info_container.visible = true
            build_menu_container.visible = false
            combat_overlay.visible = false
            combat_state = null
            $HUD/HudContainer/StrengthPanel/PanelContainer/GridContainer/EnemyDisplay.text = str(Constants.ENEMY_SHIPS[turn])
        Constants.PHASE_EXECUTE:
            for base in base_info_container.get_children():
                base.disable_harvesting()
            $HUD/HudContainer/PhasePanel/PanelContainer/VBoxContainer/PhaseGather.self_modulate = gather_color_inactive
            $HUD/HudContainer/PhasePanel/PanelContainer/VBoxContainer/PhaseExecute.self_modulate = execute_color_active
            $HUD/HudContainer/PhasePanel/PanelContainer/VBoxContainer/PhaseDefend.self_modulate = defend_color_inactive
            end_turn_button.disabled = true
            unfreeze_end_turn_button()
            base_info_container.visible = false
            build_menu_container.visible = true
            combat_overlay.visible = false
            combat_state = null
            build_ship_button.disabled = not can_build_ship()
        Constants.PHASE_DEFEND:
            $Music.stop()
            for base in base_info_container.get_children():
                base.disable_harvesting()
            $HUD/HudContainer/PhasePanel/PanelContainer/VBoxContainer/PhaseGather.self_modulate = gather_color_inactive
            $HUD/HudContainer/PhasePanel/PanelContainer/VBoxContainer/PhaseExecute.self_modulate = execute_color_inactive
            $HUD/HudContainer/PhasePanel/PanelContainer/VBoxContainer/PhaseDefend.self_modulate = defend_color_active
            end_turn_button.disabled = true
            base_info_container.visible = false
            build_menu_container.visible = false
            combat_overlay.visible = true
            combat_state = CombatState.new()
            combat_state.setup_armies(game_state.ships, Constants.ENEMY_SHIPS[turn])
            $HUD/CombatOverlay/CenterContainer/PanelContainer/VBoxContainer/CombatLog.text = "Combat beginning."
            $HUD/CombatOverlay/CenterContainer/PanelContainer/VBoxContainer/GridContainer/OurShipsDisplay.text = str(combat_state.our_ships())
            $HUD/CombatOverlay/CenterContainer/PanelContainer/VBoxContainer/GridContainer/EnemyShipsDisplay.text = str(combat_state.enemy_ships())


func on_strength_changed():
    $HUD/HudContainer/StrengthPanel/PanelContainer/GridContainer/ShipsDisplay.text = str(game_state.ships)


func on_workers_changed(worker_type: int, new_value: int):
    match worker_type:
        Constants.LB_LABOR:
            $HUD/HudContainer/WorkersPanel/PanelContainer/GridContainer/LaborDisplay.text = str(new_value)
        Constants.LB_AI:
            $HUD/HudContainer/WorkersPanel/PanelContainer/GridContainer/AiDisplay.text = str(new_value)
        Constants.LB_ADMIN:
            $HUD/HudContainer/WorkersPanel/PanelContainer/GridContainer/AdminDisplay.text = str(new_value)


func _on_EndTurnButton_pressed():
    match game_state.current_phase:
        Constants.PHASE_GATHER:
            game_state.current_phase = Constants.PHASE_EXECUTE
        Constants.PHASE_EXECUTE:
            game_state.current_phase = Constants.PHASE_DEFEND
        Constants.PHASE_DEFEND:
            game_state.current_phase = Constants.PHASE_GATHER


func unfreeze_end_turn_button():
    yield(get_tree().create_timer(1.0), "timeout")
    end_turn_button.disabled = false


func _on_BuildShipButton_pressed():
    if can_build_ship():
        $BeepSound.play()
        game_state.labor_available -= Constants.SHIP_COST[0]
        game_state.ai_available -= Constants.SHIP_COST[1]
        game_state.admin_available -= Constants.SHIP_COST[2]
        game_state.ships += 1
    build_ship_button.disabled = not can_build_ship()
