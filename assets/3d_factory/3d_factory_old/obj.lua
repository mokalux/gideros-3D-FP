function obj_factory(xworld, folderpath, objname, params)
	-- params
	local params = params or {}
	xposx = params.posx or 0
	xposy = params.posy or 0
	xposz = params.posz or 0
	xrotx = params.rotx or 0
	xroty = params.roty or 0
	xrotz = params.rotz or 0
	xmass = params.mass or 10
	xgravity = params.gravity
	xshooter = params.shooter or nil
	xismissile = params.ismissile or false
	-- some vars
	local minx, miny, minz -- can be negative
	local maxx, maxy, maxz
	local width, height, length -- obj dimensions
	-- the .obj
	local obj = loadObj(folderpath, objname)
--	LightingV1.apply(obj)
	minx, miny, minz = obj.min[1], obj.min[2], obj.min[3] -- can be negative numbers
	maxx, maxy, maxz = obj.max[1], obj.max[2], obj.max[3]
	width, height, length = maxx - minx, maxy - miny, maxz - minz
--	print("obj", width, height, length)
	obj.shape1 = r3d.BoxShape.new(width / 2, height / 2, length / 2)
	-- the viewport
	local objview = Viewport.new()
	objview:setContent(obj)
	-- transform
	matrix = objview:getMatrix()
	matrix:setPosition(xposx, height / 2 + 1 <> xposy + 1, xposz)
	matrix:setRotationX(xrotx)
	matrix:setRotationY(xroty)
	matrix:setRotationZ(xrotz)
	objview:setMatrix(matrix)
	-- the body
	objview.body = xworld:createBody(objview:getMatrix())
	-- shape position in the body
	local m1 = Matrix.new()
	m1:setPosition(0, 0, 0) -- shape1 position
	local fixture1 = objview.body:createFixture(obj.shape1, m1, xmass) -- shape, transform, mass
--	objview.body:setType(r3d.Body.DYNAMIC_BODY)
	local mat = objview.body:getMaterial() -- default: bounciness = 0.5, frictionCoefficient = 0.3, rollingResistance = 0
	mat.bounciness = 0.1
	mat.frictionCoefficient = 0.5
	mat.rollingResistance = 0.1 -- 0 = no resistance, 1 = max resistance
	objview.body:setMaterial(mat)
	if xismissile then
		objview.body:enableGravity(false)
		matrix = xshooter:getMatrix()
		obj:setMatrix(matrix)
		fixture1:setCollisionCategoryBits(MISSILES)
		fixture1:setCollideWithMaskBits(DESTRUCTIBLES+NONDESTRUCTIBLES)
		xworld.missiles[obj] = {xbody=objview.body, xdx=xrotx, xdy=xroty, xdz=xrotz, isdirty=false}
		return obj
	else
		if xgravity ~= nil then
			objview.body:enableGravity(xgravity)
		else
			objview.body:enableGravity(true)
		end
		fixture1:setCollisionCategoryBits(DESTRUCTIBLES)
		fixture1:setCollideWithMaskBits(NONDESTRUCTIBLES+PLAYER1+MISSILES)
		xworld.objs[obj] = {xbody=objview.body}
	end
	-- align the obj with the body
--	objview.body:setTransform(matrix)
	obj:setMatrix(matrix)

--	return obj, objview.body
end
