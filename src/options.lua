local sw, sh = love.graphics.getMode()
local frame = loveframes.Create("frame")
frame:SetSize(500, 300)
frame:Center()
frame:SetY(sh-450)
frame:SetName("Options                                                                                                      Press ESC to return to menu")
frame:SetVisible(false)
frame:ShowCloseButton(false)

function showOptions()
	frame:SetVisible(true)
	GAMESTATE = "OPTIONS"
end

function closeOptions()
	frame:SetVisible(false)
end