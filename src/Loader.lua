currentLevel = 1
winTimer = 3
gameOverTimer = 3

if not love.filesystem.exists("save.lua") then
	love.filesystem.newFile("save.lua")
	love.filesystem.write("save.lua", 1)
end

maxLevel = love.filesystem.read("save.lua")
maxLevel = tonumber(maxLevel)

function nextLevel(dt)
	if win == true then
		winTimer = winTimer - dt		
	end
	if winTimer < 0 then
		if love.filesystem.exists("levels/level"..currentLevel + 1 ..".lua") then
			currentLevel = currentLevel + 1
		else
			currentLevel = 1
		end
		TEsound.stop("music")
		love.filesystem.load("main.lua")()
		love.load()		
	end	
end

function game_over(dt)
	if gameOver == true then
		gameOverTimer = gameOverTimer - dt
	end
	if gameOverTimer < 0 then
		currentLevel = currentLevel
		TEsound.stop("music")
		love.filesystem.load("main.lua")()
		love.load()
	end
end