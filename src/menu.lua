function button_spawn(x,y,text, id)
	table.insert(button, {x = x, y = y, text = text, id = id, mouseover = false})
end

function button_draw()
	for i,v in ipairs(button) do		
		love.graphics.setFont(f)
		love.graphics.setColor(10,10,10)
		love.graphics.print(v.text, v.x, v.y)
		if v.mouseover == true then
			love.graphics.setColor(217,177,102)
			love.graphics.print(v.text, v.x -2, v.y -2)
		end
	end
end

function button_click(x,y)
	for i,v in ipairs(button) do
		if x > v.x and
		x < v.x + f:getWidth(v.text) and
		y > v.y and
		y < v.y + f:getHeight(v.text) then
			if v.id == "options" then
				showOptions()
			elseif v.id == "continue" then
				continue()
			elseif v.id == "new_game" then
				newGame()
			elseif v.id == "mapedit" then
				Editor.load()
			elseif v.id == "quit" then
				love.event.push("quit")
			end
		end
	end
end

function button_check()
	for i,v in ipairs(button) do
		if love.mouse:getX() < v.x + f:getWidth(v.text) and
		love.mouse:getX() > v.x and
		love.mouse:getY() < v.y + f:getHeight(v.text) and
		love.mouse:getY() > v.y then
			v.mouseover = true
		else
			v.mouseover = false
		end
	end
end

function menuCursor()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(cursorImg, love.mouse.getX(), love.mouse.getY())
end