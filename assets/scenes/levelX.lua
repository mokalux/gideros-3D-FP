LevelX = Core.class(Sprite)

function LevelX:init()
	-- bg
	application:setBackgroundColor(0x0000ff)
	-- r3d world
	self.world = r3d.World.new(0, -9.8, 0) -- gravity
	-- some lists to store coming objects (static bodies, ...)
	self.world.staticbodies = {}
	--Set up a fullscreen 3D viewport
	self.view = D3.View.new(myappwidth, myappheight, 45, 0.1, 1024)
	self:addChild(self.view)
	-- the scene
	self.scene = self.view:getScene()
	-- a ground (r3d static body)
	local gplane = PLANE_3D.new(self.world, {
		sizex=128, sizey=0.1, sizez=128,
		texpath="grass.png", texw=4*1024, texh=4*1024,
	})
	-- a player
	self.player1 = Player1.new(self.world, self.view)
	-- add objects, player1, ... to the scene
	for o = 1, #self.world.staticbodies do
		self.scene:addChild(self.world.staticbodies[o])
	end
	self.scene:addChild(self.player1)
	-- debug draw
	local debugDraw = r3d.DebugDraw.new(self.world)
	self.scene:addChild(debugDraw)
	-- lighting
	Lighting.setLight(2, 8, -16, 0.3) -- I DON'T REALLY GET IT!
	-- player listeners
	self:addEventListener(Event.KEY_DOWN, self.player1.onKeyDown, self.player1)
	self:addEventListener(Event.KEY_UP, self.player1.onKeyUp, self.player1)
	-- scene listeners
	self:addEventListener("enterBegin", self.onTransitionInBegin, self)
	self:addEventListener("enterEnd", self.onTransitionInEnd, self)
	self:addEventListener("exitBegin", self.onTransitionOutBegin, self)
	self:addEventListener("exitEnd", self.onTransitionOutEnd, self)
end

-- GAME LOOP
function LevelX:onEnterFrame(e)
	-- r3d physics simulation
	self.world:step(e.deltaTime)
	--Animation engine tick
	D3Anim.tick()
	--Compute shadows
	Lighting.computeShadows(self.scene)
end

-- SCENE EVENT LISTENERS
function LevelX:onTransitionInBegin()
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end

function LevelX:onTransitionInEnd()
	self:myKeysPressed()
end

function LevelX:onTransitionOutBegin()
	self:removeEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end

function LevelX:onTransitionOutEnd()
end

-- KEYS HANDLER
function LevelX:myKeysPressed()
	self:addEventListener(Event.KEY_DOWN, function(e)
		-- for mobiles and desktops
		if e.keyCode == KeyCode.BACK or e.keyCode == KeyCode.ESC then
			scenemanager:changeScene("levelX", 2, transitions[2], easings[1])
		end
	end)
end
