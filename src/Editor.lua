Editor = {}
local data = {
	topbar = {
		texts = {"Exit", "Clear", "Play"},
		positions = {}
	}
}

function Editor.load()
	GAMESTATE = "EDITOR"
	Editor.mode = "main"
	love.mouse.setVisible(true)
	-- load the editor
	-- by default load level1.lua
	Editor.setMap("level1")
	
	do
		local masterX = screenWidth - 5
		for i,v in ipairs(data.topbar.texts) do
			local buttonWidth = editor:getWidth(v) + 10
			masterX = masterX - buttonWidth
			data.topbar.positions[i] = {
				masterX,
				0,
				buttonWidth,
				35
			}
			masterX = masterX - 5
		end
	end
end

function Editor.setMap(filepath, notify)
	-- notify means it will first ask for confirmation if a map exists and not saved
	-- this function sets the running map (in the editor)
	
	-- ask whether to save
	
	if filepath == "" then return end -- dont throw an error
	Editor.map = love.filesystem.load("levels/"..filepath..".lua")()
	--print(Editor.parse(Editor.map)) -- IT LOOKS LIKE CRAP :)
end

function Editor.saveMap()
	-- saves the map
end

function Editor.unload() -- unloads all hooks and returns to menu

end

function Editor.keypressed(key)
	if key == "escape" then
		Editor.setMap("", true)
		GAMESTATE = "MENU"
		love.filesystem.load("main.lua")()
		love.load()
	elseif key == "f2" then
		Editor.saveMap()
	elseif key == "f1" then
		Editor.showTileSelector()
	end
end

function Editor.update(dt)

end

EditorSelected = {}
function Editor.draw()
	love.graphics.setBackgroundColor(255,255,255)
	love.graphics.setColor(255,255,255)
	love.graphics.setBlendMode("alpha")
	love.graphics.draw(bg,0,0,0,scaleX,scaleY)
	
	-- DRAW TOOLBAR BACKGROUND
	love.graphics.setColor(127, 127, 127)
	love.graphics.rectangle("fill", 0, 0, screenWidth, 35)
	
	-- DRAW TOOLBAR BUTTONS
	for i,str in ipairs(data.topbar.texts) do
		local x, y, w, h = unpack(data.topbar.positions[i])
		local mx, my = love.mouse.getPosition()
		local intersected = intersect(x, y-5, w, h+5, mx, my)
		
		if intersected then
			if love.mouse.isDown("l") then
				data.topbar.selected = i
			elseif data.topbar.selected == i then
				--[[ debug
				table.insert(EditorSelected, str)
				if #EditorSelected > 10 then
					table.remove(EditorSelected, 1)
				end
				--]]
				print("Selected == " .. str)
				data.topbar.selected = nil
			end
		elseif (data.topbar.selected == i) and (not love.mouse.isDown("l")) then
			data.topbar.selected = nil
		end
		
		local alpha = intersected and ( (data.topbar.selected == i) and 50 or 100) or 255
		
		love.graphics.setColor(0, 0, 0, alpha)
		love.graphics.rectangle("fill", x, y, w, h)
		
		love.graphics.setColor(255, 128, 0)
		love.graphics.setFont(editor)
		love.graphics.printf(str, x, y+7, w, "center")
		
		--[[debug
		love.graphics.printf(tostring(intersected), 0, 50*i, screenWidth, "left")
		love.graphics.printf(tostring(alpha), 0, 50*i, screenWidth, "center")
		--]]
	end
	
	--[[ debug
	love.graphics.printf("Selected items:", 0, 300, screenWidth, "center")
	for i,v in ipairs(EditorSelected) do
		love.graphics.printf(v, 0, 50*i + 300, screenWidth, "center")
	end
	--]]
end

function Editor.parse(t, _no)
	print(type(t))
	assert(type(t) == "table", "not a table!")
	local s = "{"
	for k, v in pairs(t) do
		local tk, tv = type(k), type(v)
		if tk == "boolean" then
			k = k and "[true]" or "[false]"
		elseif tk == "string" then
			if string.find(k, "[%c%p%s]") then
				k = '["'..k..'"]'
			end
		elseif tk == "number" then
			k = "["..k.."]"
		elseif tk == "table" then
			k = "["..Editor.parse(k).."]"
		end
		if tv == "boolean" then
			v = v and "true" or "false"
		elseif tv == "string" then
			v = string.format("%q", v)
		elseif tv == "table" then
			v = Editor.parse(v, true)
		end
		s = s..k.."="..v..","
	end
	local ret = _no and "" or "return "
	return s.."}"
end