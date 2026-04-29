class_name OptionsScreen
extends Control


@onready var back_btn: SoundButton = %backBtn
@onready var master_slider: HSlider = %master_slider
@onready var music_slider: HSlider = %music_slider
@onready var effects_slider: HSlider = %effects_slider

@onready var master_bus_idx: int = AudioServer.get_bus_index(&"Master")
@onready var music_bus_idx: int = AudioServer.get_bus_index(&"Music")
@onready var effects_bus_idx: int = AudioServer.get_bus_index(&"Effects")


func _ready() -> void:
    master_slider.value = AudioServer.get_bus_volume_db(master_bus_idx)
    music_slider.value = AudioServer.get_bus_volume_db(music_bus_idx)
    effects_slider.value = AudioServer.get_bus_volume_db(effects_bus_idx)


func _on_back_btn_pressed() -> void:
    var screen_man: ScreenTransitionManager = get_tree().get_first_node_in_group("screen_transition_man")
    screen_man.transtition_to(screen_man.Screens.title)


func _on_master_slider_value_changed(value: float) -> void:
    AudioServer.set_bus_volume_db(master_bus_idx, value)


func _on_music_slider_value_changed(value: float) -> void:
    AudioServer.set_bus_volume_db(music_bus_idx, value)


func _on_effects_slider_value_changed(value: float) -> void:
    AudioServer.set_bus_volume_db(effects_bus_idx, value)
