Player1 = Core.class(Sprite)

function Player1:init(xworld, xcamera, xparams)
	-- the params
	self.params = xparams or {}
	self.params.posx = xparams.posx or 0
	self.params.posy = xparams.posy or 0
	self.params.posz = xparams.posz or 0
	self.params.rotx = xparams.rotx or 0
	self.params.roty = xparams.roty or 0
	self.params.rotz = xparams.rotz or 0
	self.params.mass = xparams.mass or 1
	self.params.BIT = xparams.BIT or nil
	self.params.colBIT = xparams.colBIT or nil
	-- for camera positioning
	self.camera = xcamera
	-- the mesh
	local xfilemesh = "models/fbx_json/bot_y/bot_y_mesh.json"
	local xfileidle = "models/fbx_json/bot_y/bot_y_idle.json"
	local xfilewalk = "models/fbx_json/bot_y/bot_y_walk.json"
	-- load our model in gdx/g3dj format
	self.mesh = buildGdx(xfilemesh, {
--		["skin"] = { textureFile="Skins/fantasyFemaleB.png", },
	})
	-- scale it down
	local meshscale = 0.02 -- 0.02
	local scalex, scaley, scalez = meshscale, meshscale, meshscale
	self.mesh:setScale(scalex, scaley, scalez)
	-- load two animations from g3dj files
	self.animIdle = buildGdx(xfileidle, {})
	self.animWalk = buildGdx(xfilewalk, {})
	-- sets default animation to idle
	D3Anim.setAnimation(self.mesh, self.animIdle.animations[1], "main", true, 0.5) -- ..., doloop, transition time
	-- we put the mesh in a viewport so we can matrix it
	self.view = Viewport.new()
	self.view:setContent(self.mesh)
	-- *** REACT PHYSICS 3D ***
	-- the body
	self.body = xworld:createBody(self.view:getMatrix())
	self.body:setType(r3d.Body.DYNAMIC_BODY)
	self.body:setLinearDamping(0.999) -- play with it!
	self.body:setAngularDamping(0.999) -- play with it!
	-- the shape
	self.shape = r3d.BoxShape.new(
		self.mesh:getWidth() / 4.5,
		self.mesh:getHeight() / 2,
--		self.mesh:getLength() / 2)
		0.7) -- I CAN'T GET THE DEPTH!
	-- position the collision shape inside the body
	local m1 = Matrix.new()
	m1:setPosition(0, self.mesh:getHeight()/2, 0.4)
	-- the fixture
	local fixture = self.body:createFixture(self.shape, m1, self.params.mass) -- shape, position, mass
	-- materials
	local mat = fixture:getMaterial() -- default: bounciness = 0.5, frictionCoefficient = 0.3, rollingResistance = 0
	mat.bounciness = 0.3
	mat.frictionCoefficient = 0.02
	mat.rollingResistance = 0.9 -- 0 = no resistance, 1 = max resistance
	fixture:setMaterial(mat)
	-- collision bit
	if self.params.BIT then fixture:setCollisionCategoryBits(self.params.BIT) end
	if self.params.colBIT then fixture:setCollideWithMaskBits(self.params.colBIT) end
	-- transform (for Tiled)
	local matrix = self.body:getTransform()
	matrix:setPosition(2*self.params.posx + self.mesh:getWidth(), 2*self.params.posy, -2*self.params.posz - self.mesh:getHeight())
	matrix:setRotationX(self.params.rotx)
	matrix:setRotationY(self.params.roty)
	matrix:setRotationZ(self.params.rotz)
	self.body:setTransform(matrix)
	self.view:setMatrix(matrix)
	-- add mesh to self
	self:addChild(self.mesh)
	-- event listener
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
--	self:addEventListener(Event.KEY_DOWN, self.onKeyDown, self)
--	self:addEventListener(Event.KEY_UP, self.onKeyUp, self)
end

-- GAME LOOP
function Player1:onEnterFrame(e)
	-- move player
	local matrix = self.body:getTransform()
	local force = 1 * self.body:getMass() -- 1
	local ax, ay, az = matrix:transformPoint(0, 0, 0)
	local bx, by, bz = matrix:transformPoint(0, 0, 1) -- 1 because by default the player is facing the camera
	local dx, dy, dz = bx - ax, by - ay, bz - az
	-- position the player model along its body
	self:setMatrix(matrix)
	-- controls
	if self.isup and not self.isdown then self.body:applyForce(^>dx*force, 0, ^>dz*force)
	elseif self.isdown and not self.isup then self.body:applyForce(-^>dx*force, 0, -^>dz*force)
	end
	if self.isleft and not self.isright then self.body:applyTorque(0, -force*24, 0)
	elseif self.isright and not self.isleft then self.body:applyTorque(0, force*24, 0)
	end
end

-- EVENT LISTENERS
function Player1:onKeyDown(e)
	-- controls
	if e.keyCode == KeyCode.UP then self.isup = true end
	if e.keyCode == KeyCode.DOWN then self.isdown = true end
	if e.keyCode == KeyCode.LEFT then self.isleft = true end
	if e.keyCode == KeyCode.RIGHT then self.isright = true end
	-- animations
	if self.isup or self.isdown then
		D3Anim.setAnimation(self.mesh, self.animWalk.animations[1], "main", true, 0.5)
	end
end

function Player1:onKeyUp(e)
	-- controls
	if e.keyCode == KeyCode.UP then self.isup = false end
	if e.keyCode == KeyCode.DOWN then self.isdown = false end
	if e.keyCode == KeyCode.LEFT then self.isleft = false end
	if e.keyCode == KeyCode.RIGHT then self.isright = false end
	-- animations
	if not self.isup and not self.isdown and not self.isleft and not self.isright then
		D3Anim.setAnimation(self.mesh, self.animIdle.animations[1], "main", true, 0.5)
	end
end
