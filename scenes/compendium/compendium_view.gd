class_name CompendiumView
extends Control

@onready var back_button: Button = %BackButton
@onready var tab_container: TabContainer = %TabContainer
@onready var bestiary_view: BestiaryView = %BestiaryView

# Stats labels
@onready var enemies_defeated_label: Label = %EnemiesDefeatedLabel
@onready var floors_climbed_label: Label = %FloorsClimbedLabel
@onready var runs_started_label: Label = %RunsStartedLabel
@onready var runs_won_label: Label = %RunsWonLabel
@onready var runs_lost_label: Label = %RunsLostLabel


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	visibility_changed.connect(_on_visibility_changed)
	_update_stats_display()


func _on_visibility_changed() -> void:
	if visible:
		_update_stats_display()


func _update_stats_display() -> void:
	var meta = MetaProgression.load_meta()
	
	enemies_defeated_label.text = "Enemies Defeated: %d" % meta.total_enemies_defeated
	floors_climbed_label.text = "Floors Climbed: %d" % meta.total_floors_climbed
	runs_started_label.text = "Runs Started: %d" % meta.total_runs_started
	runs_won_label.text = "Runs Won: %d" % meta.total_runs_won
	runs_lost_label.text = "Runs Lost: %d" % meta.total_runs_lost


func _on_back_pressed() -> void:
	hide()
