function Game:draw(mx,my)
	local data = Game.data
	love.graphics.setBackgroundColor(255,255,255)
	love.graphics.setColor(255,255,255)
	love.graphics.setBlendMode("alpha")
	love.graphics.draw(bg,0,0,0,scaleX,scaleY)
	
	camera:set()
	if options.graphics.shakeScreen then
		camera:shake()
	end
	
	love.graphics.setLine(3, "smooth")
	
	if aiming and objects.ball.canJump then
		-- The fadeout has been commented, see the issue posted.
		--love.graphics.setColor(202,143,84,-distanceFrom(data.objects.ball.body.x,data.objects.ball.body.y,mx + camera.x,love.mouse.getY() + camera.y))
		love.graphics.setColor(202,143,84,255)
		love.graphics.line(data.objects.ball.body.x, data.objects.ball.body.y, mx + camera.x, my + camera.y)
	end	
	
	if objects.ball.isAlive then
		love.graphics.setColor(255,255,255)
		objects.ball.anim:draw(data.objects.ball.body.x - objects.ball.shape:getRadius(), data.objects.ball.body.y - objects.ball.shape:getRadius())
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
		love.graphics.setColor(69,69,69,ParticleAlpha[1]) --(v.r, v.g, v.b)
		love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
	end		
	
	for i,v in ipairs(DeathParticle) do
		love.graphics.setColor(202,143,84,DeathParticleAlpha[1])
		love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))	
	end
	
	-- draw red and grey rectangle
	for ti,v in pairs{Grey="", Red="2"} do
		local tab = _G["Rectangle"..v]
		local tile = _G[ti.."Tiles"]
		for i,v in ipairs(tab) do
			if not _G[ti=="Red" and "Wall" or "Sensor"][i].isDestroyed then
				love.graphics.setColor(255,255,255)
				love.graphics.drawq(tile, v.quad, v.x, v.y)
			end
		end
	end			
	
	love.graphics.setFont(e)
	love.graphics.setColor(10,10,10)
	love.graphics.printf(SensorsDestroyed .."/"..SensorsCount,2 + camera.x, 22 + camera.y, screenWidth, "center")
	love.graphics.setColor(217,177,102)
	love.graphics.printf(SensorsDestroyed .."/"..SensorsCount,0 + camera.x, 20 + camera.y, screenWidth, "center")
	
	if win then
		-- love.graphics.setFont(e) -- it has already been set to "e" above
		love.graphics.setColor(10,10,10)
		love.graphics.printf("Level Completed!",2 + camera.x, screenHeight / 2 - 50 + camera.y, screenWidth, "center")
		love.graphics.setColor(217,177,102)
		love.graphics.printf("Level Completed!",0 + camera.x, screenHeight / 2 - 52 + camera.y, screenWidth, "center")
	end
	
	if gameOver and not win then
		--love.graphics.setFont(e) -- it has already been set to "e" above
		love.graphics.setColor(10,10,10)
		love.graphics.printf("Try Again!",2 + camera.x, screenHeight / 2 - 50 + camera.y, screenWidth, "center")
		love.graphics.setColor(217,177,102)
		love.graphics.printf("Try Again!",0 + camera.x, screenHeight / 2 - 52 + camera.y, screenWidth, "center")
	end
	
	camera:unset()
	
	-- CROSSHAIR
	love.graphics.setColor(202,143,84)
	love.graphics.line(mx -7, my - 7, mx + 7, my + 7)
	love.graphics.line(mx +7, my - 7, mx - 7, my + 7)
	
	
	love.graphics.setColor(0,0,0,180)
	love.graphics.rectangle("fill", 0, screenHeight - 50, screenWidth * explosionTime, 50)
end