extends KinematicBody2D

export (float) var speed = 500
export (float) var gravity = 50
export (float) var jumpSpeed = 1000
var velocity = Vector2.ZERO
var anim = "Idle"
var id = ""
var jump = 0
var timer = 0
var lastTime = 0
var diving = false
var move = Vector2.ZERO
var jumpPress = 0
var onFloor3 = 0
var dived = 0

func _process(delta):
	timer += delta
	var onFloor2 = false
	for body in $Area2D.get_overlapping_bodies():
		if body.name != name:
			onFloor2 = true
	onFloor3 -= 1
	dived -= delta
	if onFloor2:
		onFloor3 = 10
	var onFloor = onFloor3 > 0
	if id == network.id:
		global.player = self
		$Player.texture = global.textures[global.saveData["character"]]
		$Username.text = global.saveData["username"]
		
		if Input.is_action_pressed("down"):
			diving = true
		
		if diving and not is_on_floor():
			dived = 0.25
		
		if diving:
			if velocity.y < gravity:
				velocity.y = gravity
			gravity *= 2
		velocity.y += gravity
		velocity.x *= 0.5
		if diving:
			gravity /= 2
		
		if onFloor:
			diving = false
		
		jumpPress -= delta
		
		if Input.is_action_just_pressed("jump"):
			jumpPress = 0.1
		
		if is_on_floor():
			velocity.y = 0
		if dived > 0:
			jumpSpeed *= 1.25
		if jumpPress > 0 and onFloor:
			jump = 0
			jumpPress = 0
			velocity.y = -jumpSpeed
		if Input.is_action_pressed("jump") and jump < 6:
			jump += 1
			velocity.y += -jumpSpeed*jump
		if dived > 0:
			jumpSpeed /= 1.25
		
		if Input.is_action_pressed("left"):
			velocity.x -= speed
			$Player.scale.x = -4
		if Input.is_action_pressed("right"):
			velocity.x += speed
			$Player.scale.x = 4
		
		if is_on_ceiling():
			velocity.y = gravity
		
		if Input.is_action_pressed("down"):
			anim = "Crouch"
		else:
			anim = "Idle"
		if abs(velocity.x) > speed/10:
			if Input.is_action_pressed("down"):
				anim = "CrouchWalk"
			else:
				anim = "Run"
		if not onFloor:
			anim = "Jump"
		if diving:
			anim = "Dive"
		if Input.is_action_just_pressed("attack") or $AnimationPlayer.current_animation == "Attack" or $AnimationPlayer.current_animation == "vent":
			if global.saveData["character"] == 3:
				if $Player.visible:
					anim = "vent"
				elif not $AnimationPlayer.current_animation == "vent":
					anim = "RESET"
			else:
				anim = "Attack"
		$AnimationPlayer.play(anim)
		move = Vector2.ZERO
		var lastPos2 = position
		move_and_slide(velocity, Vector2.UP)
		move = position-lastPos2
	else:
		if network.playerData.has(id):
			if network.playerData[id].has("pos"):
				var pos = Vector2(network.playerData[id]["pos"][0], network.playerData[id]["pos"][1])
				var vel = Vector2(network.playerData[id]["velocity"][0], network.playerData[id]["velocity"][1])
				$Player.texture = global.textures[network.playerData[id]["character"]]
				$Username.text = network.playerData[id]["username"]
				if lastTime != network.playerData[id]["timer"]:
					$Tween.interpolate_property(self, "position", position, pos, 0.1)
					$Tween.start()
					lastTime = network.playerData[id]["timer"]
					velocity = vel
				$Player.scale.x = network.playerData[id]["scale"]
				if $Tween.is_active():
					$AnimationPlayer.play(network.playerData[id]["anim"])
					velocity = vel
			if not $Tween.is_active():
				anim = "Idle"
				if abs(velocity.x) > speed/10:
					anim = "Run"
				if not onFloor:
					anim = "Jump"
				$AnimationPlayer.play(anim)
				move_and_slide(velocity, Vector2.UP)
				velocity.y += gravity
				velocity.x *= 0.9
		else:
			if timer > 1:
				queue_free()

func _on_sendData_timeout():
	if network.id == id:
		network.data["pos"] = [position.x, position.y]
		network.data["anim"] = anim
		network.data["scale"] = $Player.scale.x
		network.data["velocity"] = [move.x, move.y]
		network.data["character"] = global.saveData["character"]
		network.data["username"] = global.saveData["username"]
