local collision = {}
--BoundingBox!
collision.check = function(ax1,ay1,aw,ah, bx1,by1,bw,bh)
	local ax2,ay2,bx2,by2 = ax1 + aw, ay1 + ah, bx1 + bw, by1 + bh
	return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
end
--/BoundingBox!

collision.checkInsert = function(x, y)
	for i,v in pairs(object) do
		colliding = collision.check(x,y,gui.w,gui.h, v.x,v.y,v.w,v.h)
		if colliding then break end
	end
	return colliding
end

collision.Remove = function(x, y)
	for i,v in ipairs(walls) do
		local colliding = collision.check(x,y,1,1, v.x,v.y,v.w,v.h)
		if colliding then
			table.remove(walls, i)
		end
	end
	for i,v in ipairs(sensors) do
		local colliding = collision.check(x,y,1,1, v.x,v.y,v.w,v.h)
		if colliding then
			table.remove(sensors, i)
		end
	end
	for i,v in ipairs(object) do
		local colliding = collision.check(x,y,1,1, v.x,v.y,v.w,v.h)
		if colliding then
			table.remove(object, i)
		end
	end
	for i,v in ipairs(RectangleEditor) do
		local colliding = collision.check(x,y,1,1, v.x,v.y,v.w,v.h)
		if colliding then
			table.remove(RectangleEditor, i)
		end
	end
	for i,v in ipairs(RectangleEditor2) do
		local colliding = collision.check(x,y,1,1, v.x,v.y,v.w,v.h)
		if colliding then
			table.remove(RectangleEditor2, i)
		end
	end
end
return collision