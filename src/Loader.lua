GAMESTATE = "MENU"
winTimer = 3
gameOverTimer = 1

function nextLevel(dt)
	if win == true then
		winTimer = winTimer - dt
	end
	if winTimer < 0 and not testmap then
		if love.filesystem.exists("levels/" .. currentPack .."/level"..currentLevel + 1 ..".lua") then
			currentLevel = currentLevel + 1
			if currentLevel > maxLevel then
				love.filesystem.write("save.lua", currentLevel)
			end
		else
			-- DEMO ONLY
			if demo then
				if not love.filesystem.exists("completed.lua") then
					love.filesystem.newFile("completed.lua")
					love.filesystem.write("completed.lua", "true")
				end
			end
			-- END DEMO ONLY
			GAMESTATE = "MENU"
			currentLevel = 1
			love.filesystem.write("save.lua", currentLevel)
			love.filesystem.load("main.lua")()
			love.load()
		end
		love.filesystem.load("main.lua")()
		love.load()		
	elseif winTimer < 0 and testmap then
		testmap = true
		love.filesystem.load("main.lua")()
		love.load()	
	end
end

function game_over(dt)
	if gameOver == true then
		gameOverTimer = gameOverTimer - dt * 1.5
		slowmo:start()
		shake = false
	end
	if gameOverTimer < 0 then
		currentLevel = currentLevel		
		love.filesystem.load("main.lua")()
		love.load()
	end
end