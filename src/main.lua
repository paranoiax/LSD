require "camera"
require "lib.TEsound"
require "lib.AnAL"
require "Loader"
require "Editor"
require "menu"
require "controls"

explosionList = {"sounds/explosion.wav", "sounds/explosion2.wav", "sounds/explosion3.wav", "sounds/explosion4.wav"}

function beginCallback(fixture1, fixture2, contact)

	if ( (fixture1:getUserData() == "wall") or (fixture2:getUserData() == "wall") ) and ( (fixture1:getUserData() == "ball") or (fixture2:getUserData() == "ball") ) then
		objects.ball.sticky = true
		objects.ball.canJump = true
		if win == false then
			gameOver = true
		end
	end
	
	if ( (fixture1:getUserData() == "sensor") or (fixture2:getUserData() == "sensor") ) and ( (fixture1:getUserData() == "ball") or (fixture2:getUserData() == "ball") ) then
		objects.ball.sticky = true
		objects.ball.canJump = true
		explosionTime = 1
		explodeBall = true
	end
	
	if ( (fixture1:getUserData() == "wall") or (fixture2:getUserData() == "wall") ) and ( (fixture1:getUserData() == "ball") or (fixture2:getUserData() == "ball") ) then
		VelX, VelY = objects.ball.body:getLinearVelocity()
		objects.ball.isAlive = false
		death = true
	end
	
	for i,v in ipairs(Sensor) do
		if v.fixture == fixture1 or v.fixture == fixture2 then
			if fixture1:getUserData() == "ball" or fixture2:getUserData() == "ball" then
			v.touching = true
			collX = v.body:getX()
			collY = v.body:getY()
			end
		end
	end
end

function endCallback(fixture1, fixture2, contact)

	if fixture1:getUserData() == "sensor" or fixture2:getUserData() == "sensor" or fixture1:getUserData() == "wall" or fixture2:getUserData() == "wall" then
		if fixture1:getUserData() == "ball" or fixture2:getUserData() == "ball" then
			objects.ball.sticky = false
			objects.ball.canJump = false
			explodeBall = false
			explosionTime = 1
		end
	end

	for i,v in ipairs(Sensor) do
		if v.fixture == fixture1 or v.fixture == fixture2 then
			if fixture1:getUserData() == "ball" or fixture2:getUserData() == "ball" then
				v.touching = false
				v.fixture:destroy()
				v.isDestroyed = true
				explode = true
				shake = true
				TEsound.play(explosionList)
				SensorsDestroyed = SensorsDestroyed + 1
			end
		end
	end
   
   contact = nil
   collectgarbage()

end

function love.load()	
	love.mouse.setVisible(false)
	
	explodeBall = false
	BallExplode = false
	explosionTime = 1

	particleEffects = true
	debugmode = false
	
	icon = love.graphics.newImage("images/icon.png")
	cursorImg = love.graphics.newImage("images/cursor.png")
	love.graphics.setIcon(icon)
	f = love.graphics.newFont("fonts/DisplayOTF.otf", 90)
	e = love.graphics.newFont("fonts/DisplayOTF.otf", 90)
	d = love.graphics.newFont(14)
	--love.mouse:setGrab(false)

	bg = love.graphics.newImage("images/bg.jpg")

	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 9.81 * 64, true)
	world:setCallbacks(beginCallback, endCallback)
	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()

	button = {}
	objects = {}
	Sensor = {}
	Obstacle = {}
	Particle = {}
	Wall = {}
	DeathParticle = {}
	currentSensor = 1
	currentObstacle = 1
	currentWall = 1

	Rectangle = {}
	GreyTiles = love.graphics.newImage('images/quad_grey.png')
	GreyTiles:setWrap("repeat","repeat")	
	GreyTilesW, GreyTilesH = GreyTiles:getWidth(), GreyTiles:getHeight()

	Rectangle2 = {}
	RedTiles = love.graphics.newImage('images/quad.png')
	RedTiles:setWrap("repeat","repeat")	
	RedTilesW, RedTilesH = RedTiles:getWidth(), GreyTiles:getHeight()

	collX = 0
	collY = 0
	VelX = 0
	VelY = 0
	explode = false
	death = false
	shake = false
	camera.time = 3

	-- LEVEL --
	
	if not love.filesystem.exists("save.lua") then
		love.filesystem.newFile("save.lua")
		love.filesystem.write("save.lua", 1)
	end

	maxLevel = love.filesystem.read("save.lua")
	maxLevel = tonumber(maxLevel)
	print(maxLevel)

	if maxLevel > 1 then
		currentLevel = maxLevel
	elseif maxLevel == 1 then
		currentLevel = 1
	end
	
	currentPack = "original"
	while not love.filesystem.exists("levels/"..currentPack.."/level"..currentLevel..".lua") do
		currentLevel = currentLevel - 1
		assert(currentLevel > 0, "Couldn't find a level for that map-pack")
	end
	map = love.filesystem.load("levels/"..currentPack.."/level"..currentLevel..".lua")()
	
	for i,v in pairs{sensors=addSensor, walls=addWall} do
		for _, data in ipairs(map[i]) do
			v(unpack(data))
		end
	end
	
	if currentLevel > maxLevel then
		love.filesystem.write("save.lua", currentLevel)
	end	

	-- LEVEL --

	objects.ball = {}
	objects.ball.image = love.graphics.newImage("images/ball_anim.png")
	objects.ball.anim = newAnimation(objects.ball.image, 24, 24, 0.1, 0)
	objects.ball.force = 0.95
	objects.ball.body = love.physics.newBody(world, map.player[1], map.player[2], "dynamic")
	objects.ball.shape = love.physics.newCircleShape(12)
	objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, 1)
	objects.ball.fixture:setRestitution(0)
	objects.ball.body:setLinearDamping(0.2)
	objects.ball.body:setFixedRotation(true)
	objects.ball.fixture:setFriction(1)
	objects.ball.fixture:setUserData("ball")
	objects.ball.body:setMass(0.3)
	objects.ball.fixture:setCategory(4)
	objects.ball.fixture:setMask(3)
	objects.ball.sticky = false
	objects.ball.canJump = false
	objects.ball.isAlive = true

	for rectA,tab in pairs({[{"", "Grey"}]=Sensor, [{"2","Red"}]=Wall}) do
		for i,v in ipairs(tab) do
			local x, y, w, h = v.x - v.width / 2, v.y - v.height / 2, v.width, v.height
			_G["Rectangle"..rectA[1]][i] = {
				quad = love.graphics.newQuad(0, 0, w, h, _G[rectA[2].."TilesW"], _G[rectA[2].."TilesW"]),
				x = x,
				y = y
			}
		end
	end

	limit = 90
	deathLimit = 70
	SensorsCount = #Sensor
	SensorsDestroyed = 0

	win = false
	winTimer = 3
	gameOver = false
	gameOverTimer = 3
	
	runNativeResolution()
	scaleX = screenWidth / 1280
	scaleY = screenHeight / 720
	
	ball_menu_image = love.graphics.newImage("images/ball_anim_menu.png")
	ball_menu_anim = newAnimation(ball_menu_image, 192, 192, 0.1, 0)
	
	if currentLevel > 1 then
		button_spawn(screenWidth / 2 - f:getWidth("Continue") / 2,screenHeight / 4 * 3 -85-85,"Continue", "continue")
	end
	button_spawn(screenWidth / 2 - f:getWidth("New Game") / 2,screenHeight / 4 * 3-85,"New Game", "new_game")
	button_spawn(screenWidth / 2 - f:getWidth("Map Editor") / 2,screenHeight / 4 * 3,"Map Editor", "mapedit") --now correctly centered
	button_spawn(screenWidth / 2 - f:getWidth("Quit") / 2,screenHeight / 4 * 3 +85,"Quit", "quit")
	
	if GAMESTATE == "MENU" then
		TEsound.stop("music")
		TEsound.playLooping("sounds/music.mp3", "music", nil, 0.7) --to lower volume as intended without need for additonal line
	end
	
end

function love.update(dt)

	MENU_UPDATE(dt)
	INGAME_UPDATE(dt)
	if GAMESTATE == "EDITOR" then
		Editor.update(dt)
	end
end

function love.draw()
	if GAMESTATE == "EDITOR" then
		Editor.draw()
	end
	MENU_DRAW()
	INGAME_DRAW()

	if debugmode == true then
		love.graphics.setColor(255,50,200)
		love.graphics.setFont(d)
		--[[love.graphics.print("Mouse-Ball Distance: "..distanceFrom(objects.ball.body:getX(),objects.ball.body:getY(),love.mouse:getX() + camera.x,love.mouse.getY() + camera.y),10 + camera.x,15 + camera.y)
		love.graphics.print("Active Bodies: "..world:getBodyCount(),10 + camera.x,35 + camera.y)
		love.graphics.print("Particles per Explosion: "..limit,10 + camera.x,55 + camera.y)
		for q = 1, #Sensor do 
			if Sensor[q].touching == true then
				love.graphics.print("Position of next Explosion: "..math.floor(collX + .5)..", "..math.floor(collY + .5),10 + camera.x,115 + camera.y)
			end
		end--]]--
		love.graphics.print("Frames per Second: "..love.timer:getFPS(),10 + camera.x, 75 + camera.y)
		love.graphics.print('Press "R" to restart!',10 + camera.x, 95 + camera.y)
		--love.graphics.print("Time until explosion: "..explosionTime,10 + camera.x, 135 + camera.y)
		love.graphics.print("Max Level: "..love.filesystem.read("save.lua"),10 + camera.x, 155 + camera.y)
		love.graphics.print("Current Level: "..currentLevel,10 + camera.x, 175 + camera.y)
		love.graphics.print("Current Gamestate: "..GAMESTATE,10 + camera.x, 195 + camera.y)
	end
	
end

function ball_launch()
	local x,y = objects.ball.body:getPosition()
	if objects.ball.canJump == true then
		objects.ball.body:applyLinearImpulse((love.mouse.getX()-x + camera.x)*objects.ball.force,(love.mouse.getY()-y + camera.y)*objects.ball.force)
	end
end

function draw_crosshair()		
	if objects.ball.canJump == true then
		love.graphics.setColor(202,143,84,distanceFrom(objects.ball.body:getX(),objects.ball.body:getY(),love.mouse:getX() + camera.x,love.mouse.getY() + camera.y))
		love.graphics.line(objects.ball.body:getX(), objects.ball.body:getY(), love.mouse.getX() + camera.x, love.mouse.getY() + camera.y)
		love.graphics.setColor(255,255,255,255)
	end
end

function aim_crosshair()
	love.mouse.setVisible(false)
	love.graphics.setColor(202,143,84)
	love.graphics.line(love.mouse:getX() -7 +camera.x, love.mouse:getY() -7 + camera.y, love.mouse.getX() + 7 + camera.x, love.mouse.getY() + 7 + camera.y)
	love.graphics.line(love.mouse:getX() +7 +camera.x, love.mouse:getY() -7 + camera.y, love.mouse.getX() -7 + camera.x, love.mouse.getY() + 7 + camera.y)
end

function draw_timer()
	love.graphics.setColor(0,0,0,180)
	love.graphics.rectangle("fill", 0, screenHeight - 50, screenWidth * explosionTime, 50)
end

function addSensor(x, y, width, height)
	x = x + width / 2
	y = y + height / 2
	Sensor[currentSensor] = {}
	Sensor[currentSensor].body = love.physics.newBody(world, x, y, "static")
	Sensor[currentSensor].shape = love.physics.newRectangleShape(width, height)
	Sensor[currentSensor].fixture = love.physics.newFixture(Sensor[currentSensor].body, Sensor[currentSensor].shape,1)
	Sensor[currentSensor].touching = false
	Sensor[currentSensor].isDestroyed = false
	Sensor[currentSensor].fixture:setSensor(false)
	Sensor[currentSensor].fixture:setUserData("sensor")
	Sensor[currentSensor].x = x
	Sensor[currentSensor].y = y
	Sensor[currentSensor].width = width
	Sensor[currentSensor].height = height
	currentSensor = currentSensor + 1
end

function addWall(x, y, width, height)
	x = x + width / 2
	y = y +height / 2
	Wall[currentWall] = {}
	Wall[currentWall].body = love.physics.newBody(world, x, y, "static")
	Wall[currentWall].shape = love.physics.newRectangleShape(width, height)
	Wall[currentWall].fixture = love.physics.newFixture(Wall[currentWall].body, Wall[currentWall].shape,1)
	Wall[currentWall].fixture:setUserData("wall")
	Wall[currentWall].fixture:setSensor(false)
	Wall[currentWall].fixture:setFriction(100)
	Wall[currentWall].x = x
	Wall[currentWall].y = y
	Wall[currentWall].width = width
	Wall[currentWall].height = height
	currentWall = currentWall + 1	
end

function drawRedRectangle()
	for i,v in ipairs(Rectangle2) do
		love.graphics.setColor(255,255,255)
		love.graphics.drawq(RedTiles, v.quad, v.x, v.y)
	end
end

function drawGreyRectangle()
	for i,v in ipairs(Rectangle) do
		if not Sensor[i].isDestroyed then
			love.graphics.setColor(255,255,255)
			love.graphics.drawq(GreyTiles, v.quad, v.x, v.y)
		end
	end
end

function addParticle()
	for currentParticle = 1, limit do
		Particle[currentParticle] = {}
		Particle[currentParticle].size = math.random(3,6)
		Particle[currentParticle].body = love.physics.newBody(world, collX + math.random(-65,65), collY + math.random(-50,50), "dynamic")
		Particle[currentParticle].shape = love.physics.newRectangleShape(Particle[currentParticle].size,Particle[currentParticle].size)
		Particle[currentParticle].fixture = love.physics.newFixture(Particle[currentParticle].body, Particle[currentParticle].shape,1)
		Particle[currentParticle].fixture:setSensor(false)
		Particle[currentParticle].body:setMass(0.025)
		Particle[currentParticle].fixture:setUserData("particle")
		Particle[currentParticle].fixture:setCategory(3)
		Particle[currentParticle].fixture:setMask(4,5)
	end
end

function addDeathParticle()
	for currentDeathParticle = 1, deathLimit do
		DeathParticle[currentDeathParticle] = {}
		DeathParticle[currentDeathParticle].size = math.random(2,4)
		DeathParticle[currentDeathParticle].body = love.physics.newBody(world, objects.ball.body:getX() + math.random(-objects.ball.shape:getRadius(),objects.ball.shape:getRadius()), objects.ball.body:getY() + math.random(-objects.ball.shape:getRadius(),objects.ball.shape:getRadius()), "dynamic")
		DeathParticle[currentDeathParticle].shape = love.physics.newRectangleShape(DeathParticle[currentDeathParticle].size,DeathParticle[currentDeathParticle].size)
		DeathParticle[currentDeathParticle].fixture = love.physics.newFixture(DeathParticle[currentDeathParticle].body, DeathParticle[currentDeathParticle].shape,1)
		DeathParticle[currentDeathParticle].fixture:setSensor(false)
		DeathParticle[currentDeathParticle].body:setMass(0.01)
		DeathParticle[currentDeathParticle].fixture:setUserData("deathparticle")
		DeathParticle[currentDeathParticle].fixture:setCategory(5)
		DeathParticle[currentDeathParticle].fixture:setMask(4,3)
	end
end

function checkWin()
	win = SensorsDestroyed == SensorsCount
	if win == true then
		objects.ball.sticky = true
		objects.ball.isAlive = false
		objects.ball.canJump = false
	end
end

function explosionTimer(dt)
	local multiplier = SensorsDestroyed / SensorsCount
	if multiplier >= 1 then
		multiplier = 1
	end
	if explodeBall == true and SensorsDestroyed > 0 then
		explosionTime =  explosionTime - dt * 1.25 * multiplier
	end
	if explosionTime < 0 then
		objects.ball.sticky = true
		objects.ball.isAlive = false
		objects.ball.canJump = false
		death = true
		explodeBall = false
		gameOver = true
		explosionTime = 0
	end
end

function outOfBounds()
	if objects.ball.body:getX() < -map.boundaries or objects.ball.body:getX() > map.boundaries or objects.ball.body:getY() < -map.boundaries or objects.ball.body:getY() > map.boundaries then
		if not win then
			gameOver = true
		end
	end
end

function runNativeResolution()
	gameWidth, gameHeight, gameFullscreen, gameVsync, gameFsaa = love.graphics.getMode( )
	if not gameFullscreen then
		love.graphics.toggleFullscreen()
	end
end

function INGAME_UPDATE(dt)
	if GAMESTATE == "INGAME" then
		world:update(dt)
		TEsound.cleanup()		
		objects.ball.anim:update(dt)	
		explosionTimer(dt)
		
		for i,v in ipairs(Sensor) do
			if v.isDestroyed then
				v.body:setActive(false)
			end
		end
		
		camera.x = camera.x - (camera.x - (objects.ball.body:getX() - screenWidth / 2)) * dt * camera.speed
		camera.y = camera.y - (camera.y - (objects.ball.body:getY() - screenHeight / 2)) * dt * camera.speed
		
		if not objects.ball.isAlive then
			objects.ball.canJump = false
		end			
		
		if objects.ball.sticky then
			objects.ball.body:setLinearVelocity(0,0)
			objects.ball.body:setAwake(false)		
		end
		
		if explode then
			for i,v in ipairs(Particle) do
				v.fixture:destroy()
				v.body:setActive(false)
				v.body:destroy()
			end
			if particleEffects == true then
				addParticle()
				for i,v in ipairs(Particle) do
					v.body:applyLinearImpulse(math.random(-30,30),math.random(-40,20))
					--v.r, v.g, v.b = math.random(255),math.random(255),math.random(255) --Colorful Explosions / Set a boolean variable for "original mappack completed" if true activate this (maybe)
				end
			end
			explode = false
		end
		
		if death then
			TEsound.play("sounds/death.wav")
			if particleEffects == true then
				addDeathParticle()
				for i,v in ipairs(DeathParticle) do
					v.body:applyLinearImpulse(VelX / 500, VelY / 500)
				end
			end
			death = false
		end
		
		camera:timer(dt)
		checkWin()
		nextLevel(dt)
		game_over(dt)
		outOfBounds()
	end
end

function INGAME_DRAW()
	if GAMESTATE == "INGAME" then
		--math.randomseed(love.timer.getMicroTime()) -- causes SERIOUS LAG!
		love.graphics.setBackgroundColor(255,255,255)
		love.graphics.setColor(255,255,255)
		love.graphics.setBlendMode("alpha")
		love.graphics.draw(bg,0,0,0,scaleX,scaleY)
		
		camera:set()
		camera:shake()
		
		love.graphics.setLine(3, "smooth")
		
		if aiming == true then
			draw_crosshair()
		end	
		
		if objects.ball.isAlive then
			love.graphics.setColor(255,255,255)
			objects.ball.anim:draw(objects.ball.body:getX() - objects.ball.shape:getRadius(), objects.ball.body:getY() - objects.ball.shape:getRadius())
		end
	   
		if debugmode then
			for i,v in ipairs(Sensor) do
				if v.touching == true then
					love.graphics.setColor(200, 0, 0, 60)
					love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
				end
			end
		end
		
		for i,v in ipairs(Wall) do
			love.graphics.setColor(166,38,27)
			love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
		end
		
		for i,v in ipairs(Particle) do
			love.graphics.setColor(69,69,69) --(v.r, v.g, v.b)
			love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
		end
		
		for i,v in ipairs(DeathParticle) do
			love.graphics.setColor(202,143,84)
			love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))	
		end
		
		drawGreyRectangle()
		drawRedRectangle()			
		
		love.graphics.setFont(e)
		love.graphics.setColor(10,10,10)
		love.graphics.printf(SensorsDestroyed .."/"..SensorsCount,2 + camera.x, 22 + camera.y, screenWidth, "center")
		love.graphics.setColor(217,177,102)
		love.graphics.printf(SensorsDestroyed .."/"..SensorsCount,0 + camera.x, 20 + camera.y, screenWidth, "center")
		
		if win then
			love.graphics.setFont(e)
			love.graphics.setColor(10,10,10)
			love.graphics.printf("Level Completed!",2 + camera.x, screenHeight / 2 - 50 + camera.y, screenWidth, "center")
			love.graphics.setColor(217,177,102)
			love.graphics.printf("Level Completed!",0 + camera.x, screenHeight / 2 - 52 + camera.y, screenWidth, "center")
		end
		
		if gameOver and not win then
			love.graphics.setFont(e)
			love.graphics.setColor(10,10,10)
			love.graphics.printf("Try Again!",2 + camera.x, screenHeight / 2 - 50 + camera.y, screenWidth, "center")
			love.graphics.setColor(217,177,102)
			love.graphics.printf("Try Again!",0 + camera.x, screenHeight / 2 - 52 + camera.y, screenWidth, "center")
		end
		
		aim_crosshair()
		camera:unset()
		draw_timer()
	end
end

function MENU_UPDATE(dt)
	if GAMESTATE == "MENU" then
		ball_menu_anim:update(dt)
		button_check()
	end
end

function MENU_DRAW()
	if GAMESTATE == "MENU" then
		love.graphics.setColor(255,255,255)
		love.graphics.draw(bg,0,0,0,scaleX,scaleY)
		ball_menu_anim:draw(screenWidth / 2 - 96, screenHeight / 2 - 250)

		love.graphics.setFont(e)
		love.graphics.setColor(10,10,10)
		love.graphics.printf("Little Sticky Destroyer",2, 82, screenWidth, "center")
		love.graphics.setColor(217,177,102)
		love.graphics.printf("Little Sticky Destroyer",0, 80, screenWidth, "center")
		
		button_draw()
		menuCursor()
	end
end

-- loading main.lua again is: unresourceful (many resources, unless lua garbage collects it..)
function continue()
	con_level = love.filesystem.read("save.lua")
	con_level = tonumber(con_level)	
	currentLevel = con_level
	love.filesystem.write("save.lua", con_level)
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