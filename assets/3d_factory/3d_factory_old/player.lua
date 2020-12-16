-- the player
function PLAYER(xworld)
	-- the obj file
	local shipobj = loadObj("3d_objs/ship", "ship.obj")
--	LightingV1.apply(shipobj)
	local minx, miny, minz = shipobj.min[1], shipobj.min[2], shipobj.min[3] -- can be negative numbers
	local maxx, maxy, maxz = shipobj.max[1], shipobj.max[2], shipobj.max[3]
	local width, height, length = maxx - minx, maxy - miny, maxz - minz
	--print("shipobj", width, height, length)
	shipobj.shape1 = r3d.SphereShape.new(height / 2) -- front
--	shipobj.shape2 = r3d.BoxShape.new(width / 2, height / 2, length / 2) -- back (middle) XXX
	shipobj.shape2 = r3d.SphereShape.new(height / 2) -- back
	shipobj.shape3 = r3d.SphereShape.new(height / 2) -- right
	shipobj.shape4 = r3d.SphereShape.new(height / 2) -- left
--	shipobj.shape1:setRotationX(90)
	shipobj.frontmass = 64
	shipobj.rearmass = 64
	shipobj.view = Viewport.new()
	shipobj.view:setContent(shipobj)
	shipobj.view:setPosition(0, height * 6, 0) -- ship start position
	shipobj.body = xworld:createBody(shipobj.view:getMatrix())
	shipobj.body:setLinearDamping(0.4)
	local m1, m2, m3, m4 = Matrix.new(), Matrix.new(), Matrix.new(), Matrix.new()
	m1:setPosition(0, 0, -length / 2) -- front
	m2:setPosition(0, 0, length / 2) -- back XXX
	m3:setPosition(-width / 2, 0, 0) -- right
	m4:setPosition(width / 2, 0, 0) -- left
	local fixture1 = shipobj.body:createFixture(shipobj.shape1, m1, shipobj.frontmass) -- shape, transform, mass
	local fixture2 = shipobj.body:createFixture(shipobj.shape2, m2, shipobj.rearmass) -- shape, transform, mass
	local fixture3 = shipobj.body:createFixture(shipobj.shape3, m3, shipobj.frontmass) -- shape, transform, mass
	local fixture4 = shipobj.body:createFixture(shipobj.shape4, m4, shipobj.frontmass) -- shape, transform, mass
	fixture1:setCollisionCategoryBits(PLAYER1)
	fixture2:setCollisionCategoryBits(PLAYER1)
	fixture3:setCollisionCategoryBits(PLAYER1)
	fixture4:setCollisionCategoryBits(PLAYER1)
	fixture1:setCollideWithMaskBits(DESTRUCTIBLES+NONDESTRUCTIBLES)
	fixture2:setCollideWithMaskBits(DESTRUCTIBLES+NONDESTRUCTIBLES)
	fixture3:setCollideWithMaskBits(DESTRUCTIBLES+NONDESTRUCTIBLES)
	fixture4:setCollideWithMaskBits(DESTRUCTIBLES+NONDESTRUCTIBLES)
	--shipobj.body:setType(r3d.Body.DYNAMIC_BODY)
	local mat = shipobj.body:getMaterial() -- default: bounciness = 0.5, frictionCoefficient = 0.3, rollingResistance = 0
	mat.bounciness = 0.1
	mat.frictionCoefficient = 0.3
	mat.rollingResistance = 0.3 -- 0 = no resistance, 1 = max resistance
	shipobj.body:setMaterial(mat)
	--shipobj.body:enableGravity(true)

	return shipobj, shipobj.body
end
