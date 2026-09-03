extends Node2D

@export var card_scene: PackedScene = preload("res://scenes/card.tscn")
@export var card_textures: Array[Texture2D] = []

@onready var grid: GridContainer = $GridContainer

var first_card = null
var second_card = null

var matched_pairs: int = 0
var moves: int = 0
var seconds_elapsed: int = 0

var can_click: bool = true


func _ready():
	$GameTimer.timeout.connect(_on_timer_tick)
	$RestartButton.pressed.connect(_on_restart_pressed)
	$WinLabel.hide()
	create_cards()


func create_cards():
	# Remove the existing card from GridContainer.
	for child in grid.get_children():
		child.queue_free()

	# 4 matching pairs = 8 cards.
	var values = [
		1, 1,
		2, 2,
		3, 3,
		4, 4
	]

	# Shuffle card positions.
	values.shuffle()

	# Create all 8 cards.
	for value in values:
		var card = card_scene.instantiate()

		card.value = value
		card.set_front_texture(card_textures[value - 1])

		grid.add_child(card)

		card.card_clicked.connect(_on_card_clicked)


func _on_card_clicked(card):
	if not can_click:
		return

	$FlipSound.play()

	# First card.
	if first_card == null:
		first_card = card
		return

	# Don't select the same card twice.
	if card == first_card:
		return

	# Second card.
	second_card = card

	# Increase moves.
	moves += 1
	$MovesLabel.text = "Moves: " + str(moves)

	can_click = false

	check_match()


func check_match():
	if first_card.value == second_card.value:
		# Correct match.
		first_card.set_matched()
		second_card.set_matched()

		$MatchSound.play()

		matched_pairs += 1

		# Update score.
		$ScoreLabel.text = "Score: " + str(matched_pairs)

		reset_selected_cards()

		# All 4 pairs found.
		if matched_pairs == 4:
			game_won()

	else:
		$WrongSound.play()
		# Wait before hiding incorrect cards.
		await get_tree().create_timer(0.8).timeout

		first_card.flip_down()
		second_card.flip_down()

		reset_selected_cards()


func reset_selected_cards():
	first_card = null
	second_card = null
	can_click = true


func _on_timer_tick():
	seconds_elapsed += 1
	$TimerLabel.text = "Time: " + str(seconds_elapsed) + "s"


func game_won():
	$WinLabel.show()
	$GameTimer.stop()
	$WinSound.play()

	print("You Win!")
	print("Moves: ", moves)
	print("Time: ", seconds_elapsed, " seconds")


func _on_restart_pressed():
	get_tree().reload_current_scene()
