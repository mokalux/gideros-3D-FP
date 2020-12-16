function obj_flat_factory(xworld, folderpath, objname, params)
	-- params
	local params = params or {}
	xposx = params.posx or 0
	xposy = params.posy or 0
	xposz = params.posz or 0
	xrotx = params.rotx or 0
	xroty = params.roty or 0
	xrotz = params.rotz or 0
	xmass = params.mass or 10
	xgravity = params.gravity or nil
	-- the .obj
	local obj = loadObj(folderpath, objname)
--	LightingV1.apply(obj)
	local minx, miny, minz = obj.min[1], obj.min[2], obj.min[3] -- can be negative numbers
	local maxx, maxy, maxz = obj.max[1], obj.max[2], obj.max[3]
	local width, height, length = maxx - minx, maxy - miny, maxz - minz
--	print("obj", width, height, length)
	obj.shape = r3d.BoxShape.new(width / 2, 0.001, length / 2) -- XXX
	-- the viewport
	local objview = Viewport.new()
	objview:setContent(obj)
	-- transform
	matrix = objview:getMatrix()
	matrix:setPosition(xposx, xposy <> height / 2, xposz)
	matrix:setRotationX(xrotx)
	matrix:setRotationY(xroty)
	matrix:setRotationZ(xrotz)
	objview:setMatrix(matrix)
	-- the body
	objview.body = xworld:createBody(objview:getMatrix())
	local fixture = objview.body:createFixture(obj.shape, nil, xmass) -- shape, transform, mass
	objview.body:setType(r3d.Body.STATIC_BODY)
--	local mat = objview.body:getMaterial() -- default: bounciness = 0.5, frictionCoefficient = 0.3, rollingResistance = 0
	local mat = obj.shape:getMaterial() -- default: bounciness = 0.5, frictionCoefficient = 0.3, rollingResistance = 0
	mat.bounciness = 0
	mat.frictionCoefficient = 1
	mat.rollingResistance = 1 -- 0 = no resistance, 1 = max resistance
	objview.body:setMaterial(mat)
	if xgravity ~= nil then
		objview.body:enableGravity(xgravity)
	else
		objview.body:enableGravity(true)
	end
	fixture:setCollisionCategoryBits(NONDESTRUCTIBLES)
	fixture:setCollideWithMaskBits(DESTRUCTIBLES+PLAYER1+MISSILES)
	xworld.objs[obj] = {xbody=objview.body}
	-- align the obj with the body
	obj:setMatrix(matrix)

--	return obj, objview.body
end
