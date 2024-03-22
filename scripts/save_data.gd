class_name SaveData
## The class that loads and saves the game


var unlocked_levels: int = 1


func load_data() -> void:
	if not FileAccess.file_exists("user://savegame.txt"):
		return
	
	var save_file = FileAccess.open("user://savegame.txt", FileAccess.READ)
	unlocked_levels = int(save_file.get_line())


func save() -> void:
	var save_string: String = ""
	save_string = save_string + str(unlocked_levels) + "\n"
	
	var save_file := FileAccess.open("user://savegame.txt", FileAccess.WRITE)
	save_file.store_string(save_string)
	save_file.close()
