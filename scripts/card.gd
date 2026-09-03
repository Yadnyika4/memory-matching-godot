extends Button

signal card_clicked(card)

var value: int = -1
var is_flipped: bool = false
var is_matched: bool = false


func _ready():
	pressed.connect(_on_pressed)
	flip_down()


func _on_pressed():
	if is_flipped or is_matched:
		return

	flip_up()
	card_clicked.emit(self)


func flip_up():
	var tween = create_tween()

	tween.tween_property(self, "scale:x", 0.05, 0.15)
	tween.tween_callback(func():
		is_flipped = true
		text = ""
		$FrontImage.visible = true
	)
	tween.tween_property(self, "scale:x", 1.0, 0.15)

func flip_down():
	var tween = create_tween()

	tween.tween_property(self, "scale:x", 0.05, 0.15)
	tween.tween_callback(func():
		is_flipped = false
		text = "?"
		$FrontImage.visible = false
	)
	tween.tween_property(self, "scale:x", 1.0, 0.15)


func set_matched():
	is_matched = true
	disabled = true


func set_front_texture(tex: Texture2D):
	$FrontImage.texture = tex
