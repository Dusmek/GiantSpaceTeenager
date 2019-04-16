extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var speed = Vector2(0,0)
var force = Vector2(0,0)
func myupdate(delta):
	speed+=force*delta
	position+=speed*delta
	pass
	
func _on_Sprite_ready():
	var atom_sprite = get_node("Sprite_node")
	var r = randi()%4
	if r==0:
		atom_sprite.set_texture(load("atom1.png"))
	elif r==1:
		atom_sprite.set_texture(load("atom2.png"))
	elif r==2:
		atom_sprite.set_texture(load("atom3.png"))
	elif r==3:
		atom_sprite.set_texture(load("atom4.png"))
	pass # Replace with function body.
