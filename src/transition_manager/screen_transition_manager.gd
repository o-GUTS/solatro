class_name ScreenTransitionManager
extends Node


enum Screens {
    title, options, credits, game, shop
}

const title_screen_path: String = "res://src/screens/title/title_screen.tscn"
const options_screen_path: String = "res://src/screens/options/options_screen.tscn"
const credits_screen_path: String = "res://src/screens/credits/credits_screen.tscn"
const game_screen_path: String = "res://src/screens/game/game_screen.tscn"
const shop_screen_path: String = "res://src/screens/shop/shop_screen.tscn"

@onready var fade_rect: ColorRect = %fade_rect
@onready var screen_parent: Node = %screen_parent
@onready var anim: AnimationPlayer = %anim


func transtition_to(screen: Screens) -> void:
    anim.play(&"fade_in")
    await anim.animation_finished

    for node in screen_parent.get_children():
        node.queue_free()

    match screen:
        Screens.title:
            var screen_scene: PackedScene = load(title_screen_path)
            screen_parent.add_child(screen_scene.instantiate())

        Screens.options:
            var screen_scene: PackedScene = load(options_screen_path)
            screen_parent.add_child(screen_scene.instantiate())

        Screens.credits:
            var screen_scene: PackedScene = load(credits_screen_path)
            screen_parent.add_child(screen_scene.instantiate())

        Screens.game:
            var screen_scene: PackedScene = load(game_screen_path)
            screen_parent.add_child(screen_scene.instantiate())

        Screens.shop:
            var screen_scene: PackedScene = load(shop_screen_path)
            screen_parent.add_child(screen_scene.instantiate())

    anim.play(&"fade_out")
    await anim.animation_finished

    anim.play(&"RESET")
