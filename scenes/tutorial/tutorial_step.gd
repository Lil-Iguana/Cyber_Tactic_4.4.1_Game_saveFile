class_name TutorialStep
extends Resource

enum ActionType {
	NONE,              # Just show text, no action required
	PLAY_CARD,         # Player must play a card
	PLAY_CARD_TYPE,    # Player must play specific card type
	END_TURN,          # Player must press end turn
	CLICK_NODE,        # Player must click specific node
	WAIT_ENEMY_TURN,   # Wait for enemy to complete turn
	WAIT_SIGNAL,       # Wait for custom signal
}

@export var narration_text: String = ""
@export var action_type: ActionType = ActionType.NONE
@export var highlight_node_path: String = ""  # Node path to highlight (e.g., "BattleUI/EndTurnButton")
@export var card_type_required: Card.Type = Card.Type.ATTACK  # For PLAY_CARD_TYPE
@export var wait_signal_name: String = ""  # For WAIT_SIGNAL
@export var auto_advance_delay: float = 0.0  # Auto-advance after this many seconds (0 = no auto)
@export var block_all_except_highlight: bool = true  # Block all input except highlighted element
@export var show_drag_arrow: bool = false  # Show animated drag arrow
@export var drag_arrow_end_pos: Vector2 = Vector2(320, 150)  # Where drag arrow points to
