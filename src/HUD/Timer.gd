extends HBoxContainer

@onready var countdowntime : int = 61
@onready var Timer_label = $TimerValue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display_timer(countdowntime)
	var timer = $Timer
	timer.wait_time = 1.0
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func _on_timer_timeout() -> void:
	countdowntime -= 1
	display_timer(countdowntime)
	if countdowntime <= 0:
		$Timer.stop()
		#TODO Déclencement du prochain niveau ou quelque chose du genre


func display_timer(currentTime : int) -> void:
	Timer_label.text = str(floor(currentTime/60)).pad_zeros(2) +" : " +str(currentTime%60).pad_zeros(2)
