class_name SoundButton
extends Button


@export var click_sound: AudioStream = null
@export var hover_sound: AudioStream = null
@export_range(-80, 24) var click_volume: float
@export_range(-80, 24) var hover_volume: float

@onready var click_stream: AudioStreamPlayer = %clickStream
@onready var hover_stream: AudioStreamPlayer = %hoverStream


func _ready() -> void:
  click_stream.volume_db = click_volume
  click_stream.stream = click_sound

  hover_stream.stream = hover_sound
  hover_stream.volume_db = hover_volume


func _on_button_down() -> void:
  if click_sound != null:
    click_stream.play()


func _on_mouse_entered() -> void:
  if hover_sound != null:
    hover_stream.play()
