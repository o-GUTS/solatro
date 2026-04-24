@tool
class_name BackgroundContainer
extends PanelContainer


@export var bg_color := Color.WHITE
@export var shadow_color := Color.BLACK
@export var corner_radius := 10
@export_tool_button("UPDATE", "Reload") var update: Callable = update_styles


func _ready() -> void:
  update_styles()


func update_styles() -> void:
  var panel_style := StyleBoxFlat.new()

  panel_style.bg_color = bg_color
  panel_style.border_color = shadow_color
  panel_style.set_corner_radius_all(corner_radius)
  #panel_style.draw_center = true
  panel_style.border_width_bottom = 1
  panel_style.anti_aliasing = false

  add_theme_stylebox_override("panel", panel_style)
