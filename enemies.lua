


StupidEnemy = Object:new()
function StupidEnemy:init( obj )
	self.name = obj.name
	self.type = obj.type

	local body    = P.newBody( world, obj.x, obj.y, "dynamic" )
	local radius  = math.max( 8, math.max( obj.width, obj.height ) )
	local shape   = P.newCircleShape( radius )
	local fixture = P.newFixture( body, shape )
	fixture:setUserData("enemy")
	body:setMass( 1 )
	body:setLinearDamping( 4, 4 )
	self.body     = body
	self.radius   = radius
    self.id       = obj.properties.id

	self.ai_target = nil
	self.ai_state  = nil
	self.ai_debug  = {}
    self.isBeingControlled = false

	print( "StupidEnemy:init "..tostring(self.name) )
end

function StupidEnemy:update()
	if self.isBeingControlled == false then
        if not self.ai_target then
            self:change_ai_state( "find_target" )
            self:update_find_target()
        else
            self:change_ai_state( "play_target" )
            self:update_play_target()
            self:update_find_target()
        end
    else
        -- this is the input table
        -- let's not use isDown nowhere else
        local input = {
            ix   = bool[isDown("right", "d")] - bool[isDown("left", "a")],
            iy   = bool[isDown("down", "s")] - bool[isDown("up", "w")],
            hack = isDown("space", "e"),
            run  = isDown("lshift", "rshift"),
        }


        local ix = 0
        local iy = 0
        ix = input.ix * (1 + bool[ input.run ] * 0.5)
        iy = input.iy * (1 + bool[ input.run ] * 0.5)

        local v_max       = 85
        local accel_max   = 8.5
        local diagonal    = 1 / math.sqrt(2)
        -- local diagonal    = 1 -- for double speed on diagonal movement
        if ix ~= 0 and iy ~= 0 then
            v_max           = diagonal * v_max
            accel_max       = diagonal * accel_max
        end
        local vx, vy      = self.body:getLinearVelocity()
        local accel_x     = clamp( ix * v_max - vx , -accel_max, accel_max )
        local accel_y     = clamp( iy * v_max - vy , -accel_max, accel_max )
        local mass        = self.body:getMass()
        self.body:applyLinearImpulse( accel_x * mass, accel_y * mass )

        if ( vx ~= 0 or vy ~= 0 ) and ( ix ~= 0 or iy ~= 0 ) then
            self.ang = math.atan2(vx, -vy)
        end

        if isDown("escape") then
            self.isBeingControlled = false
            map.player.isControlling = false
        end

	end
end

function StupidEnemy:draw()
	local x, y = self.body:getPosition()
	G.setColor( 96, 96, 96 )
	G.circle( "fill", x, y, self.radius )
	
	if isDown( "f3" ) then
	  self:draw_debug_ai()
  end
end



function StupidEnemy:draw_debug_ai()
  G.setColor( 255, 0, 0 )
  for _, stuff in ipairs( self.ai_debug ) do
    local t, x1, y1, x2, y2  = unpack( stuff )
    if t == "dot" then
      G.circle( "fill", x1, y1, 3 )
    elseif t == "line" then
      G.line( x1, y1, x2, y2 )
    end
  end
  self.ai_debug = {}
end

function StupidEnemy:change_ai_state( state )
	if self.ai_state == state then return end
	self.ai_state = state
	if self.name then
		print( self.name.." ai_state: "..tostring( self.ai_state ) )
	end
end

function StupidEnemy:update_find_target()
	local player = map.player
	if not player then return end
	local x1, y1 = self.body:getPosition()
	local x2, y2 = player:pos()
	
	if isDown( "f3" ) then
		table.insert( self.ai_debug, { "line", x1, y1, x2, y2 } )
	end
	
	world:rayCast( x1, y1, x2, y2,
		function( fixture, x, y, xn, yn, fraction )
			if isDown( "f3" ) then
				table.insert( self.ai_debug, { "dot", x, y } )
			end
		
			local user_data = fixture:getUserData()
			if user_data == "wall" or user_data == "door" then
				self.ai_target = nil
				return 0
			elseif user_data == "player" then
				self.ai_target = player
				return 1
			end
			return 1
		end
	)
end

function StupidEnemy:update_play_target()
	local a = V( self.body:getPosition() )
	local b = V( self.ai_target:pos() )
	local d = b - a
	d:norm()
	d:mul( 4 )
	self.body:applyLinearImpulse( d.x, d.y )
end


function StupidEnemy:pos()
	return self.body:getX(), self.body:getY()
end

V = Object:new()
function V:init( x, y )
	self.x = x or 0
	self.y = y or 0
end

function V:__tostring()
	return "V("..tostring(self.x)..", "..tostring(self.y)..")"
end
function V:__concat(other)
	return other..tostring(self)
end

function V:__add(other)
	return V( self.x + other.x, self.y + other.y )
end

function V:add(other)
	self.x = self.x + other.x
	self.y = self.y + other.y
end

function V:__sub(other)
	return V( self.x - other.x, self.y - other.y )
end

function V:sub(other)
	self.x = self.x - other.x
	self.y = self.y - other.y
end

function V:__mul(other)
	return V( self.x * other, self.y * other )
end

function V:mul(other)
	self.x = self.x * other
	self.y = self.y * other
end

function V:__div(other)
	return V( self.x / other, self.y / other )
end

function V:__unm()
	return V( -self.x, -self.y )
end

function V:__pow(other)
	return V( self.x ^ other, self.y ^ other )
end

function V:__eq(other)
	return self.x == other.x and self.y == other.y
end

function V:__lt(other)
	return self:length2() < other:length2()
end

function V:__le(other)
	local a = self:length2()
	local b = other:length2()
	return a < b or a == b
end

function V:length2()
	return self.x^2 + self.y^2
end

function V:length()
	return math.sqrt(self.x^2 + self.y^2)
end

function V:angle()
	return math.atan2(self.x, self.y)
end

function V:distance2(other)
	return (other.x-self.x)^2+(other.y-self.y)^2
end

function V:distance(other)
	return math.sqrt((other.x-self.x)^2+(other.y-self.y)^2)
end

function V:copy()
	return V( self.x, self.y )
end

function V:norm()
	local l = self:length()
	self.x = self.x / l
	self.y = self.y / l
end
