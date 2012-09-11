function love.mousepressed(x,y,b)
	if b == "l" and GAMESTATE == "INGAME" then
		aiming = true
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
	if key == "escape" then
		if GAMESTATE == "MENU" then
			love.event.push("quit")
		elseif GAMESTATE == "INGAME" then
			GAMESTATE = "MENU"
			love.filesystem.load("main.lua")()
			love.load()
		elseif GAMESTATE == "EDITOR" then
			Editor.keypressed(key, ...)
		end
	elseif key == "r" or key == "enter" or key == "return" or key == " " then
		if GAMESTATE == "INGAME" then
			love.filesystem.load("main.lua")()
			love.load()
		end
	end
end