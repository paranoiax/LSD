function love.mousepressed(x,y,b)
	if GAMESTATE == "EDITOR" then
		Editor.mousepressed(x, y, b)
	end
	if b == "l" and GAMESTATE == "INGAME" then
		aiming = true
	end
	if b == "mu" and GAMESTATE == "INGAME" then
		camera.setScale(1.1)
	end
end

function love.mousereleased(x,y,b)
	if b == "l" and GAMESTATE == "INGAME" then
		ball_launch(x,y)
		aiming = false
		if objects.ball.canJump == true then
			objects.ball.sticky = false
		end				
	end
	if b == "l" and GAMESTATE == "MENU" then
		button_click(x,y)
	end
end

function love.keypressed(key, ...)
	if GAMESTATE == "EDITOR" then
		Editor.keypressed(key, ...)
	elseif GAMESTATE == "INGAME" then
		if key == "r" or key == "enter" or key == "return" or key == " " then
			love.filesystem.load("main.lua")()
			love.load()
		elseif key == "escape" then
			GAMESTATE = "MENU"
			love.filesystem.load("main.lua")()
			love.load()
		end
	elseif GAMESTATE == "MENU" then
		if key == "escape" then
			love.event.push("quit")
		end
	end
end

function Editor.mousepressed(x, y, b)
	if b == 'l' and y < 769 then
		x, y = x + camera.x, y + camera.y
		if currentObject == "player" and #player < 1 then
			player.isSet = true
			playerX = x
			playerY = y
		end
		x, y = (math.floor((x / 10)) * 10), (math.floor((y / 10)) * 10) --snap to grid		
		
		colliding = collision.checkInsert(x, y)		
		if not colliding then
			table.insert(object, {x = x, y = y, w = gui.w, h = gui.h})
			if currentObject == "wall" then
				table.insert(walls, {x = x, y = y, w = gui.w, h = gui.h})
			elseif currentObject == "sensor" then
				table.insert(sensors, {x = x, y = y, w = gui.w, h = gui.h})
			end		
		end
		
	end
	if b == 'r' then
		collision.Remove(x + camera.x, y + camera.y)
	end
	if b == 'l' and y >= 769 then
		if x < love.graphics.getWidth()*0.2 then
			gui.focus = 'w'
		elseif x < love.graphics.getWidth()*0.4 then
			gui.focus = 'h'
		end
	end
end

function Editor.keypressed(key)
	if key == "escape" then
		Editor.unload()
	end
	if key == 'a' and gui.w >10 then
		gui.w = gui.w - 10
	end
	if key == 'd' then
		gui.w = gui.w + 10
	end
	if key == 'w' then
		gui.h = gui.h + 10
	end
	if key == 's' and gui.h > 10 then
		gui.h = gui.h - 10
	end
	if key == 'r' then
		if currentObject == "wall" then
			currentObject = "sensor"
		elseif currentObject == "sensor" then
			currentObject = "player"
		elseif currentObject == "player" then
			currentObject = "wall"
		end
	end
	if key == 'return' and maps < 10 then
		local f = love.filesystem.newFile('maps/level'..maps+1 .. '.lua')
		f:open('w')
			f:write(generateCode())
		f:close()
		maps = maps + 1
	end
	if tonumber(k) and love.keyboard.isDown('o') then
		love.filesystem.remove('maps/level'..k..'.lua') --If you don't understand this code, you should be flipping burgers instead.
	end
	if (love.keyboard.isDown('backspace') or love.keyboard.isDown('delete')) and maps > 0 then
		love.filesystem.remove('maps/level'..maps..'.lua')
		maps = maps - 1
	end
end