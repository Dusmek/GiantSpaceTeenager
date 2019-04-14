extends Control

onready var MessagesClass = preload("res://PhoneManager/NewMessageClass.gd").new(); 
onready var EMessageState = preload("res://PhoneManager/EMessageState.gd").new();

var MessageObjPath = load("res://PhoneManager/Text.tscn"); 
 
var MessageObjs = [];

func _process(delta):
	var DistanceFromBottom = 216; 
	for obj in MessageObjs:
		DistanceFromBottom -= obj.TextureRectY + 8;
		obj.UpdatePosition(DistanceFromBottom); 

func CreateNewMessage( var Message ): 
	var MessageInst = MessageObjPath.instance(); 
	MessageInst.SetUpNewMessage(Message); 
	MessageObjs.push_front(MessageInst);
	add_child(MessageInst);  