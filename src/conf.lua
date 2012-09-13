<<<<<<< HEAD
-- also serves as a utility file
function love.conf(t)

	t.screen.width = 0
	t.screen.height = 0
	t.author = "Kai Hossbach (paranoiax)"	
	t.title = 'LSD - Little Sticky Destroyer'
	t.screen.vsync = false
	t.screen.fullscreen= false
	t.screen.fsaa = 2
	t.identity = "LSD"
	t.console = false
	t.release = false

end

function intersect(x, y, w, h, x2, y2)
	local endx, endy = x+w, y+h
	return (x2<endx) and (x2>x) and (y2>y) and (y2<endy)
end

function distanceFrom(x1,y1,x2,y2)
	local distance = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) * 0.55
	distance = distance>255 and 255 or distance
	return math.floor(distance + .5)
=======
-- also serves as a utility file
function love.conf(t)

	t.screen.width = 0
	t.screen.height = 0
	t.author = "Kai Hossbach (paranoiax)"	
	t.title = 'LSD - Little Sticky Destroyer'
	t.screen.vsync = false
	t.screen.fullscreen= false
	t.screen.fsaa = 2
	t.identity = "LSD"
	t.console = false
	t.release = false

end

function intersect(x, y, w, h, x2, y2)
	local endx, endy = x+w, y+h
	return (x2<endx) and (x2>x) and (y2>y) and (y2<endy)
end

function distanceFrom(x1,y1,x2,y2)
	local distance = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) * 0.55
	distance = distance>255 and 255 or distance
	return math.floor(distance + .5)
>>>>>>> Rolled back
end