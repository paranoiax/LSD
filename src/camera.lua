camera = {}
camera.x = 0
camera.y = 0
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0
camera.speed = 7.25

function camera:set()
love.graphics.push()
love.graphics.rotate(-self.rotation)
love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
love.graphics.translate(-self.x, -self.y)
end

function camera:unset()
love.graphics.pop()
end

function camera:move(dx, dy)
self.x = self.x + (dx or 0)
self.y = self.y + (dy or 0)
end

function camera:rotate(dr)
self.rotation = self.rotation + dr
end

function camera:scale(sx, sy)
sx = sx or 1
self.scaleX = self.scaleX * sx
self.scaleY = self.scaleY * (sy or sx)
end

function camera:setPosition(x, y)
self.x = x or self.x
self.y = y or self.y
end

function camera:setScale(sx, sy)
self.scaleX = sx or self.scaleX
self.scaleY = sy or self.scaleY
end

function camera:timer(dt)
	if shake == true then
		camera.time = camera.time - dt * 4
	end
	if camera.time < 1 then
		camera.time = 3
		shake = false
	end
end

function camera.shake()
	if camera.time > 1 and shake == true then
		love.graphics.translate(math.random(15*2)-15, math.random(15*2)-15)
	end
end