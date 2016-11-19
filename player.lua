
isDown = love.keyboard.isDown

Player = Object:new()
function Player:init()
	self.ang = 0

	local body    = P.newBody( world, 0, 0, "dynamic" )
	local radius  = 6
	local shape   = P.newCircleShape( 0, 0, radius )
	local fixture = P.newFixture( body, shape )
	body:setFixedRotation( true )
	--body:setMass( 1 ) -- not necessary right now
	fixture:setUserData( "player" )
	self.body     = body
	self.fixture  = fixture
    self.isDead   = false
end

function Player:setPos( x, y )
	self.body:setX( x )
	self.body:setY( y )
	self.x = x
	self.y = y
end

function Player:pos()
	return self.body:getX(), self.body:getY()
end

function Player:update()
	-- need to split entity physics update from entity logic update

	local ix = (math.max(bool[isDown("right")], bool[isDown("d")])
	    - math.max(bool[isDown("left")], bool[isDown("a")]) )
	    * (1 + bool[isDown("lshift")]*0.5)
	local iy = (math.max(bool[isDown("down")], bool[isDown("s")])
	    - math.max(bool[isDown("up")], bool[isDown("w")]) )
	    * (1 + bool[isDown("lshift")]*0.5)

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

	if vx ~= 0 or vy ~= 0 then
		self.ang = math.atan2(vx, -vy)
	end

	--if vx ~= 0 or vy ~= 0 or accel_x ~= 0 or accel_y ~= 0 then
	--	print( vx, vy )
	--	print( accel_x, accel_y )
	--	print()
	--end
end

function Player:draw()
    

	G.push()
	local x, y = self:pos()
	G.translate(x, y)
	G.rotate(self.ang)
	G.setColor( 255, 192, 192 )
	G.rectangle( "fill", -5, -3, 10, 6 )
	G.pop()

	G.setColor( 255, 255, 255 ) -- reset for others
end

function Player:drawDead()
    G.setNewFont(30)
    G.setColor(255,10,50)
    G.print("YOU ARE DEAD !!!", map.player.body:getX() -125, map.player.body:getY())
    G.setNewFont()
    G.print("Press ENTER to respawn ...", map.player.body:getX() -60, map.player.body:getY()+40)
end
