extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var minx = 100
var maxx = 700
var miny = 100
var maxy = 700

var maxinstupdateperframe = 25*500;
var currpostponeind = 0

var allinst = []
var allspeeds = []
var allforces = []
var allmases = [];

class obj :
	var position
	var instances=[]
	#func update():
		#tu sie bedzie dzial update wszystkich pozycji dzieci
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	var el = load("res://element.tscn")
		
	for i in range(3500):
		var inst = el.instance()
		var o = obj.new()
		allinst.append(inst)
		allmases.append(1);
		allforces.append(Vector2(0,0))
		inst.position = Vector2(rand_range(minx,maxx),rand_range(miny,maxy))
		#allspeeds.append(Vector2(0,0))
		allspeeds.append(Vector2(inst.position.y-((miny+maxy)/2),-inst.position.x+((minx+maxx)/2))/10)
		add_child(inst)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(1/max(0.01,delta))
	var toincrease = []
	var toremove = []
	var count = allinst.size()
	
	var test = sqrt(max(0,(count-currpostponeind)*(count-currpostponeind)-2*maxinstupdateperframe))
	var koniec = count - floor(test)
	for i in range(currpostponeind,min(koniec,count)):
		for j in range(i+1,allinst.size()):
			var p1 = allinst[i].position
			var p2 = allinst[j].position
			var l = (p1-p2).length()
			if l <= allinst[i].scale.x*20+allinst[j].scale.x*20:
				toremove.append(j)
				var masssum = (allmases[i] + allmases[j])
				allinst[i].position=(allmases[i]*allinst[i].position + allmases[j]*allinst[j].position)/masssum
				allspeeds[i]=(allmases[i]*allspeeds[i] + allmases[j]*allspeeds[j])/masssum
				allforces[i]=(allmases[i]*allforces[i] + allmases[j]*allforces[j])/masssum
				allmases[i]+=allmases[j]
			else:
				var f = (p1-p2).normalized()*250/max(25,(l*l))
				allforces[i] -= allmases[j] *f
				allforces[j] += allmases[i] *f
	
	#zdaza sie tu problem jak dodamy dwa razy to samo do tablicy toremove
	toremove.sort()
	for j in range(toremove.size()):
		if toremove.find(toremove[j]) != j:
			continue
		else:
			var i = toremove.size() - 1 - j
			allinst[toremove[i]].get_parent().remove_child(allinst[toremove[i]])
			allinst.remove(toremove[i])
			allmases.remove(toremove[i])
			allspeeds.remove(toremove[i])
			allforces.remove(toremove[i])
		
		
	for i in range(allinst.size()):
		allspeeds[i]+=allforces[i]*delta
		allinst[i].position += allspeeds[i]*delta
		var s = sqrt(allmases[i])
		allinst[i].scale = Vector2(s,s)*0.05
		if allinst[i].position.x>maxx or allinst[i].position.x<minx:
			allinst[i].position.x = clamp(allinst[i].position.x,minx,maxx)
			allspeeds[i].x*=-0.7
		if allinst[i].position.y>maxy or allinst[i].position.y<miny:
			allinst[i].position.y = clamp(allinst[i].position.y,miny,maxy)
			allspeeds[i].y*=-0.7
		if(Input.is_mouse_button_pressed(BUTTON_LEFT)):
			var p = get_viewport().get_mouse_position() - allinst[i].position
			var l = p.length()
			allforces[i] = p.normalized()*250000/(max(250,p.length()*p.length()))
		else:
			allforces[i]=Vector2(0,0)
		
	print("start: " + str(currpostponeind) + " " + str(koniec))
	currpostponeind=koniec+1
	if currpostponeind>=allinst.size():
		currpostponeind=0
	pass
