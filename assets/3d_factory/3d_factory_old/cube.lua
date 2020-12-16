function cube_factory(xworld, params)
	-- params
	local params = params or {}
	xposx = params.posx or 0
	xposy = params.posy or 0
	xposz = params.posz or 0
	xsizex = params.sizex or 1
	xsizey = params.sizey or xsizex
	xsizez = params.sizez or xsizex
	xrotx = params.rotx or 0
	xroty = params.roty or 0
	xrotz = params.rotz or 0
	xtexpath = params.texpath or "3d_objs/texs/box.png"
	xmass = params.mass or 10
	xgravity = params.gravity
	-- the box mesh
	local cube = D3.Cube.new(xsizex, xsizey, xsizez)
	cube:mapTexture(Texture.new(xtexpath, true))
	cube:updateMode( D3.Mesh.MODE_LIGHTING | D3.Mesh.MODE_SHADOW )
	-- put it in a viewport so we can matrix it
	local cubeview = Viewport.new()
	cubeview:setContent(cube)
	-- transform
	matrix = cubeview:getMatrix()
	matrix:setPosition(xposx, xposy, xposz)
	matrix:setRotationX(xrotx)
	matrix:setRotationY(xroty)
	matrix:setRotationZ(xrotz)
	cubeview:setMatrix(matrix)
	-- body
	cubeview.body = xworld:createBody(cubeview:getMatrix())
	cubeview.shape = r3d.BoxShape.new(xsizex, xsizey, xsizez)
	local fixture1 = cubeview.body:createFixture(cubeview.shape, nil, xmass)
	fixture1:setCollisionCategoryBits(DESTRUCTIBLES)
	fixture1:setCollideWithMaskBits(MISSILES+DESTRUCTIBLES+NONDESTRUCTIBLES)
	if xgravity then cubeview.body:enableGravity(xgravity) end
	xworld.cubes[cubeview] = {xbody=cubeview.body}

--	return cubeview, cubeview.body
end
