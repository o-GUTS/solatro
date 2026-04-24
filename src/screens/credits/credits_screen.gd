class_name CreditsScreen
extends Control


@onready var go_back_btn: Button = %go_back_btn


func _on_go_back_btn_pressed() -> void:
    var screen_man: ScreenTransitionManager = get_tree().get_first_node_in_group("screen_transition_man")
    screen_man.transtition_to(screen_man.Screens.title)
