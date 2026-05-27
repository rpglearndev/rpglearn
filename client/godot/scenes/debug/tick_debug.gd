extends Control
## Escena debug US-010: muestra tick index y posición (sin depender de delta en lógica).


@onready var _label: Label = $VBox/InfoLabel


func _ready() -> void:
	GameTick.world.set_entity_position(&"player", Vector2i(10, 10))
	GameTick.world.tick_processed.connect(_on_tick_processed)
	_refresh()


func _on_tick_processed(_tick_index: int) -> void:
	_refresh()


func _refresh() -> void:
	var pos := GameTick.world.get_entity_position(&"player")
	_label.text = "Tick: %d | TPS: %d | Player: (%d, %d)\nQ/E/W/S = encolar movimiento" % [
		GameTick.world.tick_index,
		GameTick.world.ticks_per_second,
		pos.x,
		pos.y,
	]


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var dir := Vector2i.ZERO
	match event.keycode:
		KEY_W, KEY_UP:
			dir = Vector2i.UP
		KEY_S, KEY_DOWN:
			dir = Vector2i.DOWN
		KEY_A, KEY_LEFT:
			dir = Vector2i.LEFT
		KEY_D, KEY_RIGHT:
			dir = Vector2i.RIGHT
		_:
			return
	GameTick.enqueue_move(dir)
	get_viewport().set_input_as_handled()
