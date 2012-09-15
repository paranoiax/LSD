function love.mousepressed(x,y,b)
	gs.mousepressed(x, y, b)
	if b == "l" and GAMESTATE == "INGAME" then
		aiming = true
	end	
end

function love.mousereleased(x,y,b)
	gs.mousereleased(x, y, b)
end

function love.keypressed(key, unicode)
	gs.keypressed(key, unicode)
end

function love.update(dt)
	TEsound.cleanup(dt)
	cron.update(dt)
	tween.update(dt)
	gs.update(dt)
end

function love.draw()
	local mx,my = love.mouse.getPosition()
    gs.draw(mx, my)

	if debugmode == true then
		love.graphics.setColor(255,50,200)
		love.graphics.setFont(d)
		--[[love.graphics.print("Mouse-Ball Distance: "..distanceFrom(objects.ball.body:getX(),objects.ball.body:getY(),love.mouse:getX() + camera.x,love.mouse.getY() + camera.y),10 + camera.x,15 + camera.y)
		love.graphics.print("Active Bodies: "..world:getBodyCount(),10 + camera.x,35 + camera.y)
		love.graphics.print("Particles per Explosion: "..limit,10 + camera.x,55 + camera.y)
		for q = 1, #Sensor do 
			if Sensor[q].touching == true then
				love.graphics.print("Position of next Explosion: "..math.floor(collX + .5)..", "..math.floor(collY + .5),10 + camera.x,115 + camera.y)
			end
		end--]]--
		love.graphics.print("Frames per Second: "..love.timer:getFPS(),10 + camera.x, 75 + camera.y)
		love.graphics.print('Press "R" to restart!',10 + camera.x, 95 + camera.y)
		--love.graphics.print("Time until explosion: "..explosionTime,10 + camera.x, 135 + camera.y)
		love.graphics.print("Max Level: "..love.filesystem.read("save.lua"),10 + camera.x, 155 + camera.y)
		love.graphics.print("Current Level: "..currentLevel,10 + camera.x, 175 + camera.y)
		love.graphics.print("Current Gamestate: "..GAMESTATE,10 + camera.x, 195 + camera.y)
	end
	
end