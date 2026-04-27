class_name BaseCard
extends Control


@onready var texture_pivot: Control = %texturePivot
@onready var texture: Sprite2D = %texture

signal gui_input_fired(card: BaseCard,event: InputEvent)

const max_angle_rad := Vector2(
    deg_to_rad(10), deg_to_rad(10)
)

var tween_rot: Tween = null
var tween_scale: Tween = null

var following_mouse: bool = false
var value: String = ""


func _ready() -> void:
    texture.material = texture.material.duplicate()


func setup(new_value: String) -> void:
    value = new_value
    name = new_value

    var suit: String = new_value[-1]

    const textures_folder_path: String = "res://assets/Hand Drawn Cards/"
    var texture_path: String = "%s/%s/%s%s.png" % [
        textures_folder_path, Definitions.full_suit_names.get(suit),
        new_value.substr(0, new_value.length() - 1), suit
    ]

    var image := load(texture_path)
    texture.texture = image


func select() -> void:
    texture.offset.y = -150.0


func deselect() -> void:
    texture.offset.y = 0


func _on_gui_input(event: InputEvent) -> void:
    gui_input_fired.emit(self, event)

    if following_mouse: return
    if not event is InputEventMouseMotion: return

    var mouse_pos: Vector2 = get_local_mouse_position()

    var lerp_value := Vector2(
        remap(mouse_pos.x, 0.0, size.x, 0, 1),
        remap(mouse_pos.y, 0.0, size.y, 0, 1)
    )

    var new_rot := Vector2(
        rad_to_deg(lerp_angle(max_angle_rad.x, -max_angle_rad.x, lerp_value.y)),
        rad_to_deg(lerp_angle(-max_angle_rad.y, max_angle_rad.y, lerp_value.x))
    )

    @warning_ignore("unsafe_method_access")
    texture.material.set_shader_parameter("x_rot", new_rot.x)
    @warning_ignore("unsafe_method_access")
    texture.material.set_shader_parameter("y_rot", new_rot.y)


func _on_mouse_entered() -> void:
    if tween_scale and tween_scale.is_running():
        tween_scale.kill()

    tween_scale = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel(true)
    tween_scale.tween_property(texture_pivot, "scale", Vector2(1.2, 1.2), 0.5)

    z_index = 10


func _on_mouse_exited() -> void:
    if tween_rot and tween_rot.is_running():
        tween_rot.kill()

    tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
    tween_rot.tween_property(texture.material, "shader_parameter/x_rot", 0.0, 0.5)
    tween_rot.tween_property(texture.material, "shader_parameter/y_rot", 0.0, 0.5)

    if tween_scale and tween_scale.is_running():
        tween_scale.kill()

    tween_scale = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel(true)
    tween_scale.tween_property(texture_pivot, "scale", Vector2.ONE, 0.55)

    z_index = 0
