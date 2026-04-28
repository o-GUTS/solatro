class_name ShopScreen
extends Control


@onready var buy_extra_card_btn: Button = %buyExtraCardBtn
@onready var buy_extra_discard_btn: Button = %buyExtraDiscardBtn
@onready var buy_pocket_points_btn: Button = %buyPocketPointsBtn
@onready var buy_extra_hand_btn: Button = %buyExtraHandBtn
@onready var buy_double_score_btn: Button = %buyDoubleScoreBtn
@onready var buy_shield_btn: Button = %buyShieldBtn

@onready var current_cash_label: Label = %currentCashLabel


func _ready() -> void:
    buy_extra_card_btn.pressed.connect(
        func() -> void: _on_buy_btn_pressed(buy_extra_card_btn, Definitions.BonusTypes.extra_card)
    )
    buy_extra_discard_btn.pressed.connect(
        func() -> void: _on_buy_btn_pressed(buy_extra_discard_btn, Definitions.BonusTypes.extra_discard)
    )
    buy_pocket_points_btn.pressed.connect(
        func() -> void: _on_buy_btn_pressed(buy_pocket_points_btn, Definitions.BonusTypes.pocket_points)
    )
    buy_extra_hand_btn.pressed.connect(
        func() -> void: _on_buy_btn_pressed(buy_extra_hand_btn, Definitions.BonusTypes.extra_hand)
    )
    buy_double_score_btn.pressed.connect(
        func() -> void: _on_buy_btn_pressed(buy_double_score_btn, Definitions.BonusTypes.double_score)
    )
    buy_shield_btn.pressed.connect(
        func() -> void: _on_buy_btn_pressed(buy_shield_btn, Definitions.BonusTypes.shield)
    )

    for bonus_type: Definitions.BonusTypes in GlobalState.acquired_bonuses:
        match bonus_type:
            Definitions.BonusTypes.extra_card:
                buy_extra_card_btn.disabled = true
            Definitions.BonusTypes.extra_discard:
                buy_extra_discard_btn.disabled = true
            Definitions.BonusTypes.pocket_points:
                buy_pocket_points_btn.disabled = true
            Definitions.BonusTypes.extra_hand:
                buy_extra_hand_btn.disabled = true
            Definitions.BonusTypes.double_score:
                buy_double_score_btn.disabled = true

    if GlobalState.shield_activated:
        buy_shield_btn.disabled = true

    current_cash_label.text = str(GlobalState.current_cash)


func _on_buy_btn_pressed(btn: Button, bonus_type: Definitions.BonusTypes) -> void:
    match bonus_type:
        Definitions.BonusTypes.extra_card:
            if GlobalState.current_cash - Definitions.BonusPrices.extra_card >= 0:
                GlobalState.acquired_bonuses.append(bonus_type)
                GlobalState.current_cash -= Definitions.BonusPrices.extra_card
                btn.disabled = true

        Definitions.BonusTypes.extra_discard:
             if GlobalState.current_cash - Definitions.BonusPrices.extra_discard >= 0:
                GlobalState.acquired_bonuses.append(bonus_type)
                GlobalState.current_cash -= Definitions.BonusPrices.extra_discard
                btn.disabled = true

        Definitions.BonusTypes.pocket_points:
             if GlobalState.current_cash - Definitions.BonusPrices.pocket_points >= 0:
                GlobalState.acquired_bonuses.append(bonus_type)
                GlobalState.current_cash -= Definitions.BonusPrices.pocket_points
                btn.disabled = true

        Definitions.BonusTypes.extra_hand:
             if GlobalState.current_cash - Definitions.BonusPrices.extra_hand >= 0:
                GlobalState.acquired_bonuses.append(bonus_type)
                GlobalState.current_cash -= Definitions.BonusPrices.extra_hand
                btn.disabled = true

        Definitions.BonusTypes.double_score:
             if GlobalState.current_cash - Definitions.BonusPrices.double_score >= 0:
                GlobalState.acquired_bonuses.append(bonus_type)
                GlobalState.current_cash -= Definitions.BonusPrices.double_score
                btn.disabled = true

        Definitions.BonusTypes.shield:
             if GlobalState.current_cash - Definitions.BonusPrices.shield >= 0:
                GlobalState.shield_activated = true
                GlobalState.current_cash -= Definitions.BonusPrices.shield
                btn.disabled = true

    current_cash_label.text = str(GlobalState.current_cash)


func _on_quit_shop_btn_pressed() -> void:
    var screen_man: ScreenTransitionManager = get_tree().get_first_node_in_group("screen_transition_man")
    screen_man.transtition_to(screen_man.Screens.game)
