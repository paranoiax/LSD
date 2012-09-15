Game = gs:new()

function Game:init()
	require "Game.drawing"
end

function Game:enter(old, pack, level)
	love.mouse.setVisible(false)
	currentPack = pack
	currentLevel = level
	
	winTimer = 3
	gameOverTimer = 1

	explodeBall = false
	BallExplode = false
	explosionTime = 1
	
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
	
	collX = 0
	collY = 0
	VelX = 0
	VelY = 0
	explode = false
	death = false
	shake = false
	camera.time = 3
	
	limit = 90
	deathLimit = 70
	SensorsCount = #Sensor
	SensorsDestroyed = 0

	win = false
	winTimer = 3
	gameOver = false
	gameOverTimer = 3
	
	if not love.filesystem.exists("save.lua") then
		love.filesystem.newFile("save.lua")
		love.filesystem.write("save.lua", 1)
	end

	maxLevel = tonumber( tostring( love.filesystem.read("save.lua") ) )
	currentLevel = maxLevel>1 and maxLevel or 1
	
	currentPack = "original"
	while not love.filesystem.exists("levels/"..currentPack.."/level"..currentLevel..".lua") do
		currentLevel = currentLevel - 1
		assert(currentLevel > 0, "Couldn't find a level for that map-pack")
	end
	map = love.filesystem.load("levels/"..currentPack.."/level"..currentLevel..".lua")()
	
	if currentLevel > maxLevel then
		love.filesystem.write("save.lua", currentLevel)
	end
	
	objects.ball.body:setPosition(map.player[1], map.player[2])
	
	for i,v in pairs{sensors=addSensor, walls=addWall} do
		for _, data in ipairs(map[i]) do
			print("creating" .. i .. ", index:".._)
			v(unpack(data))
		end
	end
	
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
end

function Game:mousereleased(x, y, b)
	if b == "l" then
		local x,y = Game.data.objects.ball.body.x, Game.data.objects.ball.body.y
		if objects.ball.canJump then
			local mx, my = love.mouse.getX(), love.mouse.getY()
			objects.ball.body:applyLinearImpulse( (mx-x + camera.x) * objects.ball.force, (my-y + camera.y) * objects.ball.force)
		end
		aiming = false
		objects.ball.sticky = not objects.ball.canJump
	end
end

function Game:keypressed(key, unicode)
	if key == "r" or key == "enter" or key == "return" or key == " " then
		-- restart the map (retry)
		gs.switch(Game, currentPack, currentLevel)
	elseif key == "escape" then
		gs.switch(Menu)
	end
end

function Game:update(dt)
	Game.data = {
		objects = {
			ball = {
				body = {
					x = objects.ball.body:getX(),
					y = objects.ball.body:getY()
				}
			}
		}
	}

	world:update(dt)
	objects.ball.anim:update(dt)	
	
	local multiplier = SensorsDestroyed / SensorsCount
	if multiplier > 1 then
		multiplier = 1
	end
	if explodeBall and SensorsDestroyed > 0 then
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
		ParticleAlpha = {255}
		for i,v in ipairs(Particle) do
			v.fixture:destroy()
			v.body:setActive(false)
			v.body:destroy()
		end
		if options.graphics.particleEffects == true then
			addParticle()
			for i,v in ipairs(Particle) do
				v.body:applyLinearImpulse(math.random(-30,30),math.random(-40,20))
				if options.cheats.colorfulExplosions then
					v.r, v.g, v.b = math.random(255),math.random(255),math.random(255)
				end
			end
		end
		cron.after(1, tweenExplosion)
		explode = false
	end
	
	if death then
		if options.audio.sfx then
			TEsound.play("sounds/death.wav")
		end
		if options.graphics.particleEffects == true then
			addDeathParticle()
			for i,v in ipairs(DeathParticle) do
				v.body:applyLinearImpulse(VelX / 500, VelY / 500)
			end
		end
		cron.after(1.25, tweenDeath)			
		death = false
	end
	
	camera:timer(dt)
	
	win = SensorsDestroyed == SensorsCount
	if win then
		objects.ball.sticky = true
		objects.ball.isAlive = false
		objects.ball.canJump = false
		
		winTimer = winTimer - dt
	end
	
	if winTimer < 0 then
		if love.filesystem.exists("levels/" .. currentPack .."/level"..currentLevel + 1 ..".lua") then
			currentLevel = currentLevel + 1
			if currentLevel > maxLevel then
				love.filesystem.write("save.lua", currentLevel)
			end
			gs.switch(Game, currentPack, currentLevel)
		else
			currentLevel = 1
			love.filesystem.write("save.lua", currentLevel)
			gs.switch(Menu)
		end
	end	
	
	if gameOver then
		gameOverTimer = gameOverTimer - dt * 1.5
	end
	
	if gameOverTimer < 0 then
		gs.switch(Game, currentPack, currentLevel)
	end
	
	gameOver = ( (objects.ball.body:getX() < -map.boundaries or objects.ball.body:getX() > map.boundaries or objects.ball.body:getY() < -map.boundaries or objects.ball.body:getY() > map.boundaries) and (not win) )
end


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