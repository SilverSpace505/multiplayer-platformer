extends Control

var timer = 0

func _process(delta):
	timer += delta
	$Title.rect_position.x = 252 + sin(timer*2) * 10
	$Rotate.rect_rotation = sin(timer*1.25) * 3
	global.saveData["username"] = $Rotate/Customization/Username.text
	$Rotate/Customization/Player.texture = global.textures[global.saveData["character"]]
	
func _ready():
	$Rotate/Customization/Username.text = global.saveData["username"]
	$Rotate/Customization/Player.texture = global.textures[global.saveData["character"]]
	global.sceneName = "Menu"
	for player in network.playerData:
		var player2 = load("res://PlayerMenu.tscn").instance()
		$Players.add_child(player2)
		player2.id = player
		player2.name = player

func _on_Play_pressed():
	get_tree().change_scene("res://Scenes/game.tscn")
	$Rotate/Menu/Buttons/Play.text = "Loading..."
	
func _on_Customization_pressed():
	$Rotate/Menu.visible = false
	$Rotate/Customization.visible = true

func _on_Back_pressed():
	$Rotate/Menu.visible = true
	$Rotate/Customization.visible = false

func _on_Right_pressed():
	global.saveData["character"] += 1
	if global.saveData["character"] >= len(global.textures):
		global.saveData["character"] = 0

func _on_Left_pressed():
	global.saveData["character"] -= 1
	if global.saveData["character"] < 0:
		global.saveData["character"] = len(global.textures)-1