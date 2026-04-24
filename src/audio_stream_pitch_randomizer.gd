class_name AudioStreamPitchRandomizer
extends AudioStreamPlayer


@export var max_pitch: float = 1.0
@export var min_pitch: float = 0.9


func play_random_pitch() -> void:
  #pitch_scale = randf_range(min_pitch, max_pitch)
  pitch_scale = _Eerp(min_pitch, max_pitch, randf())
  play()
  #pitch_scale = 1.0


# Auxiliar function to remove pitch randomization bias
func _Eerp(a: float, b: float, t: float) -> float:
  return a * exp(t * log(b / a));
