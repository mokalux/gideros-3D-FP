function PLANE_3D(xworld, params)
	-- params
	local params = params or {}
	local xposx = params.posx or 0
	local xposy = params.posy or 0
	local xposz = params.posz or 0
	local xsizex = params.sizex or 1
	local xsizey = params.sizey or 1
	local xsizez = params.sizez or xsizex
	local xrotx = params.rotx or 0
	local xroty = params.roty or 0
	local xrotz = params.rotz or 0
	local xtexpath = params.texpath or nil
	local xtexw = params.texw or 8 * 64
	local xtexh = params.texh or 8 * 64
	-- plane mesh
	local mesh = D3.Mesh.new()
	mesh:setVertexArray{ -xsizex,xsizey,-xsizez,	xsizex,xsizey,-xsizez,	xsizex,xsizey,xsizez,	-xsizex,xsizey,xsizez }
	-- texture coordinates -- make it big (3200, 3200)
	mesh:setTextureCoordinateArray	{	0, 0,	xtexw, 0,	xtexw, xtexh,	0, xtexh	}
	-- normal array
	mesh:setGenericArray( 3, Shader.DFLOAT, 3, 4, { 0,1,0, 0,1,0, 0,1,0, 0,1,0 } )
	mesh:setIndexArray { 1,2,3,	1,3,4 }
	if xtexpath == nil then
		mesh:setTexture( Texture.new( nil, xsizex, xsizez ) )
	else
		mesh:setTexture( Texture.new( xtexpath, true, { wrap = TextureBase.REPEAT } ) )
	end
	-- lighting, shadows, and texture. setTexture doesn't automatically do it
	mesh:updateMode( D3.Mesh.MODE_LIGHTING | D3.Mesh.MODE_SHADOW | D3.Mesh.MODE_TEXTURE )
	-- put it in a viewport so we can matrix it
	local planeview = Viewport.new()
	planeview:setContent(mesh)
	-- transform
	local matrix = planeview:getMatrix()
	matrix:setPosition(xposx, xposy, xposz)
	matrix:setRotationX(xrotx)
	matrix:setRotationY(xroty)
	matrix:setRotationZ(xrotz)
	planeview:setMatrix(matrix)
	-- body
	planeview.body = xworld:createBody(planeview:getMatrix())
	planeview.body:setType(r3d.Body.STATIC_BODY)
	planeview.shape = r3d.BoxShape.new(xsizex, xsizey, xsizez)
	local fixture = planeview.body:createFixture(planeview.shape, nil, 0) -- shape, transform, weight
	fixture:setCollisionCategoryBits(NONDESTRUCTIBLES)
	fixture:setCollideWithMaskBits(PLAYER1+MISSILES+DESTRUCTIBLES)
	xworld.staticbodies[#xworld.staticbodies + 1] = planeview
end
