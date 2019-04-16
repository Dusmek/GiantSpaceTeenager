extends Node

onready var MessagesClass = preload("res://PhoneManager/NewMessageClass.gd").new(); 
onready var EMessageState = preload("res://PhoneManager/EMessageState.gd").new();


var MessagesMeh = []; 
var MessagesGood = []; 
var MessagesBad = [];  
var MessagesLosingFriend = [];  

var MessagesMehPlayer = []; 
var MessagesGoodPlayer = []; 
var MessagesBadPlayer = [];

var ConversationIndex = -1;
var ConversationIndexPlayer = -1;

var ConversationSize = 0;
var ConversationSizePlayer = 0;

var GoodMessageFriendPointsBreakpoint = 3;
var BadMessageFriendPointsBreakpoint = -3;
var LosingMessageFriendPointsBreakpoint = -10

var GoodMessageBreakpoint = 2;
var BadMessageBreakpoint = -2;


func AddNewMessageForNPC(var MessageGood, var MessageMeh, var MessageBad, var MessageLosingFriend):
		
	MessagesMeh.push_back(MessageMeh);
	MessagesGood.push_back(MessageGood);
	MessagesBad.push_back(MessageBad);
	MessagesLosingFriend.push_back(MessageLosingFriend); 
	  
	ConversationSize = MessagesMeh.size();

func AddNewMessageForPlayer(var MessageGoodPlayer, var MessageMehPlayer, var MessageBadPlayer):
		 
	MessagesMehPlayer.push_back(MessageMehPlayer);
	MessagesGoodPlayer.push_back(MessageGoodPlayer);
	MessagesBadPlayer.push_back(MessageBadPlayer);
	
	ConversationSizePlayer = MessagesMehPlayer.size();
	 
func IsAnotherMessage(var Player):
	if( Player ):
		return ConversationIndexPlayer < ConversationSizePlayer-1;
	else:
		return ConversationIndex < ConversationSize-1;

func GetActualConversationMessage(var Player, var Points): 
	print(Player);
	print(Points);
	if( Player ):
		ConversationIndexPlayer += 1;
		if( Points < BadMessageBreakpoint ): 
			return MessagesBadPlayer[ConversationIndex];
		elif( Points > GoodMessageBreakpoint ):
			return MessagesGoodPlayer[ConversationIndex];
		else:
			return MessagesMehPlayer[ConversationIndex];
	else:
		ConversationIndex += 1;
		if( Points < LosingMessageFriendPointsBreakpoint ): 
			return MessagesLosingFriend[ConversationIndex];
		elif( Points < BadMessageFriendPointsBreakpoint ):
			return MessagesBad[ConversationIndex];
		elif( Points > GoodMessageFriendPointsBreakpoint ):
			return MessagesGood[ConversationIndex];
		else:
			return MessagesMeh[ConversationIndex]; 
	pass