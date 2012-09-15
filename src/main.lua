do
	local updates = {
		{"lib.hump.gamestate", "gs"},
		"camera",
		"lib.TEsound",
		"lib.AnAL",
		"Game.load",
		"Editor.load",
		"menu",
		"controls",
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

function love.load()	
	options, objects = {
		graphics = {},
		audio = {}
	}, {}
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

	Rectangle = {}
	GreyTiles = love.graphics.newImage('images/quad_grey.png')
	GreyTiles:setWrap("repeat","repeat")	
	GreyTilesW, GreyTilesH = GreyTiles:getWidth(), GreyTiles:getHeight()

	Rectangle2 = {}
	RedTiles = love.graphics.newImage('images/quad.png')
	RedTiles:setWrap("repeat","repeat")	
	RedTilesW, RedTilesH = RedTiles:getWidth(), GreyTiles:getHeight()

	objects.ball = {}
	objects.ball.image = love.graphics.newImage("images/ball_anim.png")
	objects.ball.anim = newAnimation(objects.ball.image, 24, 24, 0.1, 0)
	objects.ball.force = 0.95
	objects.ball.body = love.physics.newBody(world, 0, 0, "dynamic")
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
	
	gameWidth, gameHeight, gameFullscreen, gameVsync, gameFsaa = love.graphics.getMode( )
	if not gameFullscreen then
		love.graphics.toggleFullscreen()
	end
	
	scaleX = screenWidth / 1280
	scaleY = screenHeight / 720
	
	gs.switch(Menu)
end