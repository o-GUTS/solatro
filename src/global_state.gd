extends Node


var current_round: int = 0
var current_cash: int = 0
var current_score: int = 0
var current_score_target: int = Definitions.base_score_target

var acquired_bonuses: Array[Definitions.BonusTypes] = []
var shield_activated: bool = false
var double_points_actived: bool = false
var has_joker: bool = false

var hand_size: int = Definitions.base_hand_size
var hands_left: int = Definitions.base_hands_count
var discards_left: int = Definitions.base_discards_count


## Reset all variables to a new game
func full_reset_state() -> void:
    current_round = 0
    current_cash = 0

    current_score = 0
    current_score_target = Definitions.base_score_target

    acquired_bonuses.clear()
    shield_activated = false
    double_points_actived = false
    has_joker = false

    hand_size = Definitions.base_hand_size
    hands_left = Definitions.base_hands_count
    discards_left = Definitions.base_discards_count


## Reset variables to a new round
func prepare_state_to_next_round() -> void:
    current_round += 1
    current_cash = 0

    current_score = 0
    current_score_target += Definitions.score_target_increment

    shield_activated = false
    double_points_actived = false
    has_joker = false

    hands_left = Definitions.base_hands_count
    discards_left = Definitions.base_discards_count
