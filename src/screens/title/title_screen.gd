class_name TitleScreen
extends Control


@onready var play_btn: SoundButton = %playBtn
@onready var options_btn: SoundButton = %optionsBtn
@onready var credits_btn: SoundButton = %creditsBtn


func _on_play_btn_pressed() -> void:
    var screen_man: ScreenTransitionManager = get_tree().get_first_node_in_group("screen_transition_man")
    screen_man.transtition_to(screen_man.Screens.game)


func _on_options_btn_pressed() -> void:
    var screen_man: ScreenTransitionManager = get_tree().get_first_node_in_group("screen_transition_man")
    screen_man.transtition_to(screen_man.Screens.options)


func _on_credits_btn_pressed() -> void:
    var screen_man: ScreenTransitionManager = get_tree().get_first_node_in_group("screen_transition_man")
    screen_man.transtition_to(screen_man.Screens.credits)
