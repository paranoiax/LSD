function love.mousepressed(x,y,b)
	gs.mousepressed(x, y, b)
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

dbg = {
	draw = function()
		local y = 20
		local draw = {}
		for i,v in ipairs(dbg.draws) do
			draw[i] = {v, y}
			y = y + 20
		end
		
		love.graphics.setColor(0, 0, 0, 127)
		love.graphics.rectangle("fill", 7, 14, 350, y-6)
		
		love.graphics.setColor(255, 50,200)
		love.graphics.setFont(d)
		
		for i,v in ipairs(draw) do
			love.graphics.print(v[1], 10, v[2])
		end
	end,
	line = function(t) table.insert(dbg.draws, t) end
}

function love.draw()
	dbg.draws = {}
	
	local mx,my = love.mouse.getPosition()
    gs.draw(mx, my)

	if debugmode == true then
		pcall( function()
		
			dbg.line("Active Bodies: "..world:getBodyCount(),10,15)
			dbg.line("Frames per Second: "..love.timer:getFPS(),10 , 35 )
			dbg.line("Sensors count: " .. SensorsDestroyed .. "/" .. SensorsCount, 10, 45)
			
			dbg.draw()
		end )
	end
	
end