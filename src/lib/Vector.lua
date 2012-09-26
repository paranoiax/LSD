class "Vector" {
    x = 0;
    y = 0;
}
function Vector:__init(x, y)
    self.x = x
    self.y = y
end
function Vector:print()
    return self.x ..", ".. self.y	
end
function Vector:getLength()
	return math.sqrt((self.x*self.x)+(self.y*self.y))
end
function Vector:normalize(factor)
	local magnitude = self:getLength();
	return Vector:new((self.x/magnitude)*factor, (self.y/magnitude)*factor)
end
function Vector:dotProduct(v)
	return (self.x*v.x) + (self.y*v.y)
end
function Vector:subtract(vec)
	return Vector:new(self.x-vec.x, self.y-vec.y)
end
function Vector:unitVector()
	local length = self:getLength()
	return Vector:new(self.x/length, self.y/length)
end