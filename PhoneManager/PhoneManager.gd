extends Node2D

onready var MessagesClass = preload("res://PhoneManager/NewMessageClass.gd").new(); 
onready var EMessageState = preload("res://PhoneManager/EMessageState.gd").new();

var Texts = [];
  
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
 
var Messages = []; 
		 
var Buttons = []; 

var InputMessageProgress = 0;
var InputMessageProgressIncrease = 0.05;
var BadHitIndexes = [];		
var GoodHitIndex = 0;		 
var InputCombo = 0.0; 
var InputComboTimer = 0.0;
var InputComboTime = 2.0;
var InputComboTimeReduction = 0.2;
var InputComboTimeMin = 1; 

var TimerFromRead = 0;
var TimerFormReadIsTicking = false;

var RandTimeFromSendTimer = 0;
var RandTimeFromSendMin = 4;
var RandTimeFromSendMax = 8;
var RandTimeFromSendB = false;

func GetNewestMessage():
	return Messages[Messages.size()-1]; 
	
func AddNewMessage(var Source):
	Messages.push_back(MessagesClass);
	if( Source ):
		GetNewestMessage().UpdateMessageState(EMessageState.Send);
	else:
		GetNewestMessage().UpdateMessageState(EMessageState.NewMessage);
		 
	GetNewestMessage().UpdateMessageSource(Source);
	GetNewestMessage().UpdateMessageText(Texts[randi()%Texts.size()]);
	get_node("ViewportContainer/Screen").CreateNewMessage(GetNewestMessage());
	if( !Source ): 
		NewInputHits();
	
func _ready():
	get_node("Buttons").rect_position = Vector2(102,400);
	Buttons = get_node("Buttons").get_children(); 
	for i in Buttons.size():
		Buttons[i].text = str(i+1);
		
	Texts.push_back("Hello there my trusted friend");
	Texts.push_back("Oh hi!");
	Texts.push_back("Oh not you, fuck you!"); 
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
	
	if( Messages.size() > 0 ): 
		if( GetNewestMessage().CheckMessageState(EMessageState.NewMessage) && !GetNewestMessage().MessageSource ):
			get_node("ShowHideButton").text = "NEW_MESSAGE";
		else:
			get_node("ShowHideButton").text = "SHOW/HIDE";
		
	if( Messages.size() > 0 && !Hidden):
		if( GetNewestMessage().CheckMessageState(EMessageState.NewMessage)):
			GetNewestMessage().UpdateMessageState(EMessageState.Read);
			TimerFormReadIsTicking = true;
			
	if( Messages.size() > 0 && TimerFormReadIsTicking):
		if( GetNewestMessage().CheckMessageState(EMessageState.Read)):
			TimerFromRead += delta;
			
	if( InputMessageProgress >= 1 && !GetNewestMessage().MessageSource ): 
		get_node("SendButton").self_modulate = Color(0,1,0);
	else:
		get_node("SendButton").self_modulate = Color(1,1,1);
		
	if( RandTimeFromSendB ):
		if( RandTimeFromSendTimer > 0 ):
			RandTimeFromSendTimer -= delta;
		else:
			if( GetNewestMessage().CheckMessageState(EMessageState.Send)):
				GetNewestMessage().UpdateMessageState(EMessageState.Seen);
			RandTimeFromSendB = false;
			
	
			
func _on_ShowHideButton_button_down(): 
	Hidden = !Hidden; 
	if( Hidden ):
		GoToPhonePositionX = HiddenPositionX;
	else: 
		GoToPhonePositionX = ShowedPositionX;    

func NewInputHits():    
	GoodHitIndex = randi()%9;   
	BadHitIndexes.clear();
	for i in rand_range(0,3):
		BadHitIndexes.push_back(GetBadIndex()); 
	
	for button in Buttons:
		button.self_modulate = Color(1,1,1);
		
	for bad in BadHitIndexes:
		Buttons[bad].self_modulate = Color(1,0,0);
		
	Buttons[GoodHitIndex].self_modulate = Color(0, 1, 0); 
	
func DisableInputHits():
	GoodHitIndex = 0;
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
		return InputMessageProgressIncrease + InputMessageProgressIncrease/2 * InputCombo;

	for bad in BadHitIndexes:
		if( Index == bad ):
			InputCombo = 0;
			InputComboTimer = 0;
			return InputMessageProgressIncrease/2; 
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
 