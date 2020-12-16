function cube_factory(xworld, xparams)
	-- params
	local params = xparams or {}
	params.posx = xparams.posx or 0
	params.posy = xparams.posy or 0
	params.posz = xparams.posz or 0
	params.sizex = xparams.sizex or 1
	params.sizey = xparams.sizey or params.sizex
	params.sizez = xparams.sizez or params.sizex
	params.rotx = xparams.rotx or 0
	params.roty = xparams.roty or 0
	params.rotz = xparams.rotz or 0
	params.texpath = xparams.texpath or "3d_objs/texs/box.png"
	params.mass = xparams.mass or 10
	params.gravity = xparams.gravity or 1
	-- the box mesh
	local mesh = D3.Cube.new(params.sizex, params.sizey, params.sizez)
	mesh:mapTexture(Texture.new(params.texpath, true))
	mesh:updateMode( D3.Mesh.MODE_LIGHTING + D3.Mesh.MODE_SHADOW )
	-- we put the mesh in a viewport so we can matrix it
	local cubeview = Viewport.new()
	cubeview:setContent(mesh)
	-- body
	cubeview.body = xworld:createBody(cubeview:getMatrix())
	cubeview.body:setType(r3d.Body.STATIC_BODY)
	local shape = r3d.BoxShape.new(params.sizex, params.sizey, params.sizez)
	local fixture = cubeview.body:createFixture(shape, nil, 0)
--	fixture1:setCollisionCategoryBits(DESTRUCTIBLES)
--	fixture1:setCollideWithMaskBits(MISSILES+DESTRUCTIBLES+NONDESTRUCTIBLES)
--	if params.gravity then cubeview.body:enableGravity(params.gravity) end
	-- transform
	local matrix = cubeview.body:getTransform()
	matrix:setPosition(2*params.posx + params.sizex, params.posy + params.sizey, -2*params.posz - params.sizez)
	matrix:setRotationX(params.rotx)
	matrix:setRotationY(params.roty)
	matrix:setRotationZ(params.rotz)
	cubeview.body:setTransform(matrix)
	cubeview:setMatrix(matrix)
	-- add it to world static body list
	xworld.staticbodies[#xworld.staticbodies + 1] = cubeview
end
