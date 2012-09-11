local data = Editor.data
data.topbar = { -- only for the menu
	texts = {"Exit", "Options", "Clear", "Play"},
	positions = {}
}


	
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
				35
			}
			masterX = masterX - 5
		end
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
				if i == 1 then
					Editor.unload()
				elseif i == 3 then
					Editor.map = {}
				elseif i == 4 then
					-- test the stupid map
				end
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

return init