class_name GameScreen
extends Control

#TODO Jokers

@onready var card_container: CardContainer = %cardContainer
@onready var discard_button: Button = %discardButton
@onready var play_hand_button: Button = %playHandButton
@onready var hand_label: Label = %hand_label
@onready var left_panel: CustomLeftPanel = %leftPanel


func _ready() -> void:
    card_container.selection_changed.connect(update_hand_type_label)
    left_panel.bonus_btn_pressed.connect(_on_bonus_btn_pressed)

    start_new_round()


func start_new_round() -> void:
    GlobalState.prepare_state_to_next_round()

    card_container.reset()
    left_panel.update_all_visuals()


func compute_score(cards: Array[String]) -> Dictionary[String, int]:
    if cards.size() == 1:
        return {"High Card": Definitions.HandScores.high_card}

    var result: Dictionary[String, int] = {"": 0}

    var suits: Array[String] = []
    var ranks: Array[int] = []

    var has_pair: bool = false
    var has_two_pair: bool = false
    var has_three_of_a_kind: bool = false
    var has_straight: bool = false
    var has_flush: bool = false
    var has_full_house: bool = false
    var has_fours_of_a_kind: bool = false
    var is_royal: bool = false

    for card_value: String in cards:
        suits.append(card_value[-1])
        ranks.append(card_value.substr(0, card_value.length() - 1).to_int())

    has_flush = cards.size() == Definitions.max_selected_cards and suits.all(func(elem: String) -> bool: return elem == suits[0])

    ranks.sort()

    # Search royal straight
    if ranks.has(1):
        var ranks_copy: Array[int] = ranks.duplicate()
        ranks_copy.remove_at(0)
        ranks_copy.append(14)

        for index: int in range(1, cards.size()):
            if (not ranks_copy[index] - 1 == ranks_copy[index - 1]) or cards.size() != Definitions.max_selected_cards:
                has_straight = false
                is_royal = false
                break

            has_straight = true
            is_royal = true

    # Search normal straight
    if not has_straight:
        for index: int in range(1, cards.size()):
            if (not ranks[index] - 1 == ranks[index - 1]) or cards.size() != Definitions.max_selected_cards:
                has_straight = false
                break

            has_straight = true

    var paterns: Dictionary[int, int] = {}
    for index: int in range(ranks.size()):
        if not paterns.has(ranks[index]):
            paterns.set(ranks[index], 1)
        else:
            paterns[ranks[index]] += 1

    for key: int in paterns.keys():
        if paterns[key] == 2:
            if has_pair:
                has_two_pair = true
            if has_three_of_a_kind:
                has_full_house = true

            has_pair = true

        elif paterns[key] == 3:
            has_three_of_a_kind = true
            if has_pair:
                has_full_house = true

        elif paterns[key] == 4:
            has_fours_of_a_kind = true

    if has_straight and has_flush and is_royal:
        result = {"Royal Flush": Definitions.HandScores.royal_flush}
    elif has_straight and has_flush:
        result = {"Straight Flush": Definitions.HandScores.straight_flush}
    elif has_straight:
        result = {"Straight": Definitions.HandScores.straight}
    elif has_flush:
        result = {"Flush": Definitions.HandScores.flush}
    elif has_fours_of_a_kind:
        result = {"Four of a Kind": Definitions.HandScores.four_of_a_kind}
    elif has_full_house:
        result = {"Full House": Definitions.HandScores.full_house}
    elif has_three_of_a_kind:
        result = {"Three of a Kind": Definitions.HandScores.trhee_of_a_kind}
    elif has_two_pair:
        result = {"Two Pair": Definitions.HandScores.two_pair}
    elif has_pair:
        result = {"Pair": Definitions.HandScores.pair}
    elif cards.size() > 0:
        result = {"High Card": Definitions.HandScores.high_card}

    return result


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
    var result: Dictionary[String, int] = compute_score(card_container.selected_cards)
    hand_label.text = result.keys()[0]


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

    card_container.discard_selected_cards()
    card_container.draw_random_cards(GlobalState.hand_size - card_container.current_hand.size())

    GlobalState.discards_left -= 1
    left_panel.update_all_visuals()


func _on_play_hand_button_pressed() -> void:
    if card_container.selected_cards.size() <= 0 or GlobalState.hands_left <= 0: return;

    for card_value: String in card_container.selected_cards:
        card_container.discard_card(card_value)

    var result: Dictionary = compute_score(card_container.selected_cards)
    card_container.selected_cards.clear()

    card_container.draw_random_cards(GlobalState.hand_size - card_container.current_hand.size())

    if GlobalState.double_points_actived:
        GlobalState.current_score += result.values()[0] * 2
        GlobalState.double_points_actived = false
    else:
        GlobalState.current_score += result.values()[0]

    GlobalState.hands_left -= 1
    left_panel.update_all_visuals()

    if GlobalState.hands_left <= 0:
        handle_end_of_round()


func _on_sort_by_rank_btn_pressed() -> void:
    card_container.current_sort_type = card_container.SortType.by_rank


func _on_sort_by_suit_btn_pressed() -> void:
    card_container.current_sort_type = card_container.SortType.by_suit
