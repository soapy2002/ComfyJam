extends Node

var time = "06:00"
var money = 0.67

func _process(delta: float) -> void:
	$GameTrackers/Time.text = str(time)
	$GameTrackers/Money.text = str(money)
