local sw, sh = love.graphics.getMode()
local frame = loveframes.Create("frame")
frame:SetSize(500, 300)
frame:Center()
frame:SetY(sh-450)
frame:SetName("Options                                                                                                      Press ESC to return to menu")
frame:SetVisible(false)
frame:ShowCloseButton(false)

local tabs = loveframes.Create("tabs", frame)
tabs:SetPos(5, 30)
tabs:SetSize(490, 265)

local tabItems = {
	"General",
	"Audio",
	"Graphics",
	"Cheats"
}

local tabPanels = {}

function preparePanel(i)
	local panel = loveframes.Create"panel"
	local text1 = loveframes.Create("text", panel)
	text1:SetText(tabItems[i])
	
	return panel
end
for i,v in ipairs(tabItems) do
	tabs:AddTab(v, preparePanel(i))
end

function showOptions()
	frame:SetVisible(true)
	GAMESTATE = "OPTIONS"
end

function closeOptions()
	frame:SetVisible(false)
end