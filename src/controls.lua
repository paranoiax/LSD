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
		pcall( function()
		--camera:unset()
		love.graphics.setColor(255,50,200)
		love.graphics.setFont(d)
		---[[
		love.graphics.print("Mouse-Ball Distance: "..distanceFrom(objects.ball.body:getX(),objects.ball.body:getY(),love.mouse:getX() ,love.mouse.getY() ),10 ,15 )
		love.graphics.print("Active Bodies: "..world:getBodyCount(),10,35)
		love.graphics.print("Particles per Explosion: "..limit,10 ,55 )
		for q = 1, #Sensor do 
			if Sensor[q].touching == true then
				love.graphics.print("Position of next Explosion: "..math.floor(collX + .5)..", "..math.floor(collY + .5),10 ,115 )
			end
		end--]]--
		love.graphics.print("Frames per Second: "..love.timer:getFPS(),10 , 75 )
		love.graphics.print('Press "R" to restart!',10 , 95 )
		love.graphics.print("Time until explosion: "..explosionTime,10 , 135 )
		love.graphics.print("Max Level: "..love.filesystem.read("save.lua"),10 , 155 )
		love.graphics.print("Current Level: "..currentLevel,10 , 175 )
		love.graphics.print("Current Gamestate: "..GAMESTATE,10 , 195 )
		end )
	end
	
end