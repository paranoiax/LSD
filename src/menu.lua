Menu = gs:new()

function Menu:init()
	button = {}
	ball_menu_image = love.graphics.newImage("images/ball_anim_menu.png")
	ball_menu_anim = newAnimation(ball_menu_image, 192, 192, 0.1, 0)
	
	local menu = {
		{"New Game", "new_game"},
		{"Map Editor", "mapedit"},
		{"Quit", "quit"}
	}
	
	local menuY = screenHeight / 4 * 3-85
	for i,v in ipairs(menu) do
		local x, y, text, id = screenWidth/2 - f:getWidth(v[1])/2, menuY, v[1], v[2]
		table.insert(button, {x = x, y = y, text = text, id = id, mouseover = false})
		menuY = menuY + 85
	end
end

function Menu:enter(old)
	love.mouse.setVisible(false)
	if (currentLevel or 0) > 1 then
		table.insert(button, 1, {x=screenWidth / 2 - f:getWidth("Continue") / 2,y=screenHeight / 4 * 3 -85-85,text="Continue", id="continue"})
	end
	
	TEsound.stop("music")
	if options.audio.music then
		TEsound.playLooping("sounds/music.mp3", "music", nil, 0.7) --to lower volume as intended without need for additonal line
	end
end

function Menu:update(dt)
	ball_menu_anim:update(dt)
	
	for i,v in ipairs(button) do		
		if love.mouse:getX() < v.x + f:getWidth(v.text) and
		love.mouse:getX() > v.x and
		love.mouse:getY() < v.y + f:getHeight(v.text) and
		love.mouse:getY() > v.y then
			v.mouseover = true
		else
			v.mouseover = false
		end
	end
end

function Menu:keypressed(key, unicode)
	if key == "escape" then
		love.event.push("quit")
	end
end

function Menu:mousereleased(x, y, b)
	if b == "l" then
		for i,v in ipairs(button) do
			if (x > v.x) and (x < v.x + f:getWidth(v.text)) and (y > v.y) and (y < v.y + f:getHeight(v.text)) then
				if v.id == "quit" then
					love.event.push("quit")
				elseif (v.id == "continue") or (v.id == "new_game") then
					currentLevel = (v.id == "continue") and tonumber(love.filesystem.read("save.lua")) or 1
					currentPack = (v.id == "continue") and "original" or "original" -- the first "original" you can load the active pack
					love.filesystem.write("save.lua", currentLevel)
					gs.switch(Game, currentPack, currentLevel)
				elseif v.id == "mapedit" then
					gs.switch(Editor)
				end
			end
		end
	end
end

function Menu:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(bg,0,0,0,scaleX,scaleY)
	ball_menu_anim:draw(screenWidth / 2 - 96, screenHeight / 2 - 250)

	love.graphics.setFont(e)
	love.graphics.setColor(10,10,10)
	love.graphics.printf("Little Sticky Destroyer",2, 82, screenWidth, "center")
	love.graphics.setColor(217,177,102)
	love.graphics.printf("Little Sticky Destroyer",0, 80, screenWidth, "center")
	
	for i,v in ipairs(button) do		
		love.graphics.setFont(f)
		love.graphics.setColor(10,10,10)
		love.graphics.print(v.text, v.x, v.y)
		if v.mouseover == true then
			love.graphics.setColor(217,177,102)
			love.graphics.print(v.text, v.x -2, v.y -2)
		end
	end
	
	love.graphics.setColor(255,255,255)
	love.graphics.draw(cursorImg, love.mouse.getX(), love.mouse.getY())	
end