class_name CardContainer
extends HBoxContainer


signal selection_changed

enum SortType {
    by_suit, by_rank
}

var current_sort_type := SortType.by_suit:
    set(value):
        current_sort_type = value
        sort_cards()

var current_hand: Array[String] = []
var selected_cards: Array[String] = []
var draw_pile: Array[String] = []

@onready var base_card_scene: PackedScene = load("res://src/base_card.tscn")


func _ready() -> void:
    reset()


func reset() -> void:
    for child: BaseCard in get_children():
        child.queue_free()

    current_hand.clear()
    draw_pile.clear()

    for suit: String in Definitions.card_suits:
        for number: String in Definitions.card_numbers:
            draw_pile.append("%s%s" % [number, suit])

    draw_pile.shuffle()
    draw_random_cards(GlobalState.hand_size)


func draw_card(card_value: String) -> BaseCard:
    var new_card: BaseCard = base_card_scene.instantiate()
    add_child(new_card)

    new_card.setup(card_value)
    new_card.gui_input_fired.connect(_on_card_gui_input)
    current_hand.append(card_value)

    sort_cards()

    return new_card


func draw_random_cards(quant: int = 1) -> void:
    for x in range(quant):
        if draw_pile.size() <= 0:
            return

        var card_value: String = draw_pile.pick_random()

        var new_card: BaseCard = draw_card(card_value)
        assert(new_card != null, "new_card can't be null")
        draw_pile.remove_at(draw_pile.find(card_value))


func discard_card(card_value: String) -> void:
    for child: BaseCard in get_children():
        if child.value == card_value:
            current_hand.remove_at(current_hand.find(card_value))
            child.queue_free()
            sort_cards()
            return

    assert(false, "Card not found to discard: " + card_value)


func discard_selected_cards() -> void:
    if selected_cards.size() <= 0:
        return

    for card_value: String in selected_cards:
        discard_card(card_value)

    selected_cards.clear()


func has_cards_selected() -> bool:
    return selected_cards.size() > 0


func sort_cards() -> void:
    var sorted_nodes := get_children()

    if current_sort_type == SortType.by_rank:
        sorted_nodes.sort_custom(
            func(a: BaseCard, b: BaseCard) -> bool: return a.value.naturalnocasecmp_to(b.value) < 0
        )
    else:
        sorted_nodes.sort_custom(
            func(a: BaseCard, b: BaseCard) -> bool: return str(a.value)[-1].naturalnocasecmp_to(str(b.value)[-1]) < 0
        )

    for node in get_children():
        remove_child(node)
    for node: BaseCard in sorted_nodes:
        add_child(node)

    add_theme_constant_override("separation", int(remap(current_hand.size(), 0.0, GlobalState.hand_size, 0.0, -50.0)))


func _on_card_gui_input(card: BaseCard, event: InputEvent) -> void:
    if event.is_action_pressed("MOUSE_LEFT"):
        if selected_cards.has(card.value):
            card.deselect()
            selected_cards.remove_at(selected_cards.find(card.value))

        elif selected_cards.size() < Definitions.max_selected_cards:
            card.select()
            selected_cards.append(card.value)

        selection_changed.emit()
