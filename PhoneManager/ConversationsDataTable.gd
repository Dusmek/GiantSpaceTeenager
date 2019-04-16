extends Node
 
onready var MessagesClass = preload("res://PhoneManager/NewMessageClass.gd").new(); 
onready var EMessageState = preload("res://PhoneManager/EMessageState.gd").new();
var ConversationClass = load("res://PhoneManager/ConversationClass.gd");
 
var Conversations = []; 

#func AddNewMessageForNPC(var MessageGood, var MessageMeh, var MessageBad, var MessageLosingFriend): 
#func AddNewMessageForPlayer(var MessageGoodPlayer, var MessageMehPlayer, var MessageBadPlayer):

func GetDatabase():  
	return Conversations[randi()%Conversations.size()];

func GenerateDatabase():
	var NewConversationClass;
	
	NewConversationClass = ConversationClass.new();
	NewConversationClass.AddNewMessageForNPC("You are my best friend! <3", "You are my only friend :3", "You are okey", "Your are fuck");
	NewConversationClass.AddNewMessageForPlayer("You are my best friend too! <3", "Awwwww : 3", "Ugh... regret is a thing :_:");
	Conversations.push_back(NewConversationClass);
	
	NewConversationClass = ConversationClass.new();
	NewConversationClass.AddNewMessageForNPC("You are my best friend! <3", "You are my only friend :3", "You are okey", "Your are fuck");
	NewConversationClass.AddNewMessageForPlayer("You are my best friend too! <3", "Awwwww : 3", "Ugh... regret is a thing :_:");
	NewConversationClass.AddNewMessageForNPC("Howdy", "sup", "huh?", "KYS");
	NewConversationClass.AddNewMessageForPlayer("AYYY", "up", "huh.");
	NewConversationClass.AddNewMessageForNPC("okej", "oki", "ok", "K");
	Conversations.push_back(NewConversationClass);
	pass