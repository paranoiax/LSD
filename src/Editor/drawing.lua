local data = Editor.data
local toolbarHeight = 60 -- remember to update the font in main.lua too!
local editor = love.graphics.newFont("fonts/DisplayOTF.otf", toolbarHeight/1.5)
local function init()
	
	do -- topbar menu
		local masterX = screenWidth - 5
		for i,v in ipairs(data.topbar.texts) do
			local buttonWidth = editor:getWidth(v) + 10
			masterX = masterX - buttonWidth
			data.topbar.positions[i] = {
				masterX,
				0,
				buttonWidth,
				toolbarHeight
			}
			masterX = masterX - 5
		end
	end
	
	do -- tools
		local masterX = 0
		local imgWidth = toolbarHeight
		local scale = (imgWidth/800)
		for i,v in ipairs(data.toolbar.components) do
			if type(v) == "table" then
				local index = #data.toolbar.positions + 1
				data.toolbar.positions[index] = {
					i,
					love.graphics.newImage("Editor/icons/"..v[2]),
					masterX,
					0,
					0,
					scale,
					scale
				}
				masterX = masterX + imgWidth
			else
				masterX = masterX + 20
			end
		end
	end
end

function Editor.update(dt)
	objects.ball.anim:update(dt)
end

EditorSelected = {}
function Editor.draw()
	local mx, my = love.mouse.getPosition()
	
	love.graphics.setBackgroundColor(255,255,255)
	love.graphics.setColor(255,255,255)
	love.graphics.setBlendMode("alpha")
	love.graphics.draw(bg,0,0,0,scaleX,scaleY)
	
	-- draw the map, it has to be under every component
	Editor.drawMap()
	
	-- DRAW TOOLBAR BACKGROUND
	love.graphics.setColor(236, 233, 216)
	love.graphics.rectangle("fill", 0, 0, screenWidth, toolbarHeight)
	
	-- DRAW TOOLBAR TOOLS
	love.graphics.setLineWidth(1)
	for i,v in ipairs(data.toolbar.positions) do
		local index, img, x, y, rot, scaleX, scaleY = unpack(v)
		local intersected = intersect(x, y, toolbarHeight, toolbarHeight, mx, my)
		
		if intersected then
			if love.mouse.isDown("l") then
				data.toolbar.selected = i
			elseif data.toolbar.selected == i then
				if Editor.debug then
					table.insert(EditorSelected, data.toolbar.components[index][3]..": "..data.toolbar.components[index][1])
					if #EditorSelected > 10 then
						table.remove(EditorSelected, 1)
					end
				end
				data.toolbar.selected = nil
			end
		elseif (data.toolbar.selected == i) and (not love.mouse.isDown"l") then
			data.toolbar.selected = nil
		end
		
		local alpha = intersected and 200 or 255
		love.graphics.setColor(255, 255, 255, alpha)
		love.graphics.rectangle("fill", x, y, toolbarHeight, toolbarHeight)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(img, x, y, rot, scaleX, scaleY)
		
		local endX = x+toolbarHeight
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.line(endX, 0, endX, toolbarHeight)
		love.graphics.line(x, 0, x, toolbarHeight)
	end
	
	-- DRAW TOOLBAR BUTTONS
	for i,str in ipairs(data.topbar.texts) do
		local x, y, w, h = unpack(data.topbar.positions[i])
		local intersected = intersect(x, y-5, w, h+5, mx, my)
		
		if intersected then
			if love.mouse.isDown("l") then
				data.topbar.selected = i
			elseif data.topbar.selected == i then
				if Editor.debug then
					table.insert(EditorSelected, str)
					if #EditorSelected > 10 then
						table.remove(EditorSelected, 1)
					end
				end
				
				if i == 1 then
					Editor.unload()
					return
				elseif i == 3 then
					Editor.setMap(true)
				elseif i == 4 then
					-- test the stupid map
				end
				data.topbar.selected = nil
			end
		elseif (data.topbar.selected == i) and (not love.mouse.isDown("l")) then
			data.topbar.selected = nil
		end
		
		local alpha = intersected and ( (data.topbar.selected == i) and 50 or 100) or 255
		
		love.graphics.setColor(255, 255, 255, alpha)
		love.graphics.rectangle("fill", x, y, w, h)
		
		love.graphics.setColor(255, 128, 0)
		love.graphics.setFont(editor)
		love.graphics.printf(str, x, y+15, w, "center")
	end
	
	if data.selected then
		-- draw the selected item, if its a circle, draw it, if its whatever, draw whatever.
	end
	
	if Editor.debug then
		love.graphics.setColor(0, 0, 0)
		love.graphics.printf("Selected items:", 0, 300, screenWidth, "center")
		for i,v in ipairs(EditorSelected) do
			love.graphics.printf(v, 0, 50*i + 300, screenWidth, "center")
		end
	end
end

function Editor.drawMap()
	camera:set()
	local map = Editor.map
	
	do -- draw both types of walls
		for _,typ in ipairs{"Rectangle", "Rectangle2"} do
			for i,v in ipairs(_G[typ]) do
				local tile = type=="Rectangle" and "GreyTiles" or "RedTiles"
				love.graphics.setColor(255,255,255)
				love.graphics.drawq(_G[tile], v.quad, v.x, v.y)
			end
		end
	end
	
	do-- draw the flaming character
		local v = map.player
		love.graphics.setColor(255, 255, 255, 255)
		objects.ball.anim:draw(v[1] - objects.ball.shape:getRadius(), v[2] - objects.ball.shape:getRadius())
	end
	camera:unset()
end

return init