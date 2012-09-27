function love.mousepressed(x,y,b)
	loveframes.mousepressed(x, y, b)
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
	loveframes.mousereleased(x, y, b)
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

function love.keyreleased(key)
	loveframes.keyreleased(key)
end

function love.keypressed(key, ...)
	loveframes.keypressed(key, ...)
	if GAMESTATE == "EDITOR" then
		Editor.keypressed(key, ...)
	elseif GAMESTATE == "INGAME" then
		if key == "r" or key == "enter" or key == "return" or key == " " then
			love.filesystem.load("main.lua")()
			love.load()
		elseif key == "escape" and not testmap then
			GAMESTATE = "MENU"
			love.filesystem.load("main.lua")()
			love.load()
		elseif key == "escape" and testmap then
			slowmo.time = {t = 1}
			GAMESTATE = "EDITOR"
		end
	elseif GAMESTATE == "MENU" then
		if key == "escape" then
			love.event.push("quit")
		end
	elseif GAMESTATE == "OPTIONS" and key=="escape" then
		GAMESTATE = "MENU"
		closeOptions()
	end
end

function Editor.mousepressed(x, y, b)
	if b == 'l' then
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
				table.insert(RectangleEditor2, {x = x, y = y, w = gui.w, h = gui.h})
			elseif currentObject == "sensor" then
				table.insert(sensors, {x = x, y = y, w = gui.w, h = gui.h})
				table.insert(RectangleEditor, {x = x, y = y, w = gui.w, h = gui.h})
			end		
		end
		
	end
	if b == 'r' then
		collision.Remove(x + camera.x, y + camera.y)
	end	
end

function love.keyboard.isShiftDown()
	return love.keyboard.isDown"lshift" or love.keyboard.isDown"rshift"
end
function love.keyboard.isAltDown()
	return love.keyboard.isDown"lalt" or love.keyboard.isDown"ralt"
end

function Editor.keypressed(key)

	if key == "escape" then
		Editor.unload()
		testmap = false
	end
	
	local concentration = love.keyboard.isShiftDown() and 4 or (love.keyboard.isAltDown() and 1 or 2)
	
	if key == 'a' and gui.w > (10*concentration) then
		gui.w = gui.w - (10*concentration)
	end
	if key == 'd' then
		gui.w = gui.w + (10*concentration)
	end
	if key == 'w' and gui.h > (10*concentration) then
		gui.h = gui.h - (10*concentration)
	end
	if key == 's' then
		gui.h = gui.h + (10*concentration)
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
	if key == 'p' then
		local f = love.filesystem.newFile('maps/testmap.lua')
		f:open('w')
			f:write(generateCode())
		f:close()
		testmap = true
		GAMESTATE = "INGAME"
		love.filesystem.load("main.lua")()
		love.load()
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

function mouseScroll(x,y)
	x, y = love.mouse.getPosition()
	if x < 30 then
		camera.x = camera.x - 100 * dt * Editor.speed
	end
	if y < 30 then
		camera.y = camera.y - 100 * dt * Editor.speed
	end
	if x > screenWidth - 30 then
		camera.x = camera.x + 100 * dt * Editor.speed
	end
	if y > screenHeight - 30 then
		camera.y = camera.y + 100 * dt * Editor.speed
	end
end