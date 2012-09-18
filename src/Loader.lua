GAMESTATE = "MENU"
winTimer = 3
gameOverTimer = 1

function nextLevel(dt)
	if win == true then
		winTimer = winTimer - dt
	end
	if winTimer < 0 then
		if love.filesystem.exists("levels/" .. currentPack .."/level"..currentLevel + 1 ..".lua") then
			currentLevel = currentLevel + 1
			if currentLevel > maxLevel then
				love.filesystem.write("save.lua", currentLevel)
			end
		else
			GAMESTATE = "MENU"
			currentLevel = 1
			love.filesystem.write("save.lua", currentLevel)
			love.filesystem.load("main.lua")()
			love.load()
		end
		love.filesystem.load("main.lua")()
		love.load()		
	end	
end

function game_over(dt)
	if gameOver == true then
		gameOverTimer = gameOverTimer - dt * 1.5
	end
	if gameOverTimer < 0 then
		currentLevel = currentLevel		
		love.filesystem.load("main.lua")()
		love.load()
	end
end