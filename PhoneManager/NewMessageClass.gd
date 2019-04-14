extends Node
 

onready var EMessageState = preload("res://PhoneManager/EMessageState.gd").new();

var MessageState = 0; 
var MessageText = "";
var MessageSource = false;#false == friend, #true == you


func CheckMessageState(var State):
	return MessageState == State;
func UpdateMessageState(var State):
	MessageState = State;
	 
func UpdateMessageText(var Text):
	MessageText = Text;
	 
func UpdateMessageSource(var Source):
	MessageSource = Source;