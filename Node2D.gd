extends Node2D

#var minx = 100
#var maxx = 700
#var miny = 100
#var maxy = 700

var minx = 0
var maxx = 1000
var miny = 0
var maxy = 1000

var maxinstupdateperframe = 25*500;
var currpostponeind = 0

var allinst = []

class obj :
	var position=Vector2(0,0)
	var speed = Vector2(0,0)
	var force = Vector2(0,0)
	var angle = 0
	var angularspeed = 0
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
		var koniec = min(instances.size(),currind+40)
		for inst1id in range(currind,koniec):
			var inst1 = instances[inst1id]
			
			inst1.force+=(position-inst1.position)*(1+0.8*(3-inst1.type)*(3-inst1.type))
			var any = false
			for inst2 in instances:
				if inst1==inst2:
					continue
				var d = inst1.position-inst2.position
				var lens = d.length()
				if lens>biggestdist:
					biggestdist=lens
				if lens<6:
					any=true
					var n = d.normalized()*(12-lens)
					if inst1.type == inst2.type and inst2.type==1:
						var stren = 3
						inst1.force+=n*stren
						inst2.force-=n*stren
					else:
						inst1.force+=n*4
						inst2.force-=n*4
					inst2.speed*=0.95
					
		currind = koniec
		if currind>=instances.size():
			radius=radius *(1-delta) + delta * biggestdist*0.45
			biggestdist=0
			if instances.size()==1:
				radius=0.3
			currind=0
		pass

# Called when the node enters the scene tree for the first time.
func _ready():
	var el = load("res://element.tscn")
	var maxr = (maxx-minx)*0.5
	var Voronoi = []
	var Vtypes = []
	randomize()
	for i in range(10):
		var temp = floor(rand_range(0,1)*4)
		print(temp)
		Vtypes.append(temp);
		Voronoi.append(Vector2(rand_range(minx,maxx),rand_range(miny,maxy)))
	var sr = Vector2(maxx+minx,maxy+miny)*0.5
	for i in range(2000):
		var inst = el.instance()
		var r = rand_range(1,maxr)
		r= (maxr-r)
		r*=r/maxr
		r = maxr-r
		var a = rand_range(0,2*PI)
		inst.position = Vector2(0,1).rotated(a) * r + sr
		var t = 0
		var closd = 10000
		for vi in range(Voronoi.size()):
			var cd = (Voronoi[vi]-inst.position).length()
			if cd<closd:
				t = Vtypes[vi]
				print(t)
				closd = cd
		inst.init(t) 
		var o = obj.new()
		o.init(inst)
		add_child(inst)
		allinst.append(o)
		
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(1/max(0.01,delta))
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
					p.speed = i2.speed
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
		
		if(Input.is_mouse_button_pressed(BUTTON_LEFT) or Input.is_mouse_button_pressed(BUTTON_RIGHT)):
			var p = get_viewport().get_mouse_position() - allinst[i].position
			var l = p.length()
			if Input.is_mouse_button_pressed(BUTTON_RIGHT):
				var s=0
				if l<200:
					s=1
				allinst[i].force = -allinst[i].speed*s#(max(0,(200-l)/200))
			else:
				allinst[i].force = p*2500000/(max(25000,p.length_squared()*p.length_squared()))
		else:
			allinst[i].force=Vector2(0,0)
			
		var sr = Vector2(maxx+minx, maxy+miny)/2
		var lsa = allinst[i].position -sr
		
		var ls2 = lsa.length()-allinst[i].radius
		if ls2 > (maxx-minx)/2:
			allinst[i].speed *= -0.5
		
	print("start: " + str(currpostponeind) + " " + str(koniec))
	currpostponeind=koniec+1
	if currpostponeind>=allinst.size():
		currpostponeind=0
	pass


