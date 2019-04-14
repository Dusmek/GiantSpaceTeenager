extends Control
 
var Width = 172;
var WidthSet = false; 

var Position = Vector2(0,0);
 
var MessageSource = false;

var TextureRectY = 0;

func _process(delta):  
	get_node("TextureRect").rect_size = Vector2(get_node("Label").rect_size.x*1.2, 16 + 15 * get_node("Label").get_line_count()); 
	TextureRectY = get_node("TextureRect").rect_size.y;
	pass
	
func SetUpNewMessage(var Message):  
	MessageSource = Message.MessageSource;
	
	get_node("Label").rect_size = Vector2(Width, 0);
	get_node("Label").text = Message.MessageText; 
	

func UpdatePosition(var PositionY_):
	var Position_ = Vector2(0, PositionY_);
	  
	if( MessageSource ):
		Position_.x += 32;
	Position = Position_;  
	
	rect_position = Position;