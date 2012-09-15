do
	local updates = {
		{"lib.hump.gamestate", "gs"},
		"camera",
		"lib.TEsound",
		"lib.AnAL",
		"Loader",
		"Editor",
		"menu",
		"controls"
		{"lib.cron", "cron"},
		{"lib.tween", "tween"}
	}
	for i,v in ipairs(updates) do
		if type(v) == "table" then
			_G[v[2]] = require(v[1])
		else
			require(v)
		end
	end
end

local explosionList = {"sounds/explosion.wav", "sounds/explosion2.wav", "sounds/explosion3.wav", "sounds/explosion4.wav"}

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
			tween.resetAll()
			cron.reset()
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
				if options.audio.sfx then
					TEsound.play(explosionList)
				end
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

	options = {
		graphics = {},
		audio = {}
	}
	options.graphics.particleEffects = true
	options.graphics.shakeScreen = true
	options.audio.music = true
	options.audio.sfx = true
	
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
	ParticleAlpha = {255}
	Wall = {}
	DeathParticle = {}
	DeathParticleAlpha = {255}
	currentSensor = 1
	currentObstacle = 1
	currentWall = 1
	
	tween.resetAll()
	cron.reset()

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

	maxLevel = tonumber( love.filesystem.read("save.lua") )

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
	
	gameWidth, gameHeight, gameFullscreen, gameVsync, gameFsaa = love.graphics.getMode( )
	if not gameFullscreen then
		love.graphics.toggleFullscreen()
	end
	
	scaleX = screenWidth / 1280
	scaleY = screenHeight / 720
	
	ball_menu_image = love.graphics.newImage("images/ball_anim_menu.png")
	ball_menu_anim = newAnimation(ball_menu_image, 192, 192, 0.1, 0)
	
	if currentLevel > 1 then
		button_spawn(screenWidth / 2 - f:getWidth("Continue") / 2,screenHeight / 4 * 3 -85-85,"Continue", "continue")
	end
	
	local menu = {
		{"New Game", "new_game"},
		{"Map Editor", "mapedit"},
		{"Quit", "quit"}
	}
	local menuY = screenHeight / 4 * 3-85
	for i,v in ipairs(menu) do
		button_spawn(screenWidth/2 - f:getWidth(v[1])/2, menuY, v[1], v[2])
		menuY = menuY + 85
	end
	
	if GAMESTATE == "MENU" then
		TEsound.stop("music")
		if options.audio.music then
			TEsound.playLooping("sounds/music.mp3", "music", nil, 0.7) --to lower volume as intended without need for additonal line
		end
	end
	
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

function tweenDeath()
	tween(1, DeathParticleAlpha, {0}, "linear", tweenDeathOver)
end

function tweenDeathOver()
	if gameOver == false then
		DeathParticleAlpha = {255}
	end
end

function tweenExplosion()
	tween(1.5, ParticleAlpha, {0}, "linear")
end