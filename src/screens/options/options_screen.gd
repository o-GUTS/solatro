class_name OptionsScreen
extends Control


@onready var back_btn: SoundButton = %backBtn
@onready var master_slider: HSlider = %masterSlider

@onready var bus_idx: int = AudioServer.get_bus_index("Master")


func _ready() -> void:
    master_slider.value = AudioServer.get_bus_volume_db(bus_idx)


func _on_back_btn_pressed() -> void:
    var screen_man: ScreenTransitionManager = get_tree().get_first_node_in_group("screen_transition_man")
    screen_man.transtition_to(screen_man.Screens.title)


func _on_master_slider_value_changed(value: float) -> void:
    AudioServer.set_bus_volume_db(bus_idx, value)
