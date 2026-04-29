class_name ScreenTransitionManager
extends Node


enum Screens {
    title, options, credits, game, shop
}

enum Musics {
    menu, game, shop
}

const title_screen_path: String = "res://src/screens/title/title_screen.tscn"
const options_screen_path: String = "res://src/screens/options/options_screen.tscn"
const credits_screen_path: String = "res://src/screens/credits/credits_screen.tscn"
const game_screen_path: String = "res://src/screens/game/game_screen.tscn"
const shop_screen_path: String = "res://src/screens/shop/shop_screen.tscn"

const menu_music_path: String = "res://assets/musics/menu_music.ogg"
const game_music_path: String = "res://assets/musics/game_music.ogg"
const shop_music_path: String = "res://assets/musics/shop_music.ogg"

var current_music := Musics.menu

@onready var fade_rect: ColorRect = %fade_rect
@onready var screen_parent: Node = %screen_parent
@onready var anim: AnimationPlayer = %anim
@onready var bg_music: AudioStreamPlayer = %bg_music


func transtition_to(screen: Screens) -> void:
    anim.play(&"fade_in")
    await anim.animation_finished

    for node in screen_parent.get_children():
        node.queue_free()

    match screen:
        Screens.title:
            var screen_scene: PackedScene = load(title_screen_path)
            screen_parent.add_child(screen_scene.instantiate())
            transition_music(Musics.menu)

        Screens.options:
            var screen_scene: PackedScene = load(options_screen_path)
            screen_parent.add_child(screen_scene.instantiate())

        Screens.credits:
            var screen_scene: PackedScene = load(credits_screen_path)
            screen_parent.add_child(screen_scene.instantiate())

        Screens.game:
            var screen_scene: PackedScene = load(game_screen_path)
            screen_parent.add_child(screen_scene.instantiate())
            transition_music(Musics.game)

        Screens.shop:
            var screen_scene: PackedScene = load(shop_screen_path)
            screen_parent.add_child(screen_scene.instantiate())
            transition_music(Musics.shop)

    anim.play(&"fade_out")
    await anim.animation_finished

    anim.play(&"RESET")


func transition_music(music: Musics) -> void:
    if current_music == music: return

    var volume_tween: Tween = create_tween()
    volume_tween.tween_property(bg_music, ^"volume_db", -50, 0.5)
    volume_tween.tween_property(bg_music, ^"volume_db", -5, 0.5)

    await volume_tween.step_finished

    bg_music.stop()

    match music:
        Musics.menu:
            bg_music.stream = load(menu_music_path)
        Musics.game:
            bg_music.stream = load(game_music_path)
        Musics.shop:
            bg_music.stream = load(shop_music_path)

    bg_music.play()
    current_music = music
