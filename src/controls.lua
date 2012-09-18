function love.mousepressed(x,y,b)
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