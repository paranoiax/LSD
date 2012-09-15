Game = gs:new()

function Game:init()
	require "Game.drawing"
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
				--v.r, v.g, v.b = math.random(255),math.random(255),math.random(255) --Colorful Explosions / Set a boolean variable for "original mappack completed" if true activate this (maybe)
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
	checkWin()
	nextLevel(dt)
	game_over(dt)
	outOfBounds()
	cron.update(dt)
	tween.update(dt)
end
