debugmode = true
demo = false
require "camera"
require "lib.TEsound"
require "lib.AnAL"
require "Loader"
require "Editor"
menu = require("menu/menu")
require "controls"
require "options"
require "lib.32log"
require "lib.Vector"
require "pixelshader"
local cron = require 'lib.cron'
local tween = require 'lib.tween'

explosionList = {"sounds/explosion.wav", "sounds/explosion2.wav", "sounds/explosion3.wav", "sounds/explosion4.wav"}

function checkValues(a, b, c)
	return (a==c) or (b==c)
end

function beginCallback(fixture1, fixture2, contact)

	if (not options.cheats.SensorsAreFtw) and checkValues(fixture1:getUserData(), fixture2:getUserData(), "wall") and checkValues(fixture1:getUserData(), fixture2:getUserData(), "ball") then
		objects.ball.sticky = true
		objects.ball.canJump = true
		if win == false then
			gameOver = true
		end
	end
	
	if ( options.cheats.SensorsAreFtw or checkValues(fixture1:getUserData(), fixture2:getUserData(), "sensor") ) and checkValues(fixture1:getUserData(), fixture2:getUserData(), "ball") then
		objects.ball.sticky = true
		objects.ball.canJump = true
		explosionTime = 1
		explodeBall = true
	end
	
	if (not options.cheats.SensorsAreFtw) and checkValues(fixture1:getUserData(), fixture2:getUserData(), "wall") and checkValues(fixture1:getUserData(), fixture2:getUserData(), "ball") then
		VelX, VelY = objects.ball.body:getLinearVelocity()
		objects.ball.isAlive = false
		death = true
	end
	
	for i,v in ipairs(Sensor) do
		if checkValues(fixture1, fixture2, v.fixture) then
			if checkValues(fixture1:getUserData(), fixture2:getUserData(), "ball") then
				v.touching = true
				collX = v.body:getX()
				collY = v.body:getY()
				explosionWidth = v.width
				explosionHeight = v.height
				limit = ((v.width + v.height) / 2)
				if limit < 20 then
					limit = 20
				elseif limit > 85 then
					limit = 85 
				end
				if SensorsDestroyed == SensorsCount -1 then
					v.isDestroyed = true
					explode = true
					shake = true
				end
			end
		end
	end
end

function endCallback(fixture1, fixture2, contact)

	if checkValues(fixture1:getUserData(), fixture2:getUserData(), "sensor") or checkValues(fixture1:getUserData(), fixture2:getUserData(), "wall") then
		if checkValues(fixture1:getUserData(), fixture2:getUserData(), "ball") and (not options.cheats.SensorsAreFtw) then
			objects.ball.sticky = false
			objects.ball.canJump = false
			explodeBall = false
			explosionTime = 1
			tween.resetAll()
			cron.reset()
		end
	end

	for i,v in ipairs(Sensor) do
		if checkValues(fixture1, fixture2, v.fixture) then
			if checkValues(fixture1:getUserData(), fixture2:getUserData(), "ball") then
				v.touching = false
				--v.fixture:destroy()
				v.isDestroyed = true
				explode = true
				shake = true
				if options.audio.sfx then
					if SensorsDestroyed == #Sensor - 1 and options.graphics.slowmotion then
						TEsound.play(explosionList, nil, nil, 0.7)
					else
						TEsound.play(explosionList)
					end
				end
				SensorsDestroyed = SensorsDestroyed + 1
			end
		end
	end
   
   contact = nil
   collectgarbage()

end

motionFrames = 10 -- number of frames to store for motion; must be at least 1 (the current frame)
alphaMultiplier = 100-- alpha of each motion is determined by: frameNumber * (1 / motionFrames * alphaMultiplier)

function love.load()

	love.mouse.setVisible(false)
	
	explodeBall = false
	BallExplode = false
	explosionTime = 1

	if options.cheats.SensorsAreFtw then
		options.cheats.timeOut = true
	end
	
	icon = love.graphics.newImage("images/icon.png")
	cursorImg = love.graphics.newImage("images/cursor.png")
	love.graphics.setIcon(icon)
	f = love.graphics.newFont("fonts/DisplayOTF.otf", 60)
	e = love.graphics.newFont("fonts/DisplayOTF.otf", 90)
	d = love.graphics.newFont(14)
	--love.mouse:setGrab(false)

	bg = love.graphics.newImage("images/bg.jpg")
	vignetteImg = love.graphics.newImage("images/vignette.jpg")
	trajectoryImg = love.graphics.newImage("images/trajectory.png")

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
	gameAlpha = 0
	titleY = -100
	
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

	timeOut = false
	collX = 0
	collY = 0
	explosionWidth = 0
	explosionHeight = 0
	VelX = 0
	VelY = 0
	explode = false
	death = false
	shake = false
	camera.time = 2
	camera.layers = {}

	-- LEVEL --
	
	if not love.filesystem.exists("save.lua") then
		love.filesystem.newFile("save.lua")
		love.filesystem.write("save.lua", 1)
	end
	
	if love.filesystem.exists("completed.lua") and demo then
		options.cheats.colorfulExplosion = love.filesystem.read("completed.lua")
	end

	maxLevel = love.filesystem.read("save.lua")
	maxLevel = tonumber(maxLevel)

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
	if not testmap then
		map = love.filesystem.load("levels/"..currentPack.."/level"..currentLevel..".lua")()
	else
		map = love.filesystem.load("maps/testmap.lua")()
	end
		
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
	objects.ball.imageJump = love.graphics.newImage("images/ball_anim_jump.png")
	objects.ball.imageFall = love.graphics.newImage("images/ball_anim_fall.png")
	objects.ball.anim = newAnimation(objects.ball.image, 24, 24, 0.1, 0)
	objects.ball.animJump = newAnimation(objects.ball.imageJump, 24, 24, 0.1, 0)
	objects.ball.animFall = newAnimation(objects.ball.imageFall, 24, 24, 0.1, 0)
	objects.ball.force = 0.95
	objects.ball.body = love.physics.newBody(world, map.player[1], map.player[2], "dynamic")
	objects.ball.shape = love.physics.newCircleShape(12)
	objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, 1)
	objects.ball.fixture:setRestitution(0)
	--objects.ball.body:setLinearDamping(0.2) -- unfortunately, this messes with the trajectory
	objects.ball.body:setFixedRotation(true)
	objects.ball.fixture:setFriction(1)
	objects.ball.fixture:setUserData("ball")
	objects.ball.body:setMass(0.3)
	objects.ball.fixture:setCategory(4)
	objects.ball.fixture:setMask(3)
	objects.ball.sticky = false
	objects.ball.canJump = false
	objects.ball.isAlive = true
	objects.ball.pos = Vector:new(x, y)
	objects.ball.jumpImpulseVector=nil
	objects.ball.maxImpulseVelocity = 600
	objects.ball.impulseVectorLength = 0
	objects.ball.maxImpulseVelocityLength=720
	objects.ball.maxProjections = 24
	objects.ball.projectionSpacing=13

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

	limit = 85
	deathLimit = 45
	SensorsCount = #Sensor
	SensorsDestroyed = 0

	win = false
	winTimer = 3
	gameOver = false
	gameOverTimer = 3
	
	scaleX = screenWidth / 996
	scaleY = screenHeight / 560
	if GAMESTATE == "MENU" then
		menu.run = true
	else
		menu.run = false
	end
	
	temp_s = tostring(options.audio.sfx)
	if temp_s == "true" then temp_s = "on" else temp_s = "off" end
	temp_m = tostring(options.audio.music)
	if temp_m == "true" then temp_m = "on" else temp_m = "off" end
	temp_inv = tostring(options.controls.inverted)
	if temp_inv == "true" then temp_inv = "yes" else temp_inv = "no" end
	temp_part = tostring(options.graphics.particleEffects)
	if temp_part == "true" then temp_part = "enabled" else temp_part = "disabled" end
	temp_shake = tostring(options.graphics.shakeScreen)
	if temp_shake == "true" then temp_shake = "enabled" else temp_shake = "disabled" end
	temp_slow = tostring(options.graphics.slowmotion)
	if temp_slow == "true" then temp_slow = "enabled" else temp_slow = "disabled" end
	temp_blur = tostring(options.graphics.motionblur)
	if temp_blur == "true" then temp_blur = "enabled" else temp_blur = "disabled" end
	temp_vignette = tostring(options.graphics.vignette)
	if temp_vignette == "true" then temp_vignette = "enabled" else temp_vignette = "disabled" end
	temp_grain = tostring(options.graphics.shader)
	if temp_grain == "true" then temp_grain = "enabled" else temp_grain = "disabled" end
	temp_god = tostring(options.cheats.SensorsAreFtw)
	if temp_god == "true" then temp_god = "enabled" else temp_god = "disabled" end
	temp_color = tostring(options.cheats.colorfulExplosion)
	if temp_color == "true" then temp_color = "enabled" else temp_color = "disabled" end
	
	menu_view = {}
	if currentLevel > 1 then
	menu_view[1] = {
		title="Little Sticky\nDestroyer",
		desc="",
		{t="Continue",cb="cont"},
		{t="New Game",cb="ng"},
		{t="Map Editor",cb="lvledit"},
		{t="Options",cb="op"},
		{t="Cheats",cb="cheats"},
		{t="Credits",cb="cr"},	
		{t="Exit",cb="exit"}
	}
	else
	menu_view[1] = {
		title="Little Sticky\nDestroyer",
		desc="",
		{t="New Game",cb="ng"},
		{t="Map Editor",cb="lvledit"},
		{t="Options",cb="op"},
		{t="Cheats",cb="cheats"},
		{t="Credits",cb="cr"},
		{t="Exit",cb="exit"}
	}
	end
	menu_view[2] = {
		title="Options",
		desc="Set your options here.",
		{t="Fullscreen",cb="fs"},
		{t="Resolution ("..love.graphics.getWidth().."x"..love.graphics.getHeight()..")",cb="res"},
		{t="Sound ("..temp_s..")",cb="sound"},
		{t="Music ("..temp_m..")",cb="music"},
		{t="Invert controls ("..temp_inv..")",cb="inverted"},
		{t="Particle effects ("..temp_part..")",cb="particles"},
		{t="Screen shaking ("..temp_shake..")",cb="shake"},
		{t="Slow motion ("..temp_slow..")",cb="slow"},
		{t="Motion blur ("..temp_blur..")",cb="blur"},
		{t="Vignette ("..temp_vignette..")",cb="vignette"},
		{t="Film grain ("..temp_grain..")",cb="grain"},
		{t="Return",cb="mm"}
	}
	menu_view[3] = {
		title="Quit",
		desc="Are you sure you want to quit?",
		{t="Confirm",cb="cexit"},
		{t="Return",cb="mm"}
	}
	menu_view[4] = {
		title="Credits",
		desc=[[
			Project Manager / Lead Artist / Lead Programmer:
			-Kai Hossbach

			Executive Programmer:
			-Qais Patankar

			Resources / Libraries:
			-Love2d (love2d.org)
			-Box2D (box2d.org)
			-TEsound (by Taehl)
			-AnAL (by bartbes)
			-32Log (by ishkabible)
			-cron (by kikito)
			-tween (by kikito)
			-lovemenu (by josefnpat)
		]],
		{t="Return",cb="mm"}
	}
	menu_view[5] = {
		title="Cheats",
		desc="Set your cheats here.",
		{t="Godmode ("..temp_god..")",cb="god"},
		{t="Colorful explosions ("..temp_color..")",cb="color"},
		{t="Return",cb="mm"}
	}
	menu:load(menu_view)
	videomodes = love.graphics.getModes()
	if currentmode == nil then currentmode = 1 end
	
	if GAMESTATE == "MENU" then
		TEsound.stop("music")
		if options.audio.music then
			TEsound.playLooping("sounds/music.mp3", "music", nil, 0.65) --to lower volume as intended without need for additonal line
		end
	end
	
	canvasSupported = love.graphics.isSupported("canvas")
	if canvasSupported then
		canvas = love.graphics.newCanvas()
		canvas:clear()
	end
	blur = false
	if options.graphics.shader then
		pixeleffect:send("nIntensity", 0.25)
	end
	
	local currentParallax1
	local Parallax1 = {}
	local currentParallax2
	local Parallax2 = {}
	local currentParallax3
	local Parallax3 = {}
	
	for currentParallax1 = 1, ((map.minX+map.maxX+map.maxY+map.minY) / 40) do
		Parallax1[currentParallax1] = {}
		Parallax1[currentParallax1].size = math.random(6,18)
		Parallax1[currentParallax1].x = math.random(map.minX-map.minX,map.maxX+map.maxX)
		Parallax1[currentParallax1].y = math.random(map.minY-map.minY,map.maxY+map.maxY)
	end
	
	for currentParallax2 = 1, ((map.minX+map.maxX+map.maxY+map.minY) / 40) do
		Parallax2[currentParallax2] = {}
		Parallax2[currentParallax2].size = math.random(6,18)
		Parallax2[currentParallax2].x = math.random(map.minX-map.minX,map.maxX+map.maxX)
		Parallax2[currentParallax2].y = math.random(map.minY-map.minY,map.maxY+map.maxY)
	end
	
	for currentParallax3 = 1, ((map.minX+map.maxX+map.maxY+map.minY) / 40) do
		Parallax3[currentParallax3] = {}
		Parallax3[currentParallax3].size = math.random(6,18)
		Parallax3[currentParallax3].x = math.random(map.minX-map.minX,map.maxX+map.maxX)
		Parallax3[currentParallax3].y = math.random(map.minY-map.minY,map.maxY+map.maxY)
	end
	
    camera:newLayer(0.75, function()
		for i,v in ipairs(Parallax1) do
			love.graphics.setColor(255,255,255,150)
			love.graphics.rectangle("fill",v.x,v.y,v.size,v.size)
			love.graphics.setColor(255,255,255)
		end
    end)
	
	camera:newLayer(0.45, function()
		for i,v in ipairs(Parallax2) do
			love.graphics.setColor(255,255,255,100)
			love.graphics.rectangle("fill",v.x,v.y,v.size*2,v.size*2)
			love.graphics.setColor(255,255,255)
		end
    end)
	
	camera:newLayer(0.2, function()
		for i,v in ipairs(Parallax3) do
			love.graphics.setColor(255,255,255,50)
			love.graphics.rectangle("fill",v.x,v.y,v.size*3,v.size*3)
			love.graphics.setColor(255,255,255)
		end
    end)
	
	camera:newLayer(1, function()
		if options.graphics.shakeScreen then
			camera:shake()
		end
		
		love.graphics.setLine(3, "smooth")
		
		if options.graphics.motionblur then
			if blur then
				love.graphics.setBlendMode("subtractive")			
				love.graphics.setCanvas(canvas)
				blurAlpha = math.clamp(dt*alphaMultiplier*255, motionFrames, 255)
				blurAlpha = ((blurAlpha / 255) * gameAlpha)
				love.graphics.setColor(0, 0, 0, blurAlpha)
				--Makes the transparency low as it adds to the canvas.
				love.graphics.rectangle('fill', 0+camera.x, 0+camera.y, screenWidth,screenHeight)
				--Adds a background so the trails don't stick.
				love.graphics.setBlendMode("alpha")
			end
		end
		
		if aiming == true then
			draw_crosshair()
		end	
		
		if objects.ball.isAlive then
			love.graphics.setColor(255,255,255,gameAlpha)
			if pixelEffectSupported and options.graphics.shader then love.graphics.setPixelEffect(pixeleffect) end
				if objects.ball.canJump then
					objects.ball.anim:draw(objects.ball.body:getX() - objects.ball.shape:getRadius(), objects.ball.body:getY() - objects.ball.shape:getRadius())
				else
					local x,y = objects.ball.body:getLinearVelocity()
					if y <= 0 then
						objects.ball.animJump:draw(objects.ball.body:getX() - objects.ball.shape:getRadius(), objects.ball.body:getY() - objects.ball.shape:getRadius())
					else
						objects.ball.animFall:draw(objects.ball.body:getX() - objects.ball.shape:getRadius(), objects.ball.body:getY() - objects.ball.shape:getRadius())
					end
				end
			if pixelEffectSupported and options.graphics.shader then love.graphics.setPixelEffect() end
		end
	   
		if debugmode then
			for i,v in ipairs(Sensor) do
				if v.touching == true then
					love.graphics.setColor(200, 0, 0, 60,gameAlpha)
					love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
				end
			end
			for i,v in ipairs(Wall) do
				love.graphics.setColor(166,38,27,gameAlpha)
				love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
			end
		end
		
		for i,v in ipairs(Particle) do
			if not v.isDestroyed then
				love.graphics.setColor(v.r,v.g,v.b,ParticleAlpha[1]) --(v.r, v.g, v.b)
				love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
			end
		end
		
		for i,v in ipairs(DeathParticle) do
			love.graphics.setColor(202,143,84,DeathParticleAlpha[1])
			love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))	
		end
		
		drawGreyRectangle()
		drawRedRectangle()				
		
		if options.graphics.motionblur then
			if blur then
				love.graphics.setCanvas()
				love.graphics.setColor(255,255,255,gameAlpha)			
				love.graphics.draw(canvas, 0+camera.x, 0+camera.y)
			end
		end		
		
		love.graphics.setFont(e)
		love.graphics.setColor(10,10,10,gameAlpha)
		love.graphics.printf(SensorsDestroyed .."/"..SensorsCount,2 + camera.x, 22 + camera.y, screenWidth, "center")
		love.graphics.setColor(217,177,102,gameAlpha)
		love.graphics.printf(SensorsDestroyed .."/"..SensorsCount,0 + camera.x, 20 + camera.y, screenWidth, "center")
		
		if win then
			love.graphics.setFont(e)
			love.graphics.setColor(10,10,10,gameAlpha)
			love.graphics.printf("Level Completed!",2 + camera.x, screenHeight / 2 - 50 + camera.y, screenWidth, "center")
			love.graphics.setColor(217,177,102,gameAlpha)
			love.graphics.printf("Level Completed!",0 + camera.x, screenHeight / 2 - 52 + camera.y, screenWidth, "center")
		end
		
		if gameOver and not win then
			love.graphics.setFont(e)
			love.graphics.setColor(10,10,10,gameAlpha)
			love.graphics.printf("Try Again!",2 + camera.x, screenHeight / 2 - 50 + camera.y, screenWidth, "center")
			love.graphics.setColor(217,177,102,gameAlpha)
			love.graphics.printf("Try Again!",0 + camera.x, screenHeight / 2 - 52 + camera.y, screenWidth, "center")
		end
		
		aim_crosshair()
    end)
	
end

function love.update(dt)
	time = time+dt
	dt = dt * slowmo.time.t
	if GAMESTATE == "MENU" then
		menu:update(dt)
	end
	INGAME_UPDATE(dt)
	if GAMESTATE == "EDITOR" then
		if options.graphics.shader then
			local nIntensity = 0.25
			pixeleffect:send("nIntensity", nIntensity)
		end
		Editor.update(dt)
	end
	tween.update(dt)
	tweenGameAlpha(dt)
end

function love.draw()
	if options.graphics.shader then
		pixeleffect:send("time",time)
	end
	love.graphics.setBackgroundColor(255,255,255)
	love.graphics.setColor(255,255,255,gameAlpha)
	love.graphics.setBlendMode("alpha")	
	if pixelEffectSupported and options.graphics.shader then love.graphics.setPixelEffect(pixeleffect) end
	love.graphics.draw(bg,0,0,0,scaleX,scaleY)
	if pixelEffectSupported and options.graphics.shader then love.graphics.setPixelEffect() end
	if GAMESTATE == "EDITOR" then
		Editor.draw()
	end
	if GAMESTATE == "MENU" then
		menu:draw()
	end
	INGAME_DRAW()
	drawVignette()
end

function ball_launch()
	local x,y = objects.ball.body:getPosition()
	if objects.ball.canJump == true then
		objects.ball.body:applyLinearImpulse(objects.ball.jumpImpulseVector.x,objects.ball.jumpImpulseVector.y)
	end
end

function draw_crosshair()		
	if objects.ball.canJump then	
		local projections = objects.ball.impulseVectorLength / (objects.ball.maxImpulseVelocity/objects.ball.maxProjections)
		local tAlpha = 255		
		for t=0, projections do
			local pos=getTrajectoryPoint(Vector:new(objects.ball.body:getX(), objects.ball.body:getY()),objects.ball.jumpImpulseVector,t*objects.ball.projectionSpacing,objects.ball.body:getMass())			
			if tAlpha > 40 then
				tAlpha = tAlpha - 30
			else 
				tAlpha = 40
			end			
			love.graphics.setColor(255,255,255,tAlpha)
			love.graphics.draw(trajectoryImg,pos.x - trajectoryImg:getWidth() / 2,pos.y - trajectoryImg:getHeight() / 2)
		end
	end
end

function aim_crosshair()
	if not aiming then
		love.mouse.setVisible(false)
		love.graphics.setColor(202,143,84,gameAlpha)
		love.graphics.line(love.mouse:getX() -7 +camera.x, love.mouse:getY() -7 + camera.y, love.mouse.getX() + 7 + camera.x, love.mouse.getY() + 7 + camera.y)
		love.graphics.line(love.mouse:getX() +7 +camera.x, love.mouse:getY() -7 + camera.y, love.mouse.getX() -7 + camera.x, love.mouse.getY() + 7 + camera.y)
	end
end

function draw_timer()
	love.graphics.setColor(0,0,0,((180 / 255) * gameAlpha))
	love.graphics.rectangle("fill", 0, screenHeight - 50, screenWidth * explosionTime, 50)
end

function addSensor(x, y, width, height)
	x = x + width / 2
	y = y - height / 2
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
	y = y - height / 2
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
		love.graphics.setColor(255,255,255,gameAlpha)		
		love.graphics.drawq(RedTiles, v.quad, v.x, v.y)
	end
end

function drawGreyRectangle()
	for i,v in ipairs(Rectangle) do
		if not Sensor[i].isDestroyed then
			love.graphics.setColor(255,255,255,gameAlpha)
			love.graphics.drawq(GreyTiles, v.quad, v.x, v.y)
		end
	end
end

function addParticle()
	for currentParticle = 1, limit do
		Particle[currentParticle] = {}
		Particle[currentParticle].size = math.random(3,6)
		Particle[currentParticle].body = love.physics.newBody(world, collX + math.random(-explosionWidth / 2,explosionWidth / 2), collY + math.random(-explosionHeight / 2,explosionHeight / 2), "dynamic")
		Particle[currentParticle].shape = love.physics.newRectangleShape(Particle[currentParticle].size,Particle[currentParticle].size)
		Particle[currentParticle].fixture = love.physics.newFixture(Particle[currentParticle].body, Particle[currentParticle].shape,1)
		Particle[currentParticle].fixture:setSensor(false)
		Particle[currentParticle].body:setMass(0.025)
		Particle[currentParticle].fixture:setUserData("particle")
		Particle[currentParticle].fixture:setCategory(3)
		Particle[currentParticle].fixture:setMask(4,5)
		Particle[currentParticle].isDestroyed = false
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
		slowmo:start()
		shake = false
		objects.ball.sticky = true
		objects.ball.isAlive = false
		objects.ball.canJump = false
		gameOver = false
	end
end

function explosionTimer(dt)
	local multiplier = SensorsDestroyed / SensorsCount
	if multiplier >= 1 then
		multiplier = 1
	end
	if explodeBall == true and SensorsDestroyed > 0 then
		if (not options.cheats.timeout) or (not options.cheats.SensorsAreFtw) then
			explosionTime =  explosionTime - dt * multiplier
		end
		if options.cheats.timeOut then
			explosionTime = 1
		end
	end
	if (explosionTime < 0) and (not options.cheats.timeOut) then
		objects.ball.sticky = true
		objects.ball.isAlive = false
		objects.ball.canJump = false
		death = true		
		explodeBall = false
		gameOver = true
		timeOut = true
		explosionTime = 0
	end
	if GAMESTATE == "INGAME"  and options.graphics.shader then
		if objects.ball.isAlive then
			local nIntensity = 0.25 / explosionTime
			if nIntensity >= 0.65 then nIntensity = 0.65 end
			pixeleffect:send("nIntensity", nIntensity)
		elseif not objects.ball.isAlive then
			local nIntensity = 0.65
			pixeleffect:send("nIntensity", nIntensity)
		end
	end
end

function outOfBounds()
	if objects.ball.body:getX() < map.minX -250 or objects.ball.body:getX() > map.maxX + 250 or objects.ball.body:getY() > map.maxY + 250 then
		if options.graphics.shader then
			local nIntensity = 0.65
			pixeleffect:send("nIntensity", nIntensity)
		end
		if not win then
			gameOver = true
		end
	end
end

function INGAME_UPDATE(dt2)
	dt = dt2
	if GAMESTATE == "INGAME" then
	
		if aiming then
			local bodyCoords = Vector:new((love.mouse.getX()-objects.ball.body:getX() + camera.x)*objects.ball.force,(love.mouse.getY()-objects.ball.body:getY() + camera.y)*objects.ball.force)
			objects.ball.jumpImpulseVector = bodyCoords
			
			objects.ball.linearVelocity = Vector:new(objects.ball.body:getLinearVelocity())
			objects.ball.linearVelocityLength = objects.ball.linearVelocity:getLength()
			
			objects.ball.jumpImpulseVector.x = objects.ball.jumpImpulseVector.x * (objects.ball.maxImpulseVelocity/objects.ball.maxImpulseVelocityLength)
			objects.ball.jumpImpulseVector.y = objects.ball.jumpImpulseVector.y * (objects.ball.maxImpulseVelocity/objects.ball.maxImpulseVelocityLength)
			objects.ball.impulseVectorLength = objects.ball.jumpImpulseVector:getLength()
			
			if options.controls.inverted then
				objects.ball.jumpImpulseVector.x = objects.ball.jumpImpulseVector.x *-1
				objects.ball.jumpImpulseVector.y = objects.ball.jumpImpulseVector.y *-1
			end
		end
		
		world:update(dt)
		TEsound.cleanup()		
		objects.ball.anim:update(dt)
		objects.ball.animJump:update(dt)
		objects.ball.animFall:update(dt)
		explosionTimer(dt)
		
		for i,v in ipairs(Sensor) do
			if v.isDestroyed then
				v.body:setActive(false)
			end
		end

		if objects.ball.body:getX() > map.minX - 250 and objects.ball.body:getX() < map.maxX +250 and objects.ball.body:getY() < map.maxY + 250 then
			camera.x = camera.x - (camera.x - (objects.ball.body:getX() - screenWidth / 2)) * dt * camera.speed
			camera.y = camera.y - (camera.y - (objects.ball.body:getY() - screenHeight / 2)) * dt * camera.speed
		end
		
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
				if not v.isDestroyed then
					v.fixture:destroy()
					v.body:setActive(false)
					v.body:destroy()
					v.isDestroyed = true
				end
			end
			if options.graphics.particleEffects == true then
				addParticle()
				for i,v in ipairs(Particle) do
					if not v.isDestroyed then
						v.body:applyLinearImpulse(math.random(-30,30),math.random(-40,20))
					end
					if options.cheats.colorfulExplosion then
						v.r, v.g, v.b = math.random(255),math.random(255),math.random(255) --Colorful Explosions / Set a boolean variable for "original mappack completed" if true activate this (maybe)
					else
						v.r, v.g, v.b = 69,69,69
					end
				end
			end		
			
			cron.after(1, tweenExplosion)
			explode = false
		end
		
		if death then
			if options.audio.sfx then
				if options.graphics.slowmotion then
					TEsound.play("sounds/death.wav", nil, nil, 0.5)
				else
					TEsound.play("sounds/death.wav")
				end
			end
			if options.graphics.particleEffects == true then
				addDeathParticle()				
				if timeOut then
					for i,v in ipairs(DeathParticle) do						
						v.body:applyLinearImpulse(math.random(-15,15),math.random(-20,10))
					end
				else
					for i,v in ipairs(DeathParticle) do
						v.body:applyLinearImpulse(VelX / 500, VelY / 500)
					end
				end
			end
			cron.after(1.25, tweenDeath)
			death = false
		end
		
		camera:timer(dt)
		checkWin()
		nextLevel(dt)
		game_over(dt)
		outOfBounds()
		cron.update(dt)	
	end
end

function INGAME_DRAW()
	if GAMESTATE == "INGAME" then	
		--math.randomseed(love.timer.getMicroTime()) -- causes SERIOUS LAG!		
		
		camera:draw()
		
		if debugmode == true then
			love.graphics.setColor(255,50,200,gameAlpha)
			love.graphics.setFont(d)
			love.graphics.print("Mouse-Ball Distance: "..distanceFrom(objects.ball.body:getX(),objects.ball.body:getY(),love.mouse:getX() + camera.x,love.mouse.getY() + camera.y),15,15)
			love.graphics.print("Active Bodies: "..world:getBodyCount(),15,35)
			love.graphics.print("Particles for next Explosion: "..limit,15,55)
			for q = 1, #Sensor do
				if Sensor[q].touching == true then
					love.graphics.print("Position of next Explosion: "..math.floor(collX + .5)..", "..math.floor(collY + .5),15,115)
				end
			end
			love.graphics.print("Frames per Second: "..love.timer:getFPS(),15, 75)
			love.graphics.print(string.format("Option list: graphics; shake:%s, pfx:%s, slomo:%s, blur:%s", options.graphics.shakeScreen, options.graphics.particleEffects, options.graphics.slowmotion, options.graphics.motionblur),15, 95)
			love.graphics.print("Time until explosion: "..explosionTime,15, 135)
			love.graphics.print("Max Level: "..love.filesystem.read("save.lua"),15, 155)
			love.graphics.print("Current Level: "..currentLevel,15, 175)
			love.graphics.print("Current Gamestate: "..GAMESTATE,15, 195)
			love.graphics.print("Size of next Explosion: "..explosionWidth .. ', ' .. explosionHeight,15, 215)
			love.graphics.print("Camera Shake: "..tostring(shake) .. ', ' .. camera.time,15, 235)
		end
		
		if not options.cheats.timeOut then
			draw_timer()
		end
		
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

function tweenDeath()
	if not gameOver and SensorsDestroyed < #Sensor then
		tween(1, DeathParticleAlpha, {0}, "linear", tweenDeathOver)
	end
end

function tweenDeathOver()	
	DeathParticleAlpha = {255}
end

function tweenExplosion()
	if not gameOver and SensorsDestroyed < #Sensor then
		tween(1.5, ParticleAlpha, {0}, "linear")
	end
end

slowmo = {}
slowmo.time = {t = 1}

function slowmo:start()
	if options.graphics.slowmotion and canvasSupported then
		blur = true
		self.time = {t = 0.20}
		cron.after(0.35, slowmoStop)
	end
end

function slowmoStop()
	slowmo.time = {t = 1}
end

function drawVignette()
	if options.graphics.vignette then
		love.graphics.setColor(255,255,255,gameAlpha)
		love.graphics.setBlendMode("multiplicative")
		love.graphics.draw(vignetteImg,0,0,0,scaleX,scaleY)
		love.graphics.setBlendMode("alpha")
	end
end

function tweenGameAlpha(dt)
	gameAlpha = gameAlpha + 350 * dt
	if gameAlpha >= 255 then
	gameAlpha = 255	
	end
end

function tweenTitleY(dt)
	titleY = titleY + 200 * dt
	if titleY >= 20 then titleY = 20 end
end

function getTrajectoryPoint(startingPosition, startingVelocity, n , m)
	--velocity and gravity are given per second but we want time step values here
	local t = 1 / 60 -- seconds per time step (at 60fps)
	local gravityX, gravityY = world:getGravity() 
	local stepVelocity = Vector:new(t * startingVelocity.x/m, t * startingVelocity.y/m) -- m/s
	local stepGravity = Vector:new(t * t * gravityX, t * t * gravityY)-- m/s/s

	return Vector:new(startingPosition.x + n * stepVelocity.x + 0.5 * (n*n+n) * stepGravity.x, startingPosition.y + n * stepVelocity.y + 0.5 * (n*n+n) * stepGravity.y)
end

function menu:callback(cb)
  if cb == "ng" then
   newGame()
  elseif cb == "cont" then  
  continue()
  elseif cb == "op" then
    menu:setstate(2)
  elseif cb == "lvledit" then
	Editor.load()
  elseif cb == "cheats" then
	menu:setstate(5)
  elseif cb == "cr" then
    menu:setstate(4)
  elseif cb == "exit" then
    menu:setstate(3)
  elseif cb == "cexit" then
    love.event.push("quit")
  elseif cb == "fs" then	
    love.graphics.toggleFullscreen()
	saveOptions()
	love.load()
  elseif cb == "res" then
    love.graphics.setMode( videomodes[currentmode].width, videomodes[currentmode].height )
    menu_view[2][2].t = "Resolution ("..love.graphics.getWidth().."x"..love.graphics.getHeight()..")"
    currentmode = ((currentmode)% #videomodes) +1
	saveOptions()
	love.load()
  elseif cb == "sound" then
    options.audio.sfx = not options.audio.sfx	    
	temp_s = tostring(options.audio.sfx)
	if temp_s == "true" then temp_s = "on" else temp_s = "off" end
    menu_view[2][3].t = "Sound ("..temp_s..")"
  elseif cb == "music" then
    options.audio.music = not options.audio.music
	if options.audio.music then TEsound.playLooping("sounds/music.mp3", "music", nil, 0.65) else TEsound.stop("music") end
	temp_m = tostring(options.audio.music)
	if temp_m == "true" then temp_m = "on" else temp_m = "off" end
    menu_view[2][4].t = "Music ("..temp_m..")"
  elseif cb == "inverted" then
    options.controls.inverted = not options.controls.inverted
    temp_inv = tostring(options.controls.inverted)
    if temp_inv == "true" then temp_inv = "yes" else temp_inv = "no" end
    menu_view[2][5].t = "Invert controls ("..temp_inv..")"
  elseif cb == "particles" then
	options.graphics.particleEffects = not options.graphics.particleEffects
    temp_part = tostring(options.graphics.particleEffects)
	if temp_part == "true" then temp_part = "enabled" else temp_part = "disabled" end
	menu_view[2][6].t = "Particle effects ("..temp_part..")"
  elseif cb == "shake" then
	options.graphics.shakeScreen = not options.graphics.shakeScreen
	temp_shake = tostring(options.graphics.shakeScreen)
	if temp_shake == "true" then temp_shake = "enabled" else temp_shake = "disabled" end
	menu_view[2][7].t = "Screen shaking ("..temp_shake..")"
  elseif cb == "slow" then
	options.graphics.slowmotion = not options.graphics.slowmotion
	temp_slow = tostring(options.graphics.slowmotion)
	if temp_slow == "true" then temp_slow = "enabled" else temp_slow = "disabled" end  
	menu_view[2][8].t = "Slow motion ("..temp_slow..")"
  elseif cb == "blur" then
	options.graphics.motionblur = not options.graphics.motionblur
	temp_blur = tostring(options.graphics.motionblur)
	if temp_blur == "true" then temp_blur = "enabled" else temp_blur = "disabled" end
	menu_view[2][9].t = "Motion blur ("..temp_blur..")"
  elseif cb == "vignette" then
	options.graphics.vignette = not options.graphics.vignette
	temp_vignette = tostring(options.graphics.vignette)
	if temp_vignette == "true" then temp_vignette = "enabled" else temp_vignette = "disabled" end
	menu_view[2][10].t = "Vignette ("..temp_vignette..")"
  elseif cb == "grain" then
	options.graphics.shader = not options.graphics.shader
	temp_grain = tostring(options.graphics.shader)
	if temp_grain == "true" then temp_grain = "enabled" else temp_grain = "disabled" end
	menu_view[2][11].t = "Film grain ("..temp_grain..")"
  elseif cb == "god" then
	options.cheats.SensorsAreFtw = not options.cheats.SensorsAreFtw
	temp_god = tostring(options.cheats.SensorsAreFtw)
	if temp_god == "true" then temp_god = "enabled" else temp_god = "disabled" end
	menu_view[5][1].t = "Godmode ("..temp_god..")"  
  elseif cb == "color" then
	options.cheats.colorfulExplosion = not options.cheats.colorfulExplosion
	temp_color = tostring(options.cheats.colorfulExplosion)
	if temp_color == "true" then temp_color = "enabled" else temp_color = "disabled" end
	menu_view[5][2].t = "Colorful explosions ("..temp_color..")"
  elseif cb == "mm" then
	saveOptions()
    menu:setstate(1)
  else
    print("unknown command:"..cb)
  end
end