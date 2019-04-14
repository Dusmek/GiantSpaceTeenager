extends Control
 
var Width = 330;
var WidthSet = false; 

var Position = Vector2(0,300);
 
var RandomTexts = [];

var Progress = 0;

func _ready():
	RandomTexts.push_back("bas stfd f78tfasdt ty8agsd 8f?"); 
	SetUpNewMessage(0);
	
func _process(delta):  
	rect_position = Position;
	#SetWidth(); 
  
func SetUpNewMessage(var Progress_):
	Progress = Progress_;
	get_node("Label").rect_size = Vector2(Width, 0);
	get_node("Label").text = GetTextProgress();  
	get_node("TextureProgress").value = 1+Progress;
	

func GetTextProgress():
	var CharArray = []; 
	for string in RandomTexts[0]:
		CharArray.push_back(string);
	
	var OutputText = "";
	for i in (int((CharArray.size())*Progress)-1):
		OutputText += str(CharArray[i]);
		
	return OutputText;