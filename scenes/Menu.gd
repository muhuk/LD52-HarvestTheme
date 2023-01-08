extends Node2D


export(PackedScene) var main_screen

func _ready():
    $Music.play()


func _on_QuitButton_pressed():
    $BeepSound.play()
    yield(get_tree().create_timer(0.2), "timeout")
    get_tree().quit()


func _on_StartButton_pressed():
    $BeepSound.play()
    yield(get_tree().create_timer(0.2), "timeout")
    get_tree().change_scene_to(main_screen)
