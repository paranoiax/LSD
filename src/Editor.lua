Editor = {}
collision = require 'collision'

function Editor.load()	
	GAMESTATE = "EDITOR"
	love.filesystem.load("main.lua")()
	love.load()
	if not love.filesystem.exists('maps') then
		love.filesystem.mkdir('maps')
	end
end
	
	Editor.speed = 4
	maps = love.filesystem.enumerate('maps')
	maps = #maps
	ground = love.graphics.getHeight() - 160
	object = {}
	currentObject = "wall"	
	walls = {}
	player = {}
	player.isSet = false
	sensors = {}
	gui = {
		w  = 50,
		h  = 50
	}
	love.graphics.setLine(4, 'smooth')
	
	playerX, playerY = 0,0
	
	font = {
		default = love.graphics.newFont(12),
		huge    = love.graphics.newFont(32)}
		
	--ALL YOUR BASE ARE BELONG TO US
	playerImg = love.graphics.newImage("images/player.png")
	
	RectangleEditor = {}
	RectangleEditor2 = {}

function Editor.update(dt)
	if love.keyboard.isDown("up") then
		camera.y = camera.y - 100 * dt * Editor.speed
	end
	if love.keyboard.isDown("down") then
		camera.y = camera.y + 100 * dt * Editor.speed
	end
	if love.keyboard.isDown("left") then
		camera.x = camera.x - 100 * dt * Editor.speed
	end
	if love.keyboard.isDown("right") then
		camera.x = camera.x + 100 * dt * Editor.speed
	end

	if love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift") then --This is crap code but it's 3 a.m. and I need to get this working.
		Editor.speed = 8
	else
		Editor.speed = 4
	end
	
	for i,v in ipairs(RectangleEditor) do
		v.quad = love.graphics.newQuad(0, 0, v.w, v.h, GreyTilesW, GreyTilesW)
	end
	
	for i,v in ipairs(RectangleEditor2) do
		v.quad = love.graphics.newQuad(0, 0, v.w, v.h, RedTilesW, RedTilesW)
	end	
	
end

function Editor.draw()
	
	local width = love.graphics.getWidth()
	local x, y = love.mouse.getPosition()
	x, y = x + camera.x, y + camera.y
	love.graphics.setColor(100, 50, 0)
	love.graphics.line(-4, ground, width+4, ground)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print('Width:  ' .. gui.w, 0, 768)
	love.graphics.print('Height: ' .. gui.h, width*0.2, 768)
	love.graphics.print('Maps: ' .. maps, width*0.4, 768)
	love.graphics.print('object: ' .. currentObject, width*0.6, 768)
	love.graphics.setFont(font.default)
	love.graphics.setColor(255,255,255)
	for i = 1,9 do
		if love.filesystem.exists('maps/level'..i..'.lua') then
			love.graphics.setColor(255,255,255)
		else
			love.graphics.setColor(128,128,128,200)
		end
		love.graphics.print('level'..i..'.lua', width*(i-1)/9, 784)
	end
	camera:set()
	
	for i,v in ipairs(RectangleEditor) do
		love.graphics.setColor(255,255,255)
		love.graphics.drawq(GreyTiles,v.quad,v.x,v.y)
	end
	
	for i,v in ipairs(RectangleEditor2) do
		love.graphics.setColor(255,255,255)
		love.graphics.drawq(RedTiles,v.quad,v.x,v.y)
	end
	
	love.graphics.setColor(255,255,255)
	if player.isSet then
		love.graphics.draw(playerImg, playerX - playerImg:getWidth() / 2, playerY - playerImg:getHeight() / 2)
	end
	
	if currentObject == "wall" then
		currentQuad = RedTiles
	end
	if currentObject == "sensor" then
		currentQuad = GreyTiles
	end
	if currentObject == "player" then
		love.graphics.setColor(255,255,255,150)
		love.graphics.draw(playerImg, x - playerImg:getWidth() / 2, y - playerImg:getHeight() / 2)
	end
	if y < 769 and currentObject ~= "player" then
		x, y = (math.floor((x / 10)) * 10), (math.floor((y / 10)) * 10) --snap to grid
		--love.graphics.rectangle('fill', x, y, gui.w, gui.h)
		love.graphics.setColor(255,255,255,150)
		EditorQuad = love.graphics.newQuad(0, 0, gui.w, gui.h, GreyTilesW, GreyTilesW)
		love.graphics.drawq(currentQuad,EditorQuad,x,y)
	end
	camera:unset()
end

function Editor.unload() -- unloads all hooks and returns to menu
	camera.x = 0
	camera.y = 0
	sensors = {}
	walls = {}
	object = {}
	RectangleEditor = {}
	RectangleEditor2 = {}
	playerX, playerY = 0,0
	player.isSet = false
	GAMESTATE = "MENU"
	love.filesystem.load("main.lua")()
	love.load()
end

function generateCode() --If this code works, it was written by Kai. If not, I don't know who wrote it.
  local ret = '' -- I am not sure if we need this, but too scared to delete. 
  ret = "return {\n\n"
  
  if player.isSet then
	ret = ret .. '\t' .. 'player = {' .. math.floor(playerX + .5) .. ', ' .. math.floor(playerY + .5) .. '},\n'
  end
  ret = ret .. '\t' .. 'boundaries = 5000,\n\n'
  
  ret = ret .. '\t' .. 'walls = {\n'
  
  for i, v in ipairs(walls) do
    ret = ret .. '\t' .. '{' .. v.x .. ', ' .. v.y+v.h .. ', ' .. v.w .. ', ' .. v.h .. '},\n' --Magic. Do not touch.
  end
  
  ret = ret .. '\t' .. '},\n\n' -- drunk, fix later
  
  ret = ret .. '\t' .. 'sensors = {\n'
  for i, v in ipairs(sensors) do
    ret = ret .. "        {" .. v.x .. ', ' .. v.y+v.h .. ', ' .. v.w .. ', ' .. v.h .. '},\n'
  end
  
  ret = ret .. '\t' .. '}\n\n}'
  
  return ret
end