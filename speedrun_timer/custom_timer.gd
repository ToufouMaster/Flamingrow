class_name CustomTimer


var _already_elapsed_time_ms: int = 0
var _start_time_ms: int = 0
var _playing: bool = false


func current_time_ms() -> int:
	return _already_elapsed_time_ms + _elapsed_time_ms()


func reset_timer() -> void:
	_playing = false
	_start_time_ms = 0
	_already_elapsed_time_ms = 0


func start_timer(time_ms: int = 0) -> void:
	_already_elapsed_time_ms = time_ms
	resume_timer()


func resume_timer() -> void:
	_start_time_ms = Time.get_ticks_msec()
	_playing = true


func pause_timer() -> void:
	_already_elapsed_time_ms += _elapsed_time_ms()
	_playing = false


## Returns the elapsed time as a conveniently formatted string
## e.g. "1:02.345"
func formatted_time() -> String:
	var time: int = current_time_ms()
	var minutes: int = 0
	var sec: int = 0
	var ms: int = 0
	while time >= 1000:
		sec += 1
		time -= 1000
		if sec >= 60:
			sec = 0
			minutes += 1
	ms = time
	var sec_str: String = str(sec)
	if sec < 10:
		sec_str = "0" + sec_str
	var ms_str: String = str(ms)
	if ms < 100:
		ms_str = "0" + ms_str
	if ms < 10:
		ms_str = "0" + ms_str
	
	return str(minutes) + ":" + sec_str + "." + ms_str


func _elapsed_time_ms() -> int:
	if _playing:
		return Time.get_ticks_msec() - _start_time_ms
	else:
		return 0
