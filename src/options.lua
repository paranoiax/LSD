options = {
	graphics = {},
	audio = {},
	cheats = {},
	controls = {}
}

if love.filesystem.exists("settings.lua") then
	love.filesystem.load("settings.lua")()
else
	ResX = 0
	ResY = 0
	ResFull = true
	options.audio.music = true
	options.audio.sfx = true
	options.controls.inverted = false
	options.graphics.particleEffects = true
	options.graphics.shakeScreen = true
	options.graphics.slowmotion = true
	options.graphics.motionblur = true
	options.graphics.vignette = true -- seriously cuts the framerate
	options.graphics.shader = true
	options.cheats.timeOut = false
	options.cheats.SensorsAreFtw = false
	options.cheats.colorfulExplosion = false
	love.filesystem.newFile("settings.lua")
	local settings = [[
ResX = 0
ResY = 0
ResFull = true
options.audio.music = true
options.audio.sfx = true
options.controls.inverted = false
options.graphics.particleEffects = true
options.graphics.shakeScreen = true
options.graphics.slowmotion = true
options.graphics.motionblur = true
options.graphics.vignette = true -- seriously cuts the framerate
options.graphics.shader = true
options.cheats.timeOut = false
options.cheats.SensorsAreFtw = false
options.cheats.colorfulExplosion = false]]
	love.filesystem.write("settings.lua", settings)
end

function saveOptions()
	local w,h,fs,vs,aa = love.graphics:getMode()
	local set = ""
	set = set .. "ResX = " .. w .. "\n"
	set = set .. "ResY = " .. h .. "\n"
	set = set .. "ResFull = " .. tostring(fs) .. "\n"
	set = set .. "options.audio.music = " .. tostring(options.audio.music) .. "\n"
	set = set .. "options.audio.sfx = " .. tostring(options.audio.sfx) .. "\n"
	set = set .. "options.controls.inverted = " .. tostring(options.controls.inverted) .. "\n"
	set = set .. "options.graphics.particleEffects = " .. tostring(options.graphics.particleEffects) .. "\n"
	set = set .. "options.graphics.shakeScreen = " .. tostring(options.graphics.shakeScreen) .. "\n"
	set = set .. "options.graphics.slowmotion = " .. tostring(options.graphics.slowmotion) .. "\n"
	set = set .. "options.graphics.motionblur = " .. tostring(options.graphics.motionblur) .. "\n"
	set = set .. "options.graphics.vignette = " .. tostring(options.graphics.vignette) .. "\n"
	set = set .. "options.graphics.shader = " .. tostring(options.graphics.shader) .. "\n"
	set = set .. "options.cheats.timeOut = " .. tostring(options.cheats.timeOut) .. "\n"
	set = set .. "options.cheats.SensorsAreFtw = " .. tostring(options.cheats.SensorsAreFtw) .. "\n"
	set = set .. "options.cheats.colorfulExplosion = " .. tostring(options.cheats.colorfulExplosion)
	love.filesystem.write("settings.lua", set)
end

local savedMode = {ResX,ResY,ResFull,false,0}
if love.graphics.getMode ~= savedMode then
	love.graphics.setMode(ResX,ResY,ResFull,false,0)
end

local strfrm = string.format
function string.format(...)
	local args = {...}
	local t = {}
	for i,v in ipairs(args) do
		t[i] = tostring(v)
	end
	return strfrm(unpack(t))
end