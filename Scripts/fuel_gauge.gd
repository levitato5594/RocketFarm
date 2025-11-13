extends ProgressBar

func _on_player_fuel_updated(fuel_percent) -> void:
	print(fuel_percent)
	value = fuel_percent
