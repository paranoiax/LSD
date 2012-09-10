GAMESTATE = "MENU"
currentLevel = 1
winTimer = 3
gameOverTimer = 1

if not love.filesystem.exists("save.lua") then
	love.filesystem.newFile("save.lua")
	love.filesystem.write("save.lua", 1)
end

maxLevel = love.filesystem.read("save.lua")
maxLevel = tonumber(maxLevel)

function continue()
	con_level = love.filesystem.read("save.lua")
	con_level = tonumber(con_level)
	currentLevel = con_level
	GAMESTATE = "INGAME"
	love.filesystem.load("main.lua")()
	love.load()
end

function newGame()
	currentLevel = 1
	love.filesystem.write("save.lua", currentLevel)
	GAMESTATE = "INGAME"
	love.filesystem.load("main.lua")()
	love.load()
end

function nextLevel(dt)
	if win == true then
		winTimer = winTimer - dt
	end
	if winTimer < 0 then
		if love.filesystem.exists("levels/level"..currentLevel + 1 ..".lua") then
			currentLevel = currentLevel + 1
			if currentLevel > maxLevel then
				love.filesystem.write("save.lua", currentLevel + 1)
			end
		else
			GAMESTATE = "MENU"
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