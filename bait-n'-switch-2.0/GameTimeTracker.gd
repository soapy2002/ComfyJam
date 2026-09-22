extends DirectionalLight3D

#Signals
signal hour_changed(hour: int)
signal day_changed(day: int)
signal time_of_day_changed(is_day: bool)

#Time Variables
var current_time: float = 360.0 #The current time of day 
var current_day: int = 1 # How many days in game has the player been playing for
var current_hour: int = 0 # How many hours have past in the current day
var is_day: bool = true 

#Static Variables
var day_start: int = 6 # The hour of day that daytime begins
var night_start: int = 21 # The hour of day that nighttime begins
var day_duration: float = 1440 #Seconds passed for a full in game day.
var time_scale: float = 1 # How many seconds in game occur per real world second.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_time += delta * time_scale
	
	var seconds_per_hour = day_duration / 24
	var new_hour = int(current_time / seconds_per_hour) % 24
	
	if new_hour != current_hour:
		current_hour = new_hour
		emit_signal("hour_changed", current_hour)
		print_debug(current_hour)
	
	if current_hour >= 24:
		current_time -= day_duration
		current_day += 1
		emit_signal("day_changed", current_day)

func check_day_transition() -> void:
	var was_day = is_day
	if current_hour >= day_start and current_hour < night_start:
		is_day = true
	else:
		is_day = false
	
	if was_day != is_day:
		emit_signal("time_of_day_changed", is_day)

	
