menu = {}

menu.font_title = love.graphics.newFont("menu/assets/Orbitron Black.ttf",64)
menu.font_desc = love.graphics.newFont("menu/assets/League_Gothic-webfont.ttf",22)
menu.font_menu = love.graphics.newFont("menu/assets/League_Gothic-webfont.ttf",26)
menu.icon = love.graphics.newImage("images/icon.png")
menu.padding = 64
menu.option = 0
menu.state = 1
menu.run = true;
function menu:load(views)
  menu.view = views
  menu:calc_offset()
  menu.iconpos = menu.option*menu.font_menu:getHeight()+menu.offset+menu.font_menu:getHeight()/2
  menu.iconcurpos = menu.iconpos
end

function menu:calc_offset()
  menu.offset = love.graphics.getHeight()/2-(menu.font_menu:getHeight()*#menu.view[menu.state])/2
end

function menu:toggle()
  menu.run = not menu.run
end

menu.title_fade = 0
function menu:draw()
  if menu.run then
    local orig_font = love.graphics.getFont()
    local orig_r, orig_g, orig_b, orig_a
    orig_r, orig_g, orig_b, orig_a = love.graphics.getColor( )
    love.graphics.setColor(0,0,0,127)
    love.graphics.rectangle("fill",love.graphics.getWidth()*6/10,0,love.graphics.getWidth()*3/10,love.graphics.getHeight())
    love.graphics.setColor(0,0,0,96+96*math.abs(math.sin(menu.title_fade)))
    love.graphics.setFont(menu.font_title)
    love.graphics.print(
      menu.view[menu.state].title,
      (love.graphics.getWidth()*6/10)/2-(menu.font_title:getWidth(menu.view[menu.state].title)/2),
      love.graphics.getHeight()*0.9-(menu.font_title:getHeight())
    )
    love.graphics.setColor(0,0,0,192)
    love.graphics.setFont(menu.font_desc)
    love.graphics.printf(
      menu.view[menu.state].desc,
      love.graphics.getWidth()*1/10,
      love.graphics.getHeight()*1/10,
      love.graphics.getWidth()*4/10,
       "right"
     )
	 love.graphics.setColor(255,255,255,192)
    love.graphics.setFont(menu.font_menu)
    for i,v in ipairs(menu.view[menu.state]) do
      love.graphics.printf(
        v.t,
        love.graphics.getWidth()*6.5/10,
        (i-1)*menu.font_menu:getHeight()+menu.offset,
        love.graphics.getWidth()*2/10,
        "right"
      )
    end	
    love.graphics.draw(
      menu.icon,
      love.graphics.getWidth()*8.5/10,
      menu.iconcurpos,--wat
      0,1,1,
      0,
      menu.icon:getHeight()/2
    )
    love.graphics.setFont(orig_font)
    love.graphics.setColor(orig_r,orig_g,orig_b,orig_a)
	menu:cursor()
  end
end


function menu:update(dt)
  if menu.run then
    menu.title_fade = menu.title_fade + dt
    menu.iconpos = menu.option*menu.font_menu:getHeight()+menu.offset+menu.font_menu:getHeight()/2
    if menu.iconpos > menu.iconcurpos then
      menu.iconcurpos = menu.iconcurpos + math.abs(menu.iconcurpos-menu.iconpos)/2
    elseif menu.iconpos < menu.iconcurpos then
      menu.iconcurpos = menu.iconcurpos - math.abs(menu.iconcurpos-menu.iconpos)/2
    end
    local temp_test = menu:determine_mouse_choice(love.mouse.getX(),love.mouse.getY())
    if temp_test then
      menu.option = temp_test
    end
  end
end

function menu:keypressed(key)
  if menu.run then
    if key == "escape" then
      menu.option = #menu.view[menu.state]-1
    elseif key == "up" then
      menu.option = (menu.option - 1) % #menu.view[menu.state]
    elseif key == "down" then
      menu.option = (menu.option + 1) % #menu.view[menu.state]
    elseif key == "return" or key == "enter" or key ==" " then
      menu:callback_exec()
    end
  end
end

function menu:callback_exec()
  if menu.callback then
    menu:callback(menu.view[menu.state][menu.option+1].cb)
  else
    print("menu:callback not defined.")
  end
end

function menu:setstate(stateid)
  if menu.view[stateid] then
    menu.option = 0
    menu.state = stateid
  else
    print("Menu state does not exist.")
  end
end

function menu:determine_mouse_choice(x,y)
  local x_start = love.graphics.getWidth()*6.5/10
  local limit = love.graphics.getWidth()*2/10
  for i = 1,#menu.view[menu.state] do
    local y_start = (i-1)*menu.font_menu:getHeight()+menu.offset
    if x >= x_start and x <= x_start + limit and y >= y_start and y <= y_start + menu.font_menu:getHeight() then
       return i-1
    end
  end
end

function menu:mousepressed(x,y,button)
  if menu.run then
    local temp_test = menu:determine_mouse_choice(x,y)
    if temp_test then
      menu.option = temp_test
      menu:callback_exec()
    end
  end
end

function menu:cursor()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(cursorImg, love.mouse.getX(), love.mouse.getY())
end

return menu
