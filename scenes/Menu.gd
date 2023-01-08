extends Node2D


export(PackedScene) var main_screen

func _on_QuitButton_pressed():
    get_tree().quit()


func _on_StartButton_pressed():
    get_tree().change_scene_to(main_screen)
