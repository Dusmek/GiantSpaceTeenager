extends Node2D

onready var MessagesClass = preload("res://PhoneManager/NewMessageClass.gd").new(); 
onready var EMessageState = preload("res://PhoneManager/EMessageState.gd").new();
onready var ConversationClass = preload("res://PhoneManager/ConversationClass.gd").new();
onready var ConversationDataBase = preload("res://PhoneManager/ConversationsDataTable.gd").new();
 
var HiddenPositionX = -400;
var ShowedPositionX = 64;
var Hidden = true;

var ActualPhonePositionX = HiddenPositionX;
var GoToPhonePositionX = HiddenPositionX;
var SpeedPhonePositionX = 5;
var ActualPhonePositionY = 64;

var NewMessageTimer = 0;
var NewMessageTimeMin = 10;
var NewMessageTimeMax = 16;
  
var ActiveConversation;

var NewConversationTimer = 0;
var NewConversationTimeMin = 4;
var NewConversationTimeMax = 6;

var Messages = [];

var Buttons = []; 

var InputMessageProgress = 0;
var InputMessageProgressIncrease = 0.05;
var BadHitIndexes = [];		
var GoodHitIndex = 0;		 
var NextGoodHitIndex = 0;	
var InputCombo = 0.0; 
var InputComboTimer = 0.0;
var InputComboTime = 2.0;
var InputComboTimeReduction = 0.2;
var InputComboTimeMin = 1; 

var TimerFromNewMessageTicking = false;
var TimerFromNewMessage = 0;

var TimerFromRead = 0;
var TimerFormReadIsTicking = false;

var RandTimeFromSendTimer = 0;
var RandTimeFromSendMin = 4;
var RandTimeFromSendMax = 8;
var RandTimeFromSendB = false;
 
var ConversationTimer = 0;
var ConversationTimerMin = 4;
var ConversationTimerMax = 8;
var ConversationTimerB = false;

var FriendLevelOverall = 0;
var FriendLevelCurrentMessage = 0;
var FriendLevelFromWaiting = 0;
var FriendLevelFromWaitingMultiplier = -0.2
var FriendLevelCurrentMessageIncrease = 0.2;


func StartNewConversation():
	print("NewConversation");
	ConversationDataBase = load("res://PhoneManager/ConversationsDataTable.gd").new();
	ConversationDataBase.GenerateDatabase();
	ActiveConversation = ConversationDataBase.GetDatabase(); 
	FriendLevelOverall *= 0.75;
	AddNewMessage(false);
	pass

func GetNewestMessage():
	return Messages[Messages.size()-1]; 
	
func AddNewMessage(var Player):
	if( ActiveConversation != null ):
		if(ActiveConversation.IsAnotherMessage(Player)):
			Messages.push_back(MessagesClass);
			var Points = 0;
				  
			if( Player ):
				GetNewestMessage().UpdateMessageState(EMessageState.Send);
				Points = FriendLevelCurrentMessage;
			else:
				GetNewestMessage().UpdateMessageState(EMessageState.NewMessage);
				TimerFromNewMessage = 0;
				TimerFromNewMessageTicking = true; 
				Points = FriendLevelOverall
				NewInputHits(); 
				
			GetNewestMessage().UpdateMessageSource(Player);  
			GetNewestMessage().UpdateMessageText(ActiveConversation.GetActualConversationMessage(Player,Points)); 
			get_node("ViewportContainer/Screen").CreateNewMessage(GetNewestMessage()); 
			 
		else:
			NewConversationTimer = rand_range(NewConversationTimeMin, NewConversationTimeMax);
			ActiveConversation = null;
			
func _ready(): 
	NextGoodHitIndex = randi()%9;
	get_node("Buttons").rect_position = Vector2(102,400);
	Buttons = get_node("Buttons").get_children(); 
	for i in Buttons.size():
		Buttons[i].text = str(i+1); 
	pass 

func _process(delta):
	#InputCombo 
	if( InputComboTimer > 0 ):
		InputComboTimer -= delta; 
	else:
		InputCombo = 0;
		InputComboTimer = 0;
	
	get_node("InputComboTimer").value = InputComboTimer + 1; 
	get_node("InputComboTimer/Label").text = "COMBO x " + str(InputCombo);
	
	#position!
	ActualPhonePositionX = lerp(ActualPhonePositionX, GoToPhonePositionX, delta*SpeedPhonePositionX);
	position = Vector2( ActualPhonePositionX, ActualPhonePositionY); 
	  
	  
				
	ConverationMechanics(delta)
	#1
	NewMessageMechanics(delta)   
	FromNewMessageToRead(delta) 
	ReadMechanics(delta) 
	#ButtonInput(var Index): when u read u can write
	SendToSeenMechanics(delta)  
	#goto1
	CheckLastMessageInConversation(delta);
	
func CheckLastMessageInConversation(var delta): 
	if( ActiveConversation != null ):
		if(!ActiveConversation.IsAnotherMessage(true) && !ActiveConversation.IsAnotherMessage(false)):
			if( GetNewestMessage().CheckMessageState(EMessageState.Read)):
				GetNewestMessage().UpdateMessageState(EMessageState.Done);
				DisableInputHits();
				AddNewMessage(true);
				TimerFormReadIsTicking = false;
				RandTimeFromSendB = false;
				NewMessageTimer = 0;

func NewMessageMechanics(var delta):
	#NewMessangeMechanics
	if( NewMessageTimer < 0):
		if( Messages.size() == 0): 
			AddNewMessage(false);
			NewMessageTimer = rand_range(NewMessageTimeMin, NewMessageTimeMax);
		elif( GetNewestMessage().CheckMessageState(EMessageState.Seen)):
			AddNewMessage(false);
			NewMessageTimer = rand_range(NewMessageTimeMin, NewMessageTimeMax);
	else:
		NewMessageTimer -= delta;

func ReadMechanics(var delta): 
	#ticking of timer from read
	if( Messages.size() > 0 && TimerFormReadIsTicking):
		if( GetNewestMessage().CheckMessageState(EMessageState.Read)):
			TimerFromRead += delta;
			
	if( InputMessageProgress >= 1 && !GetNewestMessage().MessageSource ): 
		get_node("SendButton").self_modulate = Color(0,1,0);
	else:
		get_node("SendButton").self_modulate = Color(1,1,1);

func FromNewMessageToRead(var delta): 
	#checking if message is read
	if( Messages.size() > 0 && !Hidden):
		if( GetNewestMessage().CheckMessageState(EMessageState.NewMessage)):
			GetNewestMessage().UpdateMessageState(EMessageState.Read);
			TimerFormReadIsTicking = true; 
			
			TimerFromNewMessageTicking = false; 
			FriendLevelFromWaiting += TimerFromNewMessage * FriendLevelFromWaitingMultiplier;
			TimerFromNewMessage = 0;
			
			
	#Ticking of timer from new message
	if( Messages.size() > 0 && TimerFromNewMessageTicking):
		if( GetNewestMessage().CheckMessageState(EMessageState.NewMessage)):
			TimerFromNewMessage += delta; 
			
	#just display of new message
	if( Messages.size() > 0 ): 
		if( GetNewestMessage().CheckMessageState(EMessageState.NewMessage) && !GetNewestMessage().MessageSource ):
			get_node("ShowHideButton").text = "NEW_MESSAGE";
		else:
			get_node("ShowHideButton").text = "SHOW/HIDE";  

func ConverationMechanics(var delta):
	if( NewConversationTimer > 0 ):
		NewConversationTimer -= delta;
	else:
		if( ActiveConversation == null ):
			NewConversationTimer = 0;
			StartNewConversation();

func SendToSeenMechanics(var delta): 
	if( RandTimeFromSendB ):
		if( RandTimeFromSendTimer > 0 ):
			RandTimeFromSendTimer -= delta;
		else:
			if( GetNewestMessage().CheckMessageState(EMessageState.Send)):  
				FriendLevelOverall += FriendLevelCurrentMessage;
				FriendLevelCurrentMessage = 0;
				GetNewestMessage().UpdateMessageState(EMessageState.Seen);
			RandTimeFromSendB = false;
			
func _on_ShowHideButton_button_down(): 
	Hidden = !Hidden; 
	if( Hidden ):
		GoToPhonePositionX = HiddenPositionX;
	else: 
		GoToPhonePositionX = ShowedPositionX;    
	
func NewInputHits():     
	GoodHitIndex = NextGoodHitIndex;
	NextGoodHitIndex = randi()%9
	while(  NextGoodHitIndex == GoodHitIndex ):
		NextGoodHitIndex = randi()%9
		
	BadHitIndexes.clear();
	for i in rand_range(0,3):
		BadHitIndexes.push_back(GetBadIndex()); 
	
	for button in Buttons:
		button.self_modulate = Color(1,1,1);
		
	for bad in BadHitIndexes:
		Buttons[bad].self_modulate = Color(1,0,0);
		
	Buttons[GoodHitIndex].self_modulate = Color(0, 1, 0)
	Buttons[NextGoodHitIndex].self_modulate = Color(0.25, 0.5, 0.25); 
	
func DisableInputHits():
	GoodHitIndex = 0;
	NextGoodHitIndex = 0;
	BadHitIndexes.clear();

	for button in Buttons:
		button.self_modulate = Color(1,1,1);

func GetBadIndex():
	var NewBadIndex = 0;
	NewBadIndex = randi()%9;
	
	if( NewBadIndex == GoodHitIndex ):
		return GetBadIndex();
	for bad in BadHitIndexes:
		if( NewBadIndex == bad ): 
			return GetBadIndex();
		 
	return NewBadIndex;

func _on_SendButton_pressed(): 
	if( InputMessageProgress >= 1 && !GetNewestMessage().MessageSource ): 
		RandTimeFromSendTimer = rand_range(RandTimeFromSendMin, RandTimeFromSendMax);
		RandTimeFromSendB = true;
		 
		TimerFormReadIsTicking = false;
		FriendLevelFromWaiting += TimerFromRead/2 * FriendLevelFromWaitingMultiplier;
		TimerFromRead = 0;
		
		FriendLevelOverall += FriendLevelFromWaiting;
		FriendLevelFromWaiting = 0;
		
		InputCombo = 0;
		InputMessageProgress = 0; 
		AddNewMessage(true);  
		get_node("TextInput").SetUpNewMessage(InputMessageProgress);	 
	pass

func GetInputProgressBonus(var Index): 
	if( Index == GoodHitIndex ):  
		InputComboTimer = InputComboTime - InputCombo * InputComboTimeReduction;
		if( InputComboTime < InputComboTimeMin ):
			InputComboTime = InputComboTimeMin;
		InputCombo += 1;
		FriendLevelCurrentMessage += FriendLevelCurrentMessageIncrease + FriendLevelCurrentMessageIncrease/2 * InputCombo;
		return InputMessageProgressIncrease + InputMessageProgressIncrease/2 * InputCombo;

	for bad in BadHitIndexes:
		if( Index == bad ):
			InputCombo = 0;
			InputComboTimer = 0;
			FriendLevelCurrentMessage -= FriendLevelCurrentMessageIncrease*5;
			return InputMessageProgressIncrease/2; 
			
	FriendLevelCurrentMessage -= FriendLevelCurrentMessageIncrease;
	return InputMessageProgressIncrease;



func ButtonInput(var Index): 
	if( InputMessageProgress < 1 && !GetNewestMessage().MessageSource):
		InputMessageProgress += GetInputProgressBonus(Index); 
		if( InputMessageProgress > 1 ):
			InputMessageProgress = 1;
		get_node("TextInput").SetUpNewMessage(InputMessageProgress);	 
		if( InputMessageProgress == 1 ):
			DisableInputHits();
		else: 
			NewInputHits(); 
			
func _on_Button1_pressed(): 
	ButtonInput(0); 
 
func _on_Button2_pressed():
	ButtonInput(1);
 
func _on_Button3_pressed():
	ButtonInput(2);
 
func _on_Button4_pressed():
	ButtonInput(3);
 
func _on_Button5_pressed():
	ButtonInput(4);
 
func _on_Button6_pressed():
	ButtonInput(5);
 
func _on_Button7_pressed():
	ButtonInput(6);
 
func _on_Button8_pressed():
	ButtonInput(7);
 
func _on_Button9_pressed():
	ButtonInput(8);
 