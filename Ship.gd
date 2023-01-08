extends Object
class_name Ship

var enemy: bool

var hp: int
var hit_chance: float
var damage: int


func _init(enemy_: bool):
    enemy = enemy_
    hp = Constants.SHIP_HP
    hit_chance = Constants.SHIP_HIT_CHANCE
    damage = Constants.SHIP_DAMAGE

func is_alive() -> bool:
    return hp > 0

func get_damaged(damage: int):
    hp = max(0, hp - damage)

func hit(other_ship: Ship) -> bool:
    assert(enemy != other_ship.enemy)
    if randf() <= hit_chance:
        other_ship.get_damaged(damage)
        return true
    else:
        return false
