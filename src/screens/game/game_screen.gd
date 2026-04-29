class_name GameScreen
extends Control


@onready var card_container: CardContainer = %cardContainer
@onready var discard_button: Button = %discardButton
@onready var play_hand_button: Button = %playHandButton
@onready var hand_label: Label = %hand_label
@onready var left_panel: CustomLeftPanel = %leftPanel
@onready var joker_indicator: BaseCard = %joker_indicator


func _ready() -> void:
    card_container.selection_changed.connect(update_hand_type_label)
    left_panel.bonus_btn_pressed.connect(_on_bonus_btn_pressed)

    joker_indicator.setup("joker")
    joker_indicator.gui_input_fired.connect(
        func(_card: BaseCard, event: InputEvent) -> void:
            if event.is_action_pressed(&"MOUSE_LEFT"):
                if GlobalState.joker_selected:
                    joker_indicator.deselect()
                    GlobalState.joker_selected = false

                elif card_container.selected_cards.size() < Definitions.max_selected_cards:
                    joker_indicator.select()
                    GlobalState.joker_selected = true

                update_hand_type_label()
    )
    card_container.joker_found.connect(
        func() -> void:
            if GlobalState.has_joker:
                joker_indicator.hide()
                GlobalState.joker_selected = false
            else:
                joker_indicator.show()

            GlobalState.has_joker = !GlobalState.has_joker
    )

    start_new_round()


func start_new_round() -> void:
    GlobalState.prepare_state_to_next_round()

    card_container.reset()
    left_panel.update_all_visuals()


func get_highest_poker_hand(card_names: Array[String]) -> PokerHand:
    if card_names.is_empty(): return null
    elif card_names.size() == 1:
        return PokerHand.new("High Card", Definitions.HandScores.high_card)

    var suits: Array[String] = []
    var ranks: Array[int] = []

    var has_pair: bool = false
    var has_two_pair: bool = false
    var has_three_of_a_kind: bool = false
    var has_straight: bool = false
    var has_flush: bool = false
    var has_full_house: bool = false
    var has_four_of_a_kind: bool = false
    var is_royal: bool = false

    for index in range(card_names.size()):
        var card_value: String = card_names[index]

        var suit: String = card_value[-1]
        var rank: int = card_value.substr(0, card_value.length() - 1).to_int()

        suits.append(suit)
        ranks.append(rank)

    ranks.sort()

    if card_names.size() == Definitions.max_selected_cards:
        has_flush = suits.all(func(elem: String) -> bool: return elem == suits[0])

        # Search royal straight
        has_straight = true
        if ranks.has(1): # Has Ace
            is_royal = true

            var ranks_copy: Array[int] = ranks.duplicate()
            ranks_copy.remove_at(0)
            ranks_copy.append(14)

            for index: int in range(1, ranks_copy.size()):
                if not (ranks_copy[index - 1] == ranks_copy[index] - 1):
                    has_straight = false
                    is_royal = false
                    break

        # Search normal straight
        has_straight = true
        for index: int in range(1, ranks.size()):
            if ranks[index - 1] != ranks[index] - 1:
                has_straight = false
                break

    var paterns: Dictionary[int, int] = {}
    for rank: int in ranks:
        if paterns.has(rank):
            paterns[rank] += 1
        else:
            paterns.set(rank, 1)

    # paterns count the number of times each card appears,
    # quantities are the number of times sorted
    var quantities: Array[int] = paterns.values()
    quantities.sort()
    for count: int in quantities:
        match count:
            2:
                if has_pair:
                    has_two_pair = true
                has_pair = true
            3:
                has_three_of_a_kind = true
                if has_pair:
                    has_full_house = true
            4:
                has_four_of_a_kind = true


    if has_straight and has_flush and is_royal:
        return PokerHand.new("Royal Flush", Definitions.HandScores.royal_flush)
    elif has_straight and has_flush:
        return PokerHand.new("Straight Flush", Definitions.HandScores.straight_flush)
    elif has_straight:
        return PokerHand.new("Straight", Definitions.HandScores.straight)
    elif has_flush:
        return PokerHand.new("Flush", Definitions.HandScores.flush)
    elif has_four_of_a_kind:
        return PokerHand.new("Four of a Kind", Definitions.HandScores.four_of_a_kind)
    elif has_full_house:
        return PokerHand.new("Full House", Definitions.HandScores.full_house)
    elif has_three_of_a_kind:
        return PokerHand.new("Three of a Kind", Definitions.HandScores.trhee_of_a_kind)
    elif has_two_pair:
        return PokerHand.new("Two Pair", Definitions.HandScores.two_pair)
    elif has_pair:
        return PokerHand.new("Pair", Definitions.HandScores.pair)
    elif card_names.size() > 0:
        return PokerHand.new("High Card", Definitions.HandScores.high_card)
    else:
        return null


func get_highest_poker_hand_with_joker(card_names: Array[String]) -> PokerHand:
    if card_names.is_empty(): return PokerHand.new("", 0)

    var highest_hand := PokerHand.new("", 0)

    #NOTE Brute force, but works for now
    for suit: String in Definitions.card_suits:
        for number: String in Definitions.card_numbers:
            var card_names_copy: Array[String] = card_names.duplicate()
            card_names_copy.append("%s%s" % [number, suit])

            var new_hand: PokerHand = get_highest_poker_hand(card_names_copy)
            if new_hand.value > highest_hand.value:
                highest_hand = new_hand

    return highest_hand


func handle_end_of_round() -> void:
    if (GlobalState.current_score >= GlobalState.current_score_target) or GlobalState.shield_activated:
        GlobalState.current_cash = clamp(GlobalState.current_score - GlobalState.current_score_target, 0, INF)

        if GlobalState.current_score < GlobalState.current_score_target:
            GlobalState.shield_activated = false

        var screen_man: ScreenTransitionManager = get_tree().get_first_node_in_group("screen_transition_man")
        screen_man.transtition_to(screen_man.Screens.shop)
    else:
        GlobalState.full_reset_state()
        var screen_man: ScreenTransitionManager = get_tree().get_first_node_in_group("screen_transition_man")
        screen_man.transtition_to(screen_man.Screens.title)


func update_hand_type_label() -> void:
    var result: PokerHand = null
    if GlobalState.joker_selected:
        result = get_highest_poker_hand_with_joker(card_container.selected_cards)
    else:
        result = get_highest_poker_hand(card_container.selected_cards)

    if result == null:
        hand_label.text = ""
    else:
        hand_label.text = result.name


func _on_bonus_btn_pressed(bonus_type: Definitions.BonusTypes) -> void:
    match bonus_type:
        Definitions.BonusTypes.extra_card:
            card_container.draw_random_cards()
        Definitions.BonusTypes.extra_discard:
            GlobalState.discards_left += 1
        Definitions.BonusTypes.pocket_points:
            GlobalState.current_score += 25
        Definitions.BonusTypes.extra_hand:
            GlobalState.hands_left += 1
        Definitions.BonusTypes.double_score:
            GlobalState.double_points_actived = true
        _:
            assert(false, "Need to be a valid bonus type")

    GlobalState.acquired_bonuses.remove_at(GlobalState.acquired_bonuses.find(bonus_type))
    left_panel.update_all_visuals()


func _on_discard_button_pressed() -> void:
    if GlobalState.discards_left <= 0 or !card_container.has_cards_selected():
        return

    if GlobalState.joker_selected:
        GlobalState.joker_selected = false
        joker_indicator.deselect()

    card_container.discard_selected_cards()
    card_container.draw_random_cards(GlobalState.hand_size - card_container.current_hand.size())

    GlobalState.discards_left -= 1
    left_panel.update_all_visuals()
    update_hand_type_label()


func _on_play_hand_button_pressed() -> void:
    if card_container.selected_cards.size() <= 0 or GlobalState.hands_left <= 0: return;

    for card_value: String in card_container.selected_cards:
        card_container.discard_card(card_value)

    var result: PokerHand = null

    if GlobalState.joker_selected:
        result = get_highest_poker_hand_with_joker(card_container.selected_cards)

        joker_indicator.hide()
        joker_indicator.deselect()
        GlobalState.has_joker = false
        GlobalState.joker_selected = false
    else:
        result = get_highest_poker_hand(card_container.selected_cards)

    card_container.selected_cards.clear()

    card_container.draw_random_cards(GlobalState.hand_size - card_container.current_hand.size())

    if GlobalState.double_points_actived:
        GlobalState.current_score += result.value * 2
        GlobalState.double_points_actived = false
    else:
        GlobalState.current_score += result.value

    GlobalState.hands_left -= 1
    left_panel.update_all_visuals()
    update_hand_type_label()

    if GlobalState.hands_left <= 0:
        handle_end_of_round()


func _on_sort_by_rank_btn_pressed() -> void:
    card_container.current_sort_type = card_container.SortType.by_rank


func _on_sort_by_suit_btn_pressed() -> void:
    card_container.current_sort_type = card_container.SortType.by_suit


class PokerHand:
    var name: String = ""
    var value: int = 0

    func _init(new_name: String, new_value: int) -> void:
        self.name = new_name
        self.value = new_value
