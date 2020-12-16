LevelX = Core.class(Sprite)

function LevelX:init()
	-- bg
	application:setBackgroundColor(0x0000ff)
	-- r3d world
	self.world = r3d.World.new(0, -9.8, 0) -- gravity
	-- some lists to store coming objects (static bodies, ...)
	self.world.staticbodies = {}
	self.world.kinematicbodies = {}
	self.world.dynamicbodies = {}
	--Set up a fullscreen 3D viewport
	self.camera = D3.View.new(myappwidth, myappheight, 45, 0.1, 1024)
	self:addChild(self.camera)
	-- the scene
	self.scene = self.camera:getScene()
	-- build the levels out of Tiled
	self.tiled_level = Tiled_Levels.new(self.world, self.camera, "tiled/level01.lua")
	-- add objects, player1, ... to the scene
	for s = 1, #self.world.staticbodies do
		self.scene:addChild(self.world.staticbodies[s])
	end
	for k = 1, #self.world.kinematicbodies do
		self.scene:addChild(self.world.kinematicbodies[k])
	end
	for d = 1, #self.world.dynamicbodies do
		self.scene:addChild(self.world.dynamicbodies[d])
	end
	-- debug draw
	local debugDraw = r3d.DebugDraw.new(self.world)
--	self.scene:addChild(debugDraw)
	-- player listeners
	self:addEventListener(Event.KEY_DOWN, self.tiled_level.player1.onKeyDown, self.tiled_level.player1)
	self:addEventListener(Event.KEY_UP, self.tiled_level.player1.onKeyUp, self.tiled_level.player1)
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
