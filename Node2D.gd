extends Node2D

var minx = 100
var maxx = 700
var miny = 100
var maxy = 700

var maxinstupdateperframe = 25*500;
var currpostponeind = 0

var allinst = []

class obj :
	var position=Vector2(0,0)
	var speed = Vector2(0,0)
	var force = Vector2(0,0)
	var mass = 0.2
	var radius = 1
	var currind=0
	var instances=[]
	var biggestdist=0
	func init(inst):
		instances.append(inst)
		position = inst.position
		pass
	func update(delta):#tu sie bedzie dzial update wszystkich pozycji dzieci
		speed+=force*delta
		var dp = speed*delta
		position+=dp
		for inst in instances:
			inst.position += dp
			inst.force-=inst.speed*inst.speed.length()/20
			inst.myupdate(delta)
			inst.force=Vector2(0,0)
		var koniec = min(instances.size(),currind+60)
		for inst1 in range(currind,koniec):
			instances[inst1].force+=(position-instances[inst1].position)*4
			for inst2 in instances:
				if instances[inst1]==inst2:
					continue
				var d = instances[inst1].position-inst2.position
				var lens = d.length()
				if lens>biggestdist:
					biggestdist=lens
				if lens<6:
					var n = d.normalized()
					instances[inst1].force+=n*(12-lens)*4
					inst2.force-=n*(12-lens)*4
		currind = koniec
		if currind>=instances.size():
			radius=biggestdist*0.45
			biggestdist=0
			if instances.size()==1:
				radius=0.3
			currind=0
		pass

# Called when the node enters the scene tree for the first time.
func _ready():
	var el = load("res://element.tscn")
		
	for i in range(1000):
		var inst = el.instance()
		inst.position = Vector2(rand_range(minx+200,maxx-200),rand_range(miny+200,maxy-200))
		var o = obj.new()
		o.init(inst)
		add_child(inst)
		allinst.append(o)
		
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
			var i1 = allinst[i]
			var i2 = allinst[j]
			
			var p1 = i1.position
			var p2 = i2.position
			var l = (p1-p2).length()
			if l <= i1.radius+i2.radius:
				toremove.append(j)
				var masssum = (i1.mass + i2.mass)
				i1.position=(i1.mass*i1.position + i2.mass*i2.position)/masssum
				i1.speed=(i1.mass*i1.speed + i2.mass*i2.speed)/masssum
				i1.force=(i1.mass*i1.force + i2.mass*i2.force)/masssum
				i1.mass+=i2.mass
				for p in i2.instances:  
					i1.instances.append(p)
				i2.instances.clear()
			else:
				var f = (p1-p2).normalized()*250/max(25,(l*l))
				i1.force -= i2.mass *f
				i2.force += i1.mass *f
	
	for j in range(allinst.size()):
			var i = allinst.size() - 1 - j
			if allinst[i].instances.size() ==0:
				allinst.remove(i)
		
	for i in range(allinst.size()):
		allinst[i].update(delta)
		
		if(Input.is_mouse_button_pressed(BUTTON_LEFT)):
			var p = get_viewport().get_mouse_position() - allinst[i].position
			var l = p.length()
			allinst[i].force = p.normalized()*250000/(max(250,p.length()*p.length()))
		else:
			allinst[i].force=Vector2(0,0)
			
		var sr = Vector2(maxx+minx, maxy+miny)/2
		var lsa = allinst[i].position -sr
		
		var ls2 = lsa.length_squared()
		if ls2 > (maxx-minx)*(maxx-minx)/4:
			allinst[i].position = sr+lsa.normalized()*(maxx-minx)/2
			allinst[i].speed *= -0.7
		var lsn = (allinst[i].position -sr).normalized()
		allinst[i].force += Vector2(lsn.y,-lsn.x)*0.001*ls2/max(1,allinst[i].speed.length_squared())
		
	print("start: " + str(currpostponeind) + " " + str(koniec))
	currpostponeind=koniec+1
	if currpostponeind>=allinst.size():
		currpostponeind=0
	pass


