class_name CustomLeftPanel
extends PanelContainer


signal bonus_btn_pressed(bonus_type: Definitions.BonusTypes)

enum LABELS {
    current_round, score_target, current_score,
    hands_count, discards_count
}

@onready var current_round_label: Label = %currentRoundLabel
@onready var score_target_label: Label = %scoreTargetLabel
@onready var current_score_label: Label = %currentScoreLabel
@onready var hands_cont_label: Label = %handsContLabel
@onready var discards_cont_label: Label = %discardsContLabel

@onready var extra_card_bonus_btn: Button = %extraCardBonusBtn
@onready var extra_discard_bonus_btn: Button = %extraDiscardBonusBtn
@onready var pocke_points_bonus_btn: Button = %pockePointsBonusBtn
@onready var extra_hand_bonus_btn: Button = %extraHandBonusBtn
@onready var double_score_bonus_btn: Button = %doubleScoreBonusBtn
@onready var quit_btn: Button = %quit_btn


func _ready() -> void:
    extra_card_bonus_btn.pressed.connect(func() -> void: bonus_btn_pressed.emit(Definitions.BonusTypes.extra_card))
    extra_discard_bonus_btn.pressed.connect(func() -> void: bonus_btn_pressed.emit(Definitions.BonusTypes.extra_discard))
    pocke_points_bonus_btn.pressed.connect(func() -> void: bonus_btn_pressed.emit(Definitions.BonusTypes.pocket_points))
    extra_hand_bonus_btn.pressed.connect(func() -> void: bonus_btn_pressed.emit(Definitions.BonusTypes.extra_hand))
    double_score_bonus_btn.pressed.connect(func() -> void: bonus_btn_pressed.emit(Definitions.BonusTypes.double_score))


func change_label(label: LABELS, text: String) -> void:
    match label:
        LABELS.current_round:
            current_round_label.text = text
        LABELS.score_target:
            score_target_label.text = text
        LABELS.current_score:
            current_score_label.text = text
        LABELS.hands_count:
            hands_cont_label.text = text
        LABELS.discards_count:
            discards_cont_label.text = text


func update_all_visuals() -> void:
    change_label(LABELS.current_round, "%s" % [GlobalState.current_round])
    change_label(LABELS.score_target, "%s" % [GlobalState.current_score_target])
    change_label(LABELS.current_score, "%s" % [GlobalState.current_score])
    change_label(LABELS.hands_count, "%s" % [GlobalState.hands_left])
    change_label(LABELS.discards_count, "%s" % [GlobalState.discards_left])

    #TEMP
    if GlobalState.shield_activated:
        current_round_label.text += " SHIELD"

    extra_card_bonus_btn.disabled = true
    extra_discard_bonus_btn.disabled = true
    pocke_points_bonus_btn.disabled = true
    extra_hand_bonus_btn.disabled = true
    double_score_bonus_btn.disabled = true
    for bonus_type: Definitions.BonusTypes in GlobalState.acquired_bonuses:
        match bonus_type:
            Definitions.BonusTypes.extra_card:
                extra_card_bonus_btn.disabled = false
            Definitions.BonusTypes.extra_discard:
                extra_discard_bonus_btn.disabled = false
            Definitions.BonusTypes.pocket_points:
                pocke_points_bonus_btn.disabled = false
            Definitions.BonusTypes.extra_hand:
                extra_hand_bonus_btn.disabled = false
            Definitions.BonusTypes.double_score:
                double_score_bonus_btn.disabled = false
            #Definitions.BonusTypes.shield:
                #extra_card_bonus_btn.disabled = false


func _on_quit_btn_pressed() -> void:
    GlobalState.full_reset_state()
    var screen_man: ScreenTransitionManager = get_tree().get_first_node_in_group("screen_transition_man")
    screen_man.transtition_to(screen_man.Screens.title)
