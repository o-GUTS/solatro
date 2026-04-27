class_name Definitions


enum HandScores {
  high_card = 5, pair = 10, two_pair = 20,
  trhee_of_a_kind = 30, straight = 40,
  flush = 50, full_house = 60, four_of_a_kind = 100,
  straight_flush = 125, royal_flush = 125
}
enum BonusTypes {
  extra_card, extra_discard, pocket_points,
  extra_hand, double_score, shield
}
enum BonusPrices {
  extra_card = 10, extra_discard = 25, pocket_points = 50,
  extra_hand = 75, double_score = 100, shield = 150
}

const card_suits: Array[String] = ["h", "d", "c", "s"]
const full_suit_names: Dictionary[String, String] = {"h": "Hearts", "d": "Diamonds", "s": "Spades", "c": "Clubs"}

const card_numbers: Array[String] = [
    "1", "2", "3", "4", "5", "6", "7",
    "8", "9", "10", "11", "12", "13"
]

const base_score_target: int = 0
const score_target_increment: int = 25

const max_selected_cards: int = 5
const base_hand_size: int = 8

const base_hands_count: int = 3
const base_discards_count: int = 3
