extends Control

var ButtonSizeX = 64;
var ButtonSizeY = 48; 


func _ready():
	for i in get_child_count():
		get_child(i).rect_size = Vector2(ButtonSizeX,ButtonSizeY);
		get_child(i).rect_position = Vector2(fmod(i,3)*ButtonSizeX*1.1, (i/3)*ButtonSizeY*1.1);
	pass
