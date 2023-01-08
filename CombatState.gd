extends Object
class_name CombatState

var ships: Array


func setup_armies(our_ships: int, enemy_ships: int) -> void:
    ships = []
    for idx in our_ships:
        ships.append(Ship.new(false))
    for idx in enemy_ships:
        ships.append(Ship.new(true))
    ships.shuffle()


func fight_tick() -> int:
    var result: int
    var attacker: Ship = ships.pop_front()
    var defender_idx: int = -1
    for idx in ships.size():
        if ships[idx].enemy != attacker.enemy:
            defender_idx = idx
            break
    assert(0 <= defender_idx and defender_idx < ships.size())
    var defender = ships[defender_idx]
    var is_hit: bool = attacker.hit(defender)
    if not defender.is_alive():
        ships.remove(defender_idx)
    ships.push_back(attacker)
    match [attacker.enemy, is_hit]:
        [false, true]:
            result = Constants.BATTLE_WE_HIT
        [false, false]:
            result = Constants.BATTLE_WE_MISSED
        [true, true]:
            result = Constants.BATTLE_ENEMY_HIT
        [true, false]:
            result = Constants.BATTLE_ENEMY_MISSED
    return result


func battle_state() -> int:
    var our_ships: int = 0
    var enemy_ships: int = 0
    for ship in ships:
        if ship.enemy:
            enemy_ships += 1
        else:
            our_ships += 1
    assert(enemy_ships + our_ships == ships.size())
    var result: int
    if enemy_ships == 0:
        result = Constants.BATTLE_WON
    elif our_ships == 0:
        result = Constants.BATTLE_LOST
    else:
        result = Constants.BATTLE_CONTINUE
    return result


func our_ships() -> int:
    var result: int = 0
    for ship in ships:
        if not ship.enemy:
            result += 1
    return result


func enemy_ships() -> int:
    var result: int = 0
    for ship in ships:
        if ship.enemy:
            result += 1
    return result
