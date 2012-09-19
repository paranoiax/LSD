--[[------------------------------------------------
	-- L�ve Frames --
	-- Copyright 2012 Kenny Shields --
--]]------------------------------------------------

-- progress bar class
image = class("image", base)
image:include(loveframes.templates.default)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function image:initialize()

	self.type			= "image"
	self.width 			= 0
	self.height 		= 0
	self.internal		= false
	self.image			= nil
	self.imagecolor		= nil
	
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the object
--]]---------------------------------------------------------
function image:update(dt)

	local visible = self.visible
	local alwaysupdate = self.alwaysupdate
	
	if visible == false then
		if alwaysupdate == false then
			return
		end
	end
	
	-- move to parent if there is a parent
	if self.parent ~= nil then
		self.x = self.parent.x + self.staticx
		self.y = self.parent.y + self.staticy
	end
	
	if self.Update then
		self.Update(self, dt)
	end
	
end

--[[---------------------------------------------------------
	- func: draw()
	- desc: draws the object
--]]---------------------------------------------------------
function image:draw()
	
	local visible = self.visible
	
	if visible == false then
		return
	end
	
	local skins			= loveframes.skins.available
	local skinindex		= loveframes.config["ACTIVESKIN"]
	local defaultskin 	= loveframes.config["DEFAULTSKIN"]
	local selfskin 		= self.skin
	local skin 			= skins[selfskin] or skins[skinindex]
	local drawfunc		= skin.DrawImage or skins[defaultskin].DrawImage
	
	loveframes.drawcount = loveframes.drawcount + 1
	self.draworder = loveframes.drawcount
		
	if self.Draw ~= nil then
		self.Draw(self)
	else
		drawfunc(self)
	end
	
end

--[[---------------------------------------------------------
	- func: SetImage(image)
	- desc: sets the object's image
--]]---------------------------------------------------------
function image:SetImage(image)

	if type(image) == "string" then
		self.image = love.graphics.newImage(image)
	else
		self.image = image
	end
	
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
		
end

--[[---------------------------------------------------------
	- func: GetImage()
	- desc: gets the object's image
--]]---------------------------------------------------------
function image:GetImage()

	return self.image
	
end

--[[---------------------------------------------------------
	- func: SetColor(table)
	- desc: sets the object's color 
--]]---------------------------------------------------------
function image:SetColor(data)

	self.imagecolor = data
	
end

--[[---------------------------------------------------------
	- func: GetColor()
	- desc: gets the object's color 
--]]---------------------------------------------------------
function image:GetColor()

	return self.imagecolor
	
end