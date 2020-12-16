Player1 = Core.class(Sprite)

function Player1:init(xworld, xcamera, xparams)
	-- for camera positioning
	self.camera = xcamera
	-- the params
	self.params = xparams or {}
	self.params.posx = xparams.posx or 0
	self.params.posy = xparams.posy or 0
	self.params.posz = xparams.posz or 0
	-- our 3D mesh
	local xfilemesh = "models/bot_y/bot_y_mesh.json"
	local xfileidle = "models/bot_y/bot_y_idle.json"
	local xfilewalk = "models/bot_y/bot_y_walk.json"
	-- load our model in gdx/g3dj format
	self.mesh = buildGdx(xfilemesh, {
--		["skin"] = { textureFile="Skins/fantasyFemaleB.png", },
	})
	-- scale it down (it is too big)
	local meshscale = 0.015 -- 0.02
	self.scalex, self.scaley, self.scalez = meshscale, meshscale, meshscale -- can be local!
	self.mesh:setScale(self.scalex, self.scaley, self.scalez)
	-- load two animations from g3dj files
	self.animIdle = buildGdx(xfileidle, {})
	self.animWalk = buildGdx(xfilewalk, {})
	-- sets default animation to idle
	D3Anim.setAnimation(self.mesh, self.animIdle.animations[1], "main", true, 0.5) -- ..., doloop, transition time
	-- *** REACT PHYSICS 3D ***
	-- we put the mesh in a viewport so we can matrix it
	self.player1view = Viewport.new()
	self.player1view:setContent(self.mesh)
	-- the body
	self.body = xworld:createBody(self.player1view:getMatrix())
	self.body:setType(r3d.Body.DYNAMIC_BODY)
	-- the shape
	self.shape = r3d.BoxShape.new(
		self.mesh:getWidth() / 4,
		self.mesh:getHeight() / 2,
--		self.mesh:getLength() / 2)
		0.8) -- I CAN'T GET THE DEPTH!
	-- position the collision shape inside the body
	local m1 = Matrix.new()
	m1:setPosition(0, self.mesh:getHeight() / 2, 0.4)
	-- the fixture
	local fixture = self.body:createFixture(self.shape, m1, 8) -- shape, position, mass
	self.body:setLinearDamping(0.999) -- play with it!
	self.body:setAngularDamping(0.999) -- play with it!
	-- collision bit
--	fixture:setCollisionCategoryBits(NONDESTRUCTIBLES)
--	fixture:setCollideWithMaskBits(PLAYER1+DESTRUCTIBLES)
	-- transform
	local matrix = self.body:getTransform()
	matrix:setPosition(2*self.params.posx + self.mesh:getWidth(), self.params.posy, -2*self.params.posz - self.mesh:getHeight())
--	matrix:setRotationX(params.rotx)
--	matrix:setRotationY(params.roty)
--	matrix:setRotationZ(params.rotz)
	self.body:setTransform(matrix)
	self.player1view:setMatrix(matrix)
	-- add it to world dynamic body list
	xworld.dynamicbodies[#xworld.dynamicbodies + 1] = self.player1view
	-- event listener
	self:addEventListener(Event.KEY_DOWN, self.onKeyDown, self)
	self:addEventListener(Event.KEY_UP, self.onKeyUp, self)
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end

-- GAME LOOP
function Player1:onEnterFrame(e)
	local force = 1 * self.body:getMass()
	local matrix = self.body:getTransform()
	local ax, ay, az = matrix:transformPoint(0, 0, 0)
	local bx, by, bz = matrix:transformPoint(0, 0, 1) -- 1 because by default the player is facing the camera
	local dx, dy, dz = bx - ax, by - ay, bz - az
	-- controls
	if self.isup and not self.isdown then self.body:applyForce(^>dx*force, 0, ^>dz*force)
	elseif self.isdown and not self.isup then self.body:applyForce(-^>dx*force, 0, -^>dz*force)
	end
	if self.isleft and not self.isright then self.body:applyTorque(0, -force*8, 0)
	elseif self.isright and not self.isleft then self.body:applyTorque(0, force*8, 0)
	end
	-- position the player model along its body
	self.player1view:setMatrix(matrix)
	-- the camera FPS style
	local camx, camy, camz = matrix:getPosition()
	camx += -dx * 8 -- 8 16
	camy += 4 -- 4
	camz += -dz * 8 -- 8 16
	self.camera:lookAt(
		camx + 0, camy + 0, camz - 0,
		self.player1view:getX() + 0, self.player1view:getY() + 2.1, self.player1view:getZ() + 0,
		0, 1, 0
	)
	-- lighting
	local px, py, pz = matrix:transformPoint(0, 0, 0) -- hgy29
	Lighting.setLight(px-2, py+8, pz+8, 0.3) -- hgy29
	Lighting.setLightTarget(px, py, pz, 20, 45) -- hgy29
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
