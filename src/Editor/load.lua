--if true then return end
Editor = gs:new()
require("Editor.drawing")
Editor.data = {}
local data = setmetatable({}, {
	__index = function(_,k,v)
		return rawget(Editor.data, k)
	end,
	__newindex = function(t,k,v)
		rawset(Editor.data, k, v)
	end
})

function Editor:init()
	require"Editor.data"
	require"Editor.tools"
	local toolbarHeight = 60
	editor = love.graphics.newFont("fonts/DisplayOTF.otf", toolbarHeight/1.5)
	
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
				local img = love.graphics.newImage("Editor/icons/"..v[2])
				data.toolbar.img[v[3]] = img
				
				data.toolbar.positions[index] = {
					i,
					img,
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

function Editor:enter()
	
	Editor.mode = "main"
	Editor.debug = true

	-- load the editor
	-- by default load level1.lua
	Editor.setMap("original/level1")

end

function Editor.setMap(filepath, notify)
	-- notify means it will first ask for confirmation if a map exists and not saved
	-- this function sets the running map (in the editor)
	
	-- ask whether to save
	if notify then
		-- notify the setter to save if it was saved
	end
	
	if filepath == "" then return end -- dont throw an error

	Editor.map = filepath==true and loadstring(data.newmap)() or love.filesystem.load("levels/"..filepath..".lua")()
	data.map = {}
	
	camera.x = Editor.map.player[1] - screenWidth / 2
	camera.y = Editor.map.player[2] - screenHeight / 2
	
	for rectA,tab in pairs{[{"", "Grey"}]=Editor.map.sensors, [{"2","Red"}]=Editor.map.walls} do
		for i,v in ipairs(tab) do
			local x, y, w, h = unpack(v)
			_G["Rectangle"..rectA[1]][i] = {
				quad = love.graphics.newQuad(0, 0, w, h, _G[rectA[2].."TilesW"], _G[rectA[2].."TilesW"]),
				x = x,
				y = y
			}
		end
	end
	--[[
	for tile,tab in pairs({["Grey"]="sensors", ["Red"]="walls"}) do
		data.map[tab] = {}
		if Editor.map[tab] then
			for i,v in ipairs(Editor.map[tab]) do
				local x, y, w, h = unpack(v)
				local x2, y2, w2, h2 = x - w / 2, y - w / 2, w, h
				data.map[tab][i] = {
					quad = love.graphics.newQuad(x+w/2, y+h/2, w2, h2, _G[tile.."TilesW"], _G[tile.."TilesW"]),
					x = x2,
					y = y2,
					tile = tile
				}
			end
		end
	end]]
	
	--print(Editor.parse(Editor.map)) -- IT LOOKS LIKE CRAP :)
end

function Editor.saveMap()
	-- saves the map
end

function Editor.unload() -- unloads all hooks and returns to menu
	Editor.setMap("", true)
	gs.switch(Menu)
end

function Editor:keypressed(key, unicode)
	if key == "escape" then
		Editor.unload()
	elseif key == "f2" then
		Editor.saveMap()
	elseif key == "f1" then
		Editor.showTileSelector()
	end
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