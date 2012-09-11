function love.mousepressed(x,y,b)
	if GAMESTATE == "INGAME" then
		if b == "l" then
			aiming = true
		elseif (b == "wu") or (b == "wd") then
			local append = (b=="wu") and .01 or -.01
			camera.zoom = camera.zoom + append
			if (camera.zoom > 1.5) or (camera.zoom < .5) then
				camera.zoom = camera.zoom - append
			end
		end
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