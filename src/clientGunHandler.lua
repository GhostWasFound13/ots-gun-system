local Settings = {}
local Network = {}
local Event = {}
local Input = {}
local UI = {}
local Physics = {}
local Audio = {}
local Camera = {}
local Animation = {}
local Effects = {}
local Char = {}
local Ragdoll = {}
local Bullet = {}
local Combat = {}
local Replication = {}
local Protection = {}
local Environment = {}
local Render = {}
local CharAnims = {}
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GunHandler")
local Aiming
local Firing = script:WaitForChild("Firing")
local Blur = Instance.new("BlurEffect", workspace.CurrentCamera)
local mobileaiming = false
local Side = "Right"
Blur.Name = "GunBlur"
Blur.Size = 0

repeat
	wait()
until game.Players.LocalPlayer.Character

if game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule").CameraModule.MouseLockController:FindFirstChild("BoundKeys") then
	game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule").CameraModule.MouseLockController.BoundKeys.Value = ""
end
game.Players.LocalPlayer.CameraMinZoomDistance = 2
Settings.CrouchKeys = {
	Enum.KeyCode.C,
	Enum.KeyCode.ButtonB,
	Enum.KeyCode.LeftControl
}
Settings.SprintKeys = {
	Enum.KeyCode.LeftShift,
	Enum.KeyCode.RightShift,
	Enum.KeyCode.ButtonL3
}
Settings.PunchKeys = {
	Enum.KeyCode.F,
	Enum.KeyCode.ButtonR3
}
Settings.CustomCameraEnabled = true

function Event.New(eventtable)
	local self = {}
	self = eventtable or self
	local removelist = {}
	local functions = {}
	local pendingdeletion = false
	function self:Connect(func)
		functions[#functions + 1] = func
		return function()
			removelist[func] = true
			pendingdeletion = true
		end
	end
	return function(...)
		if pendingdeletion then
			pendingdeletion = false
			local j = 1
			for i = 1, #functions do
				local f = functions[i]
				functions[i] = nil
				if removelist[f] then
					removelist[f] = nil
				else
					f(...)
					functions[j] = f
					j = j + 1
				end
			end
		else
			for i = 1, #functions do
				if functions[i] then
					functions[i](...)
				else
					
				end
			end
		end
	end, self
end
do
	local cf = CFrame.new
	local angles = CFrame.Angles
	local v3 = Vector3.new
	local rad, pi = math.rad, math.pi
	local sin, cos, asin, acos = math.sin, math.cos, math.asin, math.acos
	local findpartonray = workspace.FindPartOnRay
	local newray = Ray.new
	local findpartonraywithignore = workspace.FindPartOnRayWithIgnoreList
	Input.MouseDelta = v3()
	Input.GamepadDelta = v3()
	Input.TouchDelta = Vector3.new()
	Input.InputBegan = {}
	local InputBeganEvent = Event.New(Input.InputBegan)
	Input.InputEnded = {}
	local InputEndedEvent = Event.New(Input.InputEnded)
	Input.CurrentKeys = {}
	Input.GamepadConnected = UIS:GetGamepadConnected(Enum.UserInputType.Gamepad1)
	UIS.InputBegan:Connect(function(io, cancel)
		if cancel then
			return
		end
		Input.CurrentKeys[io.KeyCode] = true
		Input.CurrentKeys[io.UserInputType] = true
		InputBeganEvent(io)
	end)
	UIS.InputEnded:Connect(function(io, cancel)
		if cancel then
			return
		end
		Input.CurrentKeys[io.KeyCode] = false
		Input.CurrentKeys[io.UserInputType] = false
		InputEndedEvent(io)
	end)
		local lastgamepadpos = v3()
		
		local lastmousepos = v3()
	
	local MouseButton2Holding = false
	
	UIS.InputBegan:Connect(function(io, cancel)
		if io.UserInputType == Enum.UserInputType.MouseButton2 then
			MouseButton2Holding = true
			UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		end
		
		if io.UserInputType == Enum.UserInputType.Touch then
		Input.TouchDelta = Vector3.new()
		lastPos = Vector3.new()
	end
	end)
	
	UIS.InputEnded:Connect(function(io, cancel)
		if io.UserInputType == Enum.UserInputType.MouseButton2 then
			MouseButton2Holding = false
			UIS.MouseBehavior = Enum.MouseBehavior.Default
		end
	end)
	
	UIS.InputChanged:Connect(function(io, cancel)
		if io.UserInputType == Enum.UserInputType.MouseMovement then
			Input.MouseDelta = io.Delta
		end
		if io.UserInputType == Enum.UserInputType.Touch then
			if cancel then return end

			Input.MouseDelta = io.Delta * 10
    	end
		if io.UserInputType == Enum.UserInputType.Gamepad1 and io.KeyCode == Enum.KeyCode.Thumbstick2 then
			local pos = io.Position
			if io.UserInputState == Enum.UserInputState.Cancel then
				Input.GamepadDelta = v3()
				return
			end
			local newpos = v3(pos.x * 10, -pos.y * 10, pos.z * 10)
			if newpos.magnitude - lastgamepadpos.magnitude < 0 then
			else
			end
			if pos.magnitude >= 0.2 then
				local mult = 20 * pos.magnitude
				if pos.magnitude > 0.3 then
				end
				Input.GamepadDelta = v3(pos.x * mult, -pos.y * mult, pos.z * mult)
			else
				Input.GamepadDelta = v3()
			end
			lastgamepadpos = Input.GamepadDelta
		end
	end)
	function Input.IsKeyDown(input)
		if Input.CurrentKeys[input] then
			return true
		end
	end
	function Input.MatchKey(io, keys)
		keys = keys or {}
		for i, v in pairs(keys) do
			if v and (io.UserInputType == v or io.KeyCode == v) then
				return true
			end
		end
		return false
	end
	function Input.Step()
		Input.GamepadConnected = UIS:GetGamepadConnected(Enum.UserInputType.Gamepad1)
		Input.MouseDelta = v3()
	end
end
do
	local wfc = game.WaitForChild
	local cf = CFrame.new
	local angles = CFrame.Angles
	local v3 = Vector3.new
	local rad, pi = math.rad, math.pi
	local sin, cos, asin, acos = math.sin, math.cos, math.asin, math.acos
	local findpartonray = workspace.FindPartOnRay
	local newray = Ray.new
	local findpartonraywithignore = workspace.FindPartOnRayWithIgnoreList
	local forward = v3(0, 0, -1)
	local fromaxisangle = CFrame.fromAxisAngle
	local max = math.max
	local min = math.min
	Physics.Spring = {}
	Physics.InverseKinematics = {}
	do
		local spring = {}
		Physics.Spring = spring
		function Physics.Spring.new(initial)
			local t0 = tick()
			local p0 = initial or 0
			local v0 = initial and 0 * initial or 0
			local t = initial or 0
			local d = 1
			local s = 1
			local function positionvelocity(tick)
				local x = tick - t0
				local c0 = p0 - t
				if s == 0 then
					return p0, 0
				elseif d < 1 then
					local c = (1 - d * d) ^ 0.5
					local c1 = (v0 / s + d * c0) / c
					local co = cos(c * s * x)
					local si = sin(c * s * x)
					local e = 2.718281828459045 ^ (d * s * x)
					return t + (c0 * co + c1 * si) / e, s * ((c * c1 - d * c0) * co - (c * c0 + d * c1) * si) / e
				else
					local c1 = v0 / s + c0
					local e = 2.718281828459045 ^ (s * x)
					return t + (c0 + c1 * s * x) / e, s * (c1 - c0 - c1 * s * x) / e
				end
			end
			return setmetatable({
				accelerate = function(_, acceleration)
					local time = tick()
					local p, v = positionvelocity(time)
					p0 = p
					v0 = v + acceleration
					t0 = time
				end
			}, {
				__index = function(_, index)
					if index == "value" or index == "position" or index == "p" then
						local p, v = positionvelocity(tick())
						return p
					elseif index == "velocity" or index == "v" then
						local p, v = positionvelocity(tick())
						return v
					elseif index == "acceleration" or index == "a" then
						local x = tick() - t0
						local c0 = p0 - t
						if s == 0 then
							return 0
						elseif d < 1 then
							local c = (1 - d * d) ^ 0.5
							local c1 = (v0 / s + d * c0) / c
							return s * s * ((d * d * c0 - 2 * c * d * c1 - c * c * c0) * cos(c * s * x) + (d * d * c1 + 2 * c * d * c0 - c * c * c1) * sin(c * s * x)) / 2.718281828459045 ^ (d * s * x)
						else
							local c1 = v0 / s + c0
							return s * s * (c0 - 2 * c1 + c1 * s * x) / 2.718281828459045 ^ (s * x)
						end
					elseif index == "target" or index == "t" then
						return t
					elseif index == "damper" or index == "d" then
						return d
					elseif index == "speed" or index == "s" then
						return s
					else
						error(index .. " is not a valid member of spring", 0)
					end
				end,
				__newindex = function(_, index, value)
					local time = tick()
					if index == "value" or index == "position" or index == "p" then
						local p, v = positionvelocity(time)
						p0, v0 = value, v
					elseif index == "velocity" or index == "v" then
						local p, v = positionvelocity(time)
						p0, v0 = p, value
					elseif index == "acceleration" or index == "a" then
						local p, v = positionvelocity(time)
						p0, v0 = p, v + value
					elseif index == "target" or index == "t" then
						p0, v0 = positionvelocity(time)
						t = value
					elseif index == "damper" or index == "d" then
						p0, v0 = positionvelocity(time)
						d = value < 0 and 0 or value < 1 and value or 1
					elseif index == "speed" or index == "s" then
						p0, v0 = positionvelocity(time)
						s = value < 0 and 0 or value
					else
						error(index .. " is not a valid member of spring", 0)
					end
					t0 = time
				end
			})
		end
	end
	function Physics.InverseKinematics.SolveArm(a, b, l0, l1)
		local l = a:pointToObjectSpace(b)
		local u = l.unit
		local m = l.magnitude
		local x = forward:Cross(u)
		local g = acos(-u.Z)
		local p = a * fromaxisangle(x, g)
		if m < max(l0, l1) - min(l0, l1) then
			return p * cf(0, 0, max(l0, l1) - min(l0, l1) - m), -pi / 2, pi
		elseif m > l0 + l1 then
			return p * cf(0, 0, l0 + l1 - m), pi / 2, 0
		else
			local a0 = -acos((-(l1 * l1) + l0 * l0 + m * m) / (2 * l0 * m))
			local a1 = acos((l1 * l1 - l0 * l0 + m * m) / (2 * l1 * m))
			return p, a0 + pi / 2, a1 - a0
		end
	end
	function Physics.InverseKinematics.SolveLeg(a, b, l0, l1)
		local l = a:pointToObjectSpace(b)
		local lu = l.unit
		local m = l.magnitude
		local x = forward:Cross(-lu)
		local g = acos(-lu.Z)
		local p0 = a * fromaxisangle(x, g)
		local p1 = a * fromaxisangle(x, g):inverse()
		if m < max(l1, l0) - min(l1, l0) then
			return p1 * cf(0, 0, max(l1, l0) - min(l1, l0) - m), -pi / 2, pi
		elseif m > l0 + l1 then
			return p1 * cf(0, 0, l0 + l1 - m), pi / 2, 0
		else
			local a1 = -acos((-(l1 * l1) + l0 * l0 + m * m) / (2 * l0 * m))
			local a2 = acos((l1 * l1 - l0 * l0 + m * m) / (2 * l1 * m))
			return p0, -(a1 + pi / 2), -(a2 - a1)
		end
	end
	do
		local player = game.Players.LocalPlayer
		local character, uppertorso, rightupperarm, rightlowerarm, rightshoulder, rightelbow, leftupperarm, leftlowerarm, leftshoulder, leftelbow
		local elbowangle = cf(0, -0.2, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		local ro1 = cf(1, 0.4, 0)
		local ro2 = cf(-1, 0.4, 0)
		local function connectjoints()
			if character and uppertorso and rightupperarm and rightlowerarm and rightshoulder and rightelbow and leftupperarm and leftlowerarm and leftshoulder and leftelbow then
				return
			end
			if not character then
				character = player.Character or player.CharacterAdded:wait()
			end
			if not uppertorso then
				uppertorso = wfc(character, "UpperTorso")
			end
			if not rightupperarm then
				rightupperarm = wfc(character, "RightUpperArm")
			end
			if not rightlowerarm then
				rightlowerarm = wfc(character, "RightLowerArm")
			end
			if not rightshoulder then
				rightshoulder = wfc(rightupperarm, "RightShoulder")
			end
			if not rightelbow then
				rightelbow = wfc(rightlowerarm, "RightElbow")
			end
			if not leftupperarm then
				leftupperarm = wfc(character, "LeftUpperArm")
			end
			if not leftlowerarm then
				leftlowerarm = wfc(character, "LeftLowerArm")
			end
			if not leftshoulder then
				leftshoulder = wfc(leftupperarm, "LeftShoulder")
			end
			if not leftelbow then
				leftelbow = wfc(leftlowerarm, "LeftElbow")
			end
		end
		local solvearm = Physics.InverseKinematics.SolveArm
		local v3 = Vector3.new
		local cf = CFrame.new
		local angles = CFrame.Angles
		local fromaxisangle = CFrame.fromAxisAngle
		local acos = math.acos
		local max = math.max
		local min = math.min
		local pi = math.pi
		local forwardv3 = v3(0, 0, -1)
		local function solveright(target, forcedtorsocf)
			connectjoints()
			local uppercf = forcedtorsocf or uppertorso.CFrame
			local shouldercf = uppercf * ro1
			local plane, shoulderAngle, elbowAngle = solvearm(shouldercf, target, 0.515, 1.1031)
			rightshoulder.C0 = uppercf:toObjectSpace(plane) * angles(shoulderAngle, 0, 0)
			rightelbow.C0 = elbowangle * angles(elbowAngle, 0, 0)
		end
		local function solveleft(target, forcedtorsocf)
			connectjoints()
			local uppercf = forcedtorsocf or uppertorso.CFrame
			local shouldercf = uppercf * ro2
			local plane, shoulderAngle, elbowAngle = solvearm(shouldercf, target, 0.515, 1.1031)
			leftshoulder.C0 = uppercf:toObjectSpace(plane) * angles(shoulderAngle, 0, 0)
			leftelbow.C0 = elbowangle * angles(elbowAngle, 0, 0)
		end
		Physics.InverseKinematics.SolveRight = solveright
		Physics.InverseKinematics.SolveLeft = solveleft
	end
end
function Audio.PlaySound(id, parent, replicates, volume, pitch)
	if not id or not parent then
		return
	end
	volume = volume or 1
	pitch = pitch or 1
	local s = Instance.new("Sound")
	s.Parent = parent
	s.SoundId = id
	s.Volume, s.Pitch = volume, pitch
	s:Play()
	spawn(function()
		wait(1)
		wait(s.TimeLength)
		s:Destroy()
	end)
	if replicates then
		--Network:bounce("replicateaudio", id, parent, volume, pitch)
	end
end
--[[
Network:add("replicateaudio", function(id, parent, volume, pitch)
	Audio.PlaySound(id, parent, false, volume, pitch)
end)]]
do
	local cf = CFrame.new
	local angles = CFrame.Angles
	local v3 = Vector3.new
	local rad, pi = math.rad, math.pi
	local sin, cos, asin, acos = math.sin, math.cos, math.asin, math.acos
	local findpartonray = workspace.FindPartOnRay
	local newray = Ray.new
	local findpartonraywithignore = workspace.FindPartOnRayWithIgnoreList
	function Animation.LoadAnimations(data)
		local t = {}
		for i, v in pairs(data) do
			if v then
				local id = v.Id or v.ID
				local anim = Instance.new("Animation", Char.Humanoid)
				anim.AnimationId = id
				anim.Name = i
				local track = Char.Humanoid:LoadAnimation(anim)
				t[i] = track
			end
		end
		return t
	end
	function Animation.Play(anims, name, ...)
		local anim = anims[name]
		if anim ~= nil and anim.IsPlaying == false then
			anim:Play(...)
		end
	end
	function Animation.Stop(anims, name, ...)
		local anim = anims[name]
		if anim ~= nil and anim.IsPlaying == true then
			anim:Stop(...)
		end
	end
	function Animation.StopAllAnimations()
		for i, v in pairs(Char.Humanoid:GetPlayingAnimationTracks()) do
			if v and v.IsPlaying == true  and not v.Name == "HandOut" then
				v:Stop()
			end
		end
	end
	function Animation.StopAnimationsFromTable(t)
		for i, v in pairs(t) do
			if v and not v.Name == "HandOut" then
				Animation.Stop(t, i)
			end
		end
	end
end
function Effects.NewColorCorrection(saturation, contrast, brightness, tint)
	local c = Instance.new("ColorCorrectionEffect", Camera.Cam)
	c.Saturation = saturation
	c.Contrast = contrast
	c.Brightness = brightness
	c.TintColor = tint
	return c
end
do
	local cf = CFrame.new
	local angles = CFrame.Angles
	local v3 = Vector3.new
	local rad, pi = math.rad, math.pi
	local sin, cos, asin, acos = math.sin, math.cos, math.asin, math.acos
	local abs, clamp, min, max = math.abs, math.clamp, math.min, math.max
	local findpartonray = workspace.FindPartOnRay
	local newray = Ray.new
	local findpartonraywithignore = workspace.FindPartOnRayWithIgnoreList
	local lerp = function(a, b, t)
		return a + (b - a) * t
	end
	Camera.Cam = workspace.CurrentCamera
	Camera.Mode = "Orbital"
	wait(0.1)
	Camera.Cam.CameraType = "Scriptable"
	Camera.DefaultSensitivity = 0.15
	Camera.Sensitivity = 0.15
	Camera.DefaultOffset = Vector3.new(0, 2.5, 0)
	Camera.DefaultLookOffset = v3(0, 2.5, 0)
	Camera.LookOffset = v3()
	Camera.CamOffset = Vector3.new(0, 2.5, 0)
	Camera.MinY = rad(-75)
	Camera.MaxY = rad(75)
	Camera.CustomEnabled = false
	Camera.FOV = 70
	Camera.Distance = 12
	local distspring = Physics.Spring.new(0)
	distspring.s = 17
	distspring.d = 0.8
	local lookoffsetspring = Physics.Spring.new(v3())
	lookoffsetspring.s = 17
	lookoffsetspring.d = 0.8
	local fovspring = Physics.Spring.new(70)
	fovspring.s = 17
	fovspring.d = 0.8
	local sensitivityspring = Physics.Spring.new(Camera.DefaultSensitivity)
	sensitivityspring.s = 20
	sensitivityspring.d = 0.85
	local shakespring = Physics.Spring.new(v3())
	shakespring.s = 17.5
	shakespring.d = 0.8
	Camera.MinDistance = 3
	function Camera.SetSensitivity(sens)
		Camera.Sensitivity = sens or Camera.DefaultSensitivity
	end
	function Camera.ResetSensitivity()
		Camera.SetSensitivity(Camera.DefaultSensitivity)
	end
	function Camera.AddDistance(dist, speed)
		distspring.s = speed or 17
		distspring.t = dist or 0
	end
	function RotateAboutAxis(cf, axisDirection, axisPosition, angle)
		return CFrame.fromAxisAngle(axisDirection.Unit, angle) * (cf - axisPosition) + axisPosition
	end
	local Cam = Camera.Cam
	local MouseX, MouseY = 0, 0
	local NewCamCF = cf()
	local LastCamCF = cf()
	function Camera.GetHeading()
		local look = Camera.Cam.CFrame.lookVector
		return math.atan2(-look.x, -look.z), math.asin((Camera.Cam.CoordinateFrame.p - Camera.Cam.Focus.p).Unit.Y)
	end
	function Camera.SetFOV(fov, speed)
		fovspring.s = speed or 17
		fovspring.t = fov or 70
	end
	function Camera:Shake(v)
		shakespring.a = v
	end
	function Camera.HStep(dt)
		if Camera.CustomEnabled then
			if UIS.MouseIconEnabled ~= false then
				UIS.MouseIconEnabled = false
			end
			if UIS.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
				UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
			end
		elseif Camera.CustomEnabled == false then
			if UIS.MouseIconEnabled ~= true then
				UIS.MouseIconEnabled = true
				UIS.MouseBehavior = Enum.MouseBehavior.Default
			end
		end
		end
		
	function clerp(p1,p2,percent)
        local p1x,p1y,p1z,p1R00,p1R01,p1R02,p1R10,p1R11,p1R12,p1R20,p1R21,p1R22 = p1:components()
        local p2x,p2y,p2z,p2R00,p2R01,p2R02,p2R10,p2R11,p2R12,p2R20,p2R21,p2R22 = p2:components()
        return CFrame.new(p1x+percent*(p2x-p1x), p1y+percent*(p2y-p1y) ,p1z+percent*(p2z-p1z),
                (p1R00+percent*(p2R00-p1R00)), (p1R01+percent*(p2R01-p1R01)) ,(p1R02+percent*(p2R02-p1R02)),
                (p1R10+percent*(p2R10-p1R10)), (p1R11+percent*(p2R11-p1R11)) , (p1R12+percent*(p2R12-p1R12)),
                (p1R20+percent*(p2R20-p1R20)), (p1R21+percent*(p2R21-p1R21)) ,(p1R22+percent*(p2R22-p1R22)))
        end
	
	
	lookoffset = Camera.DefaultOffset
	local ArrowDelta = v3()
	
function Camera.Step(dt)
		if Camera.CustomEnabled == false then
			--return
		end
		local Ignore = {}
		local function CastRay(CastedRay) 
			table.insert(Ignore, Char.Character)
			local Success = false
			local Hit, Position, Normal
			repeat
				Hit, Position, Normal = workspace:FindPartOnRayWithIgnoreList(CastedRay	, Ignore)
				if Hit then
					if Hit.CanCollide then
						if Hit.Transparency >= 0.5 then
							table.insert(Ignore, Hit)
						else
							Success = true
						end
					else
						table.insert(Ignore, Hit)
					end
				else
					Success = true
				end
			until Success
			return Hit, Position, Normal
		end
		if Camera.Mode == "Orbital" then
			local ti = 0.1
			local delta = ArrowDelta + Input.MouseDelta + Input.GamepadDelta:Lerp(Input.GamepadDelta, ti) + Input.TouchDelta
			local rootcf = Char.RootPart.CFrame * cf(0, -Char.CrouchP * 1.5, 0)
			local Focus = (rootcf * cf(lookoffset)).p + v3(0, 2, 0)
			local ZoomCF = cf(0, 0, 0)
			local Center = Char.RootPart.Position + Vector3.new(0, 2, 0)
			lookoffsetspring.t = Camera.DefaultLookOffset + Camera.LookOffset
			lookoffset = lookoffsetspring.p
			Camera.FOV = fovspring.p
			sensitivityspring.t = Camera.Sensitivity
			MouseX = MouseX + rad(delta.x * sensitivityspring.p)
			MouseY = MouseY - rad(delta.y * sensitivityspring.p)
			MouseY = clamp(MouseY, Camera.MinY, Camera.MaxY)
			local camdist = Camera.Distance + distspring.p
			if camdist <= Camera.MinDistance then
				camdist = Camera.MinDistance
			end
			NewCamCF = cf(rootcf.p) * angles(0, -MouseX, 0) * angles(MouseY, 0, 0) * cf(0, 0, camdist) * cf(lookoffset) * angles(-shakespring.p.y, shakespring.p.x, shakespring.p.z)
			if NewCamCF ~= LastCamCF then
				local v = NewCamCF.p - Focus
				local occlusionRay = newray(Focus, v)
				local k, p = findpartonraywithignore(workspace, occlusionRay, {
					Char.Character
				})
				
				if k then
				local Distance = (p - NewCamCF.p).Magnitude
				if not Aiming then
				NewCamCF = NewCamCF * CFrame.new(0, 0, -Distance) 
				else
				NewCamCF = NewCamCF * CFrame.new(0, 0, -Distance + 4) 
				end
				end

				Camera.Cam.CFrame = clerp(Camera.Cam.CFrame, NewCamCF, 0.4)
				
				
			
				local CastedRay = Ray.new(Center, NewCamCF.Position - Center)
				local Hit, Pos, Norm = CastRay(CastedRay)
				if Hit then
					Pos = Pos + Norm * 0.2
				end
				local NewCameraCFrame = clerp(Camera.Cam.CFrame, CFrame.new(Pos) * (NewCamCF - NewCamCF.Position), 0.4)
				
				Camera.Cam.CFrame = CFrame.new(NewCameraCFrame.Position, NewCameraCFrame.Position + NewCameraCFrame.LookVector)
				LastCamCF = Camera.Cam.CFrame
			end
			Camera.Cam.FieldOfView = fovspring.p
		end
	end	
	Input.InputBegan:Connect(function(io, cancel)
		if cancel then
			return
		end
		if io.KeyCode == Enum.KeyCode.Left then
			ArrowDelta = ArrowDelta - v3(10, 0, 0)
		end
		if io.KeyCode == Enum.KeyCode.Right then
			ArrowDelta = ArrowDelta - v3(-10, 0, 0)
		end
		if io.KeyCode == Enum.KeyCode.ButtonSelect then
			local newpos = Camera.Distance + 2
			if newpos > 20 then
				newpos = 7
			end
			Camera.Distance = newpos
		end
	end)
	UIS.InputChanged:Connect(function(io, cancel)
		if cancel then
			return
		end
		if io.UserInputType == Enum.UserInputType.MouseWheel then
			local newpos = io.Position.z * 2
			Camera.Distance = Camera.Distance - newpos
			Camera.Distance = clamp(Camera.Distance, 7, 20)
		end
	end)
	Input.InputEnded:Connect(function(io, cancel)
		if io.KeyCode == Enum.KeyCode.Left then
			ArrowDelta = ArrowDelta + v3(10, 0, 0)
		end
		if io.KeyCode == Enum.KeyCode.Right then
			ArrowDelta = ArrowDelta + v3(-10, 0, 0)
		end
	end)
end
do
	local cf = CFrame.new
	local angles = CFrame.Angles
	local v3 = Vector3.new
	local rad, pi = math.rad, math.pi
	local sin, cos, asin, acos = math.sin, math.cos, math.asin, math.acos
	local abs, clamp, min, max = math.abs, math.clamp, math.min, math.max
	local findpartonray = workspace.FindPartOnRay
	local newray = Ray.new
	local findpartonraywithignore = workspace.FindPartOnRayWithIgnoreList
	local vtws = CFrame.new().vectorToWorldSpace
	Char.Character = game.Players.LocalPlayer.Character
	Char.RootPart = Char.Character:WaitForChild("HumanoidRootPart")
	Char.Humanoid = Char.Character:WaitForChild("Humanoid")
	Char.Head = Char.Character:WaitForChild("Head")
	Char.UpperTorso = Char.Character:WaitForChild("UpperTorso")
	Char.LowerTorso = Char.Character:WaitForChild("LowerTorso")
	Char.RightFoot = Char.Character:FindFirstChild("RightFoot")
	Char.LeftFoot = Char.Character:FindFirstChild("LeftFoot")
	Char.Neck = Char.Head:WaitForChild("Neck")
	Char.Waist = Char.UpperTorso:WaitForChild("Waist")
	Char.RootJoint = Char.LowerTorso:WaitForChild("Root")
	Char.RightShoulder = Char.Character.RightUpperArm.RightShoulder
	Char.LeftShoulder = Char.Character.LeftUpperArm.LeftShoulder
	Char.Backpack = game.Players.LocalPlayer:WaitForChild("Backpack")
	Char.AnimationData = {
		Idle = {
			Id = "rbxassetid://13107191645" 
		},
		HandOut = {
			Id = "rbxassetid://13111441031" -- DON'T ANIMATE.  
		},
		Walk = {
			Id = "rbxassetid://13111441031" 
		},
		Run = {
			Id = "rbxassetid://13106705356"
		},
		Jump = {
			Id = "rbxassetid://13299496981" -- DON'T ANIMATE. 
		},
		Fall = {
			Id = "rbxassetid://13240990088" 
		},
		Climb = {
			Id = "rbxassetid://13240949724" 
		},
		CrouchIdle = {
			Id = "rbxassetid://13106708459"
		},
		CrouchWalk = {
			Id = "rbxassetid://13106710297"
		},
		SneakIdle = {
			Id = "rbxassetid://13299520784" -- DON'T ANIMATE.
		},
		SneakWalk = {
			Id = "rbxassetid://13299526635" -- DON'T ANIMATE.
		},
		RollForward = {
			Id = "rbxassetid://13299552195" -- DON'T ANIMATE.
		},
		SwimIdle = {
			Id = "rbxassetid://13299556536" -- DON'T ANIMATE.
		},
		Swim = {
			Id = "rbxassetid://13241893764"  
		},
		Sit = {
			Id = "rbxassetid://13241891576"
		},
		Land = {
			Id = "rbxassetid://13299572975" -- DON'T ANIMATE.
		},
		LandSoft = {
			Id = "rbxassetid://13299576459" -- DON'T ANIMATE.
		},
		LandHard = {
			Id = "rbxassetid://13299582183" -- DON'T ANIMATE.
		},
		GettingUp = {
			Id = "rbxassetid://13299587061" -- DON'T ANIMATE.
		},
		Punch1 = {
			Id = "rbxassetid://13299594570" -- DON'T ANIMATE.
		},
		Punch2 = {
			Id = "rbxassetid://13299599786" -- DON'T ANIMATE.
		},
		Dance1 = {
			Id = "rbxassetid://03094649043" -- DON'T ANIMATE.
		},
		Dance2 = {
			Id = "rbxassetid://03094653085" -- DON'T ANIMATE.
		},
		Dance3 = {
			Id = "rbxassetid://03094655294" -- DON'T ANIMATE.
		},
		Dance4 = {
			Id = "rbxassetid://03094656998" -- DON'T ANIMATE.
		},
		Dance5 = {
			Id = "rbxassetid://03094658587" -- DON'T ANIMATE.
		},
		Dance6 = {
			Id = "rbxassetid://03094662911"	 -- DON'T ANIMATE.
		},
		Dance7 = {
			Id = "rbxassetid://03575966523"	 -- DON'T ANIMATE.
		},
		Vault = {
			Id = "rbxassetid://13299604542" -- DON'T ANIMATE.
		},
		WalkBackwards = {
			Id = "rbxassetid://13107163828"
		},
		InjuredWalk = {
			Id = "rbxassetid://13240840443" -- DON'T ANIMATE.
		},
		InjuredRun = {
			Id = "rbxassetid://13240840443" -- DON'T ANIMATE.
		}
	}
	Char.DefaultWalkSpeed = 14 
	Char.CrouchWalkSpeed = 9
	Char.RunningMultiplier = 1.5
	Char.LeaningSensitivity = 0.6
	Char.CustomJumpEnabled = false
	Char.JumpEnabled = true
	Char.CanUpdateHead = true
	Char.CanLean = true
	Char.Sprinting = false
	Char.Jumping = false
	Char.Sitting = false
	Char.Falling = false
	Char.Climbing = false
	Char.Landing = false
	Char.Swimming = false
	Char.Crouching = false
	Char.Punching = false
	Char.Tripped = false
	Char.Dancing = false
	Char.Injured = false
	Char.Loaded = true
	Char.OriginWaistC1 = Char.Waist.C1
	Char.CrouchP = 0
	Char.Speed = 0
	Char.Sprint = 0
	local crouchspring = Physics.Spring.new(0)
	crouchspring.s = 12
	crouchspring.d = 0.85
	local speedspring = Physics.Spring.new(0)
	speedspring.s = 10
	speedspring.d = 0.85
	local sprintspring = Physics.Spring.new(0)
	sprintspring.s = 15
	sprintspring.d = 0.85
	local healthspring = Physics.Spring.new(100)
	healthspring.s = 10
	healthspring.d = 0.85
	function Char.GetVelocity()
		local vel = Char.RootPart.CFrame:inverse() * (Char.RootPart.Position + Char.RootPart.Velocity)
		return vel
	end
	function Char.CheckIfWalking()
		local dir = Char.Humanoid.MoveDirection
		local speed = Vector3.new(dir.x, 0, dir.z)
		if 0 < abs(speed.unit.magnitude) then
			return true
		end
		return false
	end
	function Char.ToggleBackpack(on)
		if on then
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
		else
			Char.Humanoid:UnequipTools()
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		end
	end
	function Char.SetCrouch(on)
		if on then
			Char.Crouching = true
			crouchspring.t = 1
		else
			Char.Crouching = false
			crouchspring.t = 0
		end
	end
	
	function Char.SetSprint(on)
		local aiming = Combat.CurrentWeapon and Combat.CurrentWeapon.aiming or nil
		local lastsprint = Char.Sprinting
		if on then
			Char.Sprinting = true
			sprintspring.t = 1
			if lastsprint ~= on and not aiming then
				Camera.SetFOV(60, 3)
			end
		else
			Char.Sprinting = false
			sprintspring.t = 0
			if lastsprint ~= on and not aiming then
				Camera.SetFOV(70, 9)
			end
		end
	end
	function Char.SetWalkspeed(ws)
		ws = ws or Char.DefaultWalkSpeed
		local weaponweight = 1
		if Combat.WeaponEquipped and Combat.CurrentWeapon ~= nil and Combat.CurrentWeapon.weight ~= nil then
			weaponweight = Combat.CurrentWeapon.weight
		end
		local healthfactor = 1
		if Char.Humanoid.Health <= 25 then
			Char.Injured = true
			Blur.Size = 8
			healthfactor = 0.6
			Animation.Play(CharAnims, "InjuredWalk", 0.7)
			Char.SetSprint(false)
			--Audio.PlaySound("rbxassetid://152736435", game.Lighting, true, 0.2)
			game:GetService("SoundService").AmbientReverb = Enum.ReverbType.UnderWater
		elseif Char.Humanoid.Health > 30 then
			Char.Injured = false
			Blur.Size = 0
			game:GetService("SoundService").AmbientReverb = Enum.ReverbType.StoneCorridor
			healthfactor = 1
			Animation.Stop(CharAnims, "InjuredWalk")
		end
		local factor = healthfactor * (1 / weaponweight)
		Char.Humanoid.WalkSpeed = ws * factor
	end
	local LastLook = cf()
	local NewTransform = cf()
	local OriginNeckC0 = Char.Neck.C0
	function Char.RotateHead(mult)
		local LerpMult = mult or 0.2
		local Torso = Char.Neck.Part0
		local canupdate = Char.CanUpdateHead and not Char.Tripped
		local LookAt = Char.RootPart.Position + Camera.Cam.CFrame.lookVector * 100
		local ObjectSpace = Char.RootPart.CFrame:pointToObjectSpace(LookAt)
		LookAt = Torso.CFrame:pointToWorldSpace(ObjectSpace * Vector3.new(-1, -0.5, 2))
		if ObjectSpace.Z > 0 then
			LookAt = Torso.CFrame:pointToWorldSpace(ObjectSpace * -1)
		end
		local Thingy = Char.RootPart.Position + Char.Neck.C0.p * 1
		local NewRot = cf(Thingy, LookAt)
		local Offset = NewRot:toObjectSpace(Torso.CFrame * Char.Neck.C0)
		local NewTransform = LastLook:lerp(Offset - Offset.p, 0.1)
		local CancelTransform = LastLook:lerp(cf(), 0.1)
		local Point = Camera.Cam.CFrame.p
		local Dist = (Char.Head.CFrame.p - Point).magnitude
		local Diff = Char.Head.CFrame.Y - Point.Y
		if 0 < Char.Humanoid.Health then
			if canupdate then
				Char.Neck.Transform = cf()
				Char.Neck.C0 = clerp(Char.Neck.C0, OriginNeckC0 * angles(asin(Diff / Dist) * 0.9, -(Char.Head.CFrame.p - Camera.Cam.CFrame.p).Unit:Cross(Char.UpperTorso.CFrame.lookVector).Y, 0), LerpMult)
				--Char.Neck.C0 = Char.Neck.C0:lerp(OriginNeckC0 * angles(asin(Diff / Dist) * 0.9, -(Char.Head.CFrame.p - Camera.Cam.CFrame.p).Unit:Cross(Char.UpperTorso.CFrame.lookVector).Y, 0), 0.2)
			elseif Char.Neck.C0 ~= OriginNeckC0 then
				Char.Neck.C0 = clerp(Char.Neck.C0, OriginNeckC0, LerpMult)
				--Char.Neck.C0 = Char.Neck.C0:lerp(OriginNeckC0, 0.2)
			end
		end
	end
	local rootc0 = cf()
	local OriginRJC0 = Char.RootJoint.C0
	function Char.Lean(dt)
		local Dir = Char.Humanoid.MoveDirection
		local Vel = Char.GetVelocity()
		Vel = Vel * Char.LeaningSensitivity * (Char.Sprinting and Char.RunningMultiplier or 1)
		if Char.CanLean and not Char.Sitting then
			Vel = Vel * Char.LeaningSensitivity * (Char.Sprinting and Char.RunningMultiplier or 1)
		else
			Vel = Vector3.new()
		end
		local RotUp = Char.Sprinting and 0 or 0
		local NewAngle = angles(rad(RotUp), 0, rad(Vel.x))
		Char.Waist.C1 = Char.Waist.C1:Lerp(Char.OriginWaistC1 * NewAngle, dt * 10)
		rootc0 = Char.RootJoint.C0
		Char.RootJoint.C0 = Char.RootJoint.C0:lerp(OriginRJC0 * cf(-Vel.x * 0.02, 0, Vel.z * 0.02) * CFrame.Angles(math.rad(0) * 0.5, math.rad(Vel.x) * 0.5, math.rad(-Vel.x) * 0.5), dt * 10)
	end
	function UpdatePlayersLean(Target, Direction, Velocity, RotationUp, NewCharAngle, RootJointC0, CharWaistC1, CharOriginWaistC1, CharOriginRJC0, DTime)
		CharWaistC1 = CharWaistC1:Lerp(CharOriginWaistC1 * NewCharAngle, DTime * 10)
		RootJointC0 = RootJointC0:lerp(CharOriginRJC0 * cf(-Velocity.x * 0.02, 0, Velocity.z * 0.02) * CFrame.Angles(math.rad(0) * 0.5, math.rad(Velocity.x) * 0.5, math.rad(-Velocity.x) * 0.5), DTime * 10)
	end
	local OriginWaistC0 = Char.Waist.C0
	function Char.RotateWaist(mt)
		local canupdate = true
		if Combat.WeaponEquipped and canupdate then
			canupdate = not Combat.CurrentWeapon.aiming
		end
		local Point = game.Players.LocalPlayer:GetMouse().Hit.p
		local Dist = (Char.Head.CFrame.p - Point).magnitude
		local Diff = Char.Head.CFrame.Y - Point.Y
		if canupdate then
			--Char.Waist.C0 = Char.Waist.C0:lerp(OriginWaistC0 * angles(-(math.atan(Diff / Dist) * 0.5), (Char.Head.Position - Point).Unit:Cross(Char.UpperTorso.CFrame.lookVector).Y * 0.5, 0), mt)
			--UpdateBody:FireServer(Char.Character.UpperTorso.Waist.C0, Point, Dist)
		elseif Char.Waist.C0 ~= OriginWaistC0 then
			--Char.Waist.C0 = Char.Waist.C0:lerp(OriginWaistC0, mt)
			--UpdateBody:FireServer(Char.Character.UpperTorso.Waist.C0, Point, Dist)
		end
	end

	function Char.LoadAnimations()
		CharAnims = Animation.LoadAnimations(Char.AnimationData)
	end
	Char.LoadAnimations()
	spawn(function()
		local animatescript = Char.Character:WaitForChild("Animate")
		animatescript.Disabled = true
		animatescript:Destroy()
		Animation.StopAllAnimations()
	end)
	function Char.Spawned(c)
		spawn(function()
			wait(1)
			Char.Character = c
			Char.RootPart = Char.Character:WaitForChild("HumanoidRootPart")
			Char.Humanoid = Char.Character:WaitForChild("Humanoid")
			Char.Head = Char.Character:WaitForChild("Head")
			Char.UpperTorso = Char.Character:WaitForChild("UpperTorso")
			Char.LowerTorso = Char.Character:WaitForChild("LowerTorso")
			Char.RightFoot = Char.Character:FindFirstChild("RightFoot")
			Char.LeftFoot = Char.Character:FindFirstChild("LeftFoot")
			Char.Neck = Char.Head:WaitForChild("Neck")
			Char.Waist = Char.UpperTorso:WaitForChild("Waist")
			Char.RootJoint = Char.LowerTorso:WaitForChild("Root")
			Char.Backpack = game.Players.LocalPlayer:WaitForChild("Backpack")
			Char.RightShoulder = Char.Character.RightUpperArm.RightShoulder
			Char.LeftShoulder = Char.Character.LeftUpperArm.LeftShoulder
			Char.SetSprint(false)
			Char.Jumping = false
			Char.Sitting = false
			Char.Falling = false
			Char.Climbing = false
			Char.Landing = false
			Char.Swimming = false
			Char.Crouching = false
			Char.Punching = false
			Char.Dancing = false
			Char.CanUpdateHead = true
			Char.CanLean = true
			Char.LoadAnimations()
			Char.LoadEvents()
			Combat.Reset()
			Char.Humanoid.Died:Connect(Char.Died)
			Char.LoadFootsteps()
			Char.Loaded = true
			local animatescript = Char.Character:WaitForChild("Animate")
			animatescript.Disabled = true
			animatescript:Destroy()
			Animation.StopAllAnimations()
			Char.Humanoid.Changed:Connect(function(change)
				if change == "Jump" and Char.Humanoid.Jump == true then
					if Char.CustomJumpEnabled then
						Char.Jump()
					end
					if not Char.JumpEnabled then
						Char.Humanoid.Jump = false
					end
				end
			end)
			--Char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
			Char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
			Char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
		end)
	end
	--Char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	Char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
	Char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
	local HoldingL3 = false
	function Idle()
		if HoldingL3 then
			Char.SetSprint(false)
		end
		Char.SetWalkspeed(Char.DefaultWalkSpeed)
		Animation.Stop(CharAnims, "Run")
		Animation.Stop(CharAnims, "Walk")
		Animation.Stop(CharAnims, "WalkBackwards")
		if Char.Crouching then
			Animation.Stop(CharAnims, "Idle")
			Animation.Play(CharAnims, "CrouchWalk", 0)
		else
			Animation.Stop(CharAnims, "CrouchIdle", 0)
			Animation.Play(CharAnims, "Idle")
		end
	end
	function Walk()
		Char.SetSprint(false)
		local FallSpeedMult = (Char.Falling or Char.Jumping or Char.Punching) and 0.4 or 1
		local Velocity = Char.GetVelocity() * Vector3.new(1, 0, 1)
		local Speed = Velocity.magnitude
		local backwardsmult = 1
		if Velocity.z > 0.15 then
			backwardsmult = -1
		end
		if Char.Crouching and not Char.Sprinting then
			Char.SetWalkspeed(Char.CrouchWalkSpeed * FallSpeedMult)
			Animation.Stop(CharAnims, "Walk")
			Animation.Stop(CharAnims, "WalkBackwards")
			Animation.Play(CharAnims, "CrouchWalk", 0)
		else
			Char.SetWalkspeed(Char.DefaultWalkSpeed / 1.5 * FallSpeedMult)
			Animation.Stop(CharAnims, "CrouchWalk")
			if backwardsmult > 0 then
				if CharAnims.Walk then
					Animation.Play(CharAnims, "Walk", 0.5, 1.5)
					Animation.Stop(CharAnims, "WalkBackwards")
					CharAnims.Walk:AdjustSpeed(Speed / 16 + 0.5)
					CharAnims.Walk:AdjustWeight(Speed / 16 * 1.5)
				end
			elseif CharAnims.WalkBackwards then
				Animation.Play(CharAnims, "WalkBackwards", 1, 1.5)
				Animation.Stop(CharAnims, "Walk")
				CharAnims.WalkBackwards:AdjustSpeed(Speed / 16 + 1)
				CharAnims.WalkBackwards:AdjustWeight(Speed / 16 * 1.5)
			end
		end
		Animation.Stop(CharAnims, "Idle")
		Animation.Stop(CharAnims, "CrouchIdle", 0)
		Animation.Stop(CharAnims, "Run")
	end
	function Run()
		Char.SetCrouch(false)
		if Char.Climbing then
			return
		end
		if Char.Injured then
			return
		end
		local FallSpeedMult = (Char.Falling or Char.Jumping or Char.Punching) and 0.4 or 1
		local Velocity = Char.GetVelocity() * Vector3.new(1, 0, 1)
		local Speed = Velocity.magnitude
		Char.SetWalkspeed(Char.DefaultWalkSpeed * Char.RunningMultiplier * FallSpeedMult)
		Animation.Stop(CharAnims, "Idle")
		Animation.Stop(CharAnims, "Walk")
		Animation.Stop(CharAnims, "CrouchIdle", 0)
		Animation.Stop(CharAnims, "CrouchWalk", 0)
		Animation.Play(CharAnims, "Run", 0)
		local backwardsmult = 1
		if Velocity.z > 0.15 then
			backwardsmult = -1
		end
		if CharAnims.Run then
			CharAnims.Run:AdjustSpeed((Speed / 16 + 1.7) * sprintspring.p * backwardsmult)
			CharAnims.Run:AdjustWeight(speedspring.p / (16 * Char.RunningMultiplier) * 1.5 * sprintspring.p)
		end
	end
	function Sit()
		Animation.Stop(CharAnims, "Fall")
		Animation.Stop(CharAnims, "Jump")
		Animation.Stop(CharAnims, "Land")
		Animation.Stop(CharAnims, "LandSoft")
		Animation.Stop(CharAnims, "Run")
		Animation.Stop(CharAnims, "Idle")
		Animation.Stop(CharAnims, "Walk")
		Animation.Stop(CharAnims, "CrouchIdle", 0)
		Animation.Stop(CharAnims, "CrouchWalk", 0)
		Char.Sitting = true
		Animation.Play(CharAnims, "Sit")
	end
	local lastjumptick = 0
	function Jump()
		local jumptick = tick() - lastjumptick
		Animation.StopAnimationsFromTable(CharAnims)
		Char.Jumping = true
		Animation.Play(CharAnims, "Jump")
		local l = {}
		l = CharAnims.Jump.Stopped:Connect(function()
			Char.Jumping = false
			l:disconnect()
		end)
		if jumptick < 1.5 then
			Char.Humanoid.JumpPower = 0
			spawn(function()
				wait(1.5)
				Char.Humanoid.JumpPower = 35
			end)
			return
		else
			Char.Humanoid.JumpPower = 35
		end
		lastjumptick = tick()
	end
	function Fall()
		local FallSpeedMult = (Char.Falling or Char.Jumping or Char.Punching) and 0.7 or 1
		Animation.StopAnimationsFromTable(CharAnims)
		Char.Falling = true
		FallSpeedMult = FallSpeedMult * (Char.Sprinting and Char.RunningMultiplier or 1)
		Char.Humanoid.JumpPower = 35
		Char.SetWalkspeed(Char.DefaultWalkSpeed * FallSpeedMult)
		Animation.Play(CharAnims, "Fall")
	end
	function Char.Trip(dur)
		if Char.Tripped then
			return
		end
		Char.Tripped = true
		Char.Humanoid.PlatformStand = true
		wait(dur)
		Char.Humanoid.PlatformStand = false
		Char.Tripped = false
	end
	function Land()
		Char.Falling = false
		local velocity = abs(Char.RootPart.Velocity.y)
		if velocity > 35 and velocity <= 80 then
			Animation.Play(CharAnims, "LandSoft")
		elseif velocity > 80 and velocity < 120 then
			Char.Landing = true
			Char.SetWalkspeed(0)
			Animation.Play(CharAnims, "Land")
			do
				local t = {}
				t = CharAnims.Land.Stopped:Connect(function()
					Char.SetWalkspeed(Char.DefaultWalkSpeed)
					Char.Landing = false
					t:disconnect()
				end)
			end
		elseif velocity >= 120 then
			Char.Landing = true
			Char.SetWalkspeed(0)
			Animation.Play(CharAnims, "LandHard")
			do
				local t = {}
				t = CharAnims.LandHard.Stopped:Connect(function()
					Char.SetWalkspeed(Char.DefaultWalkSpeed)
					Char.Landing = false
					t:disconnect()
				end)
			end
		end
	end
	function Climb(speed)
		Char.Climbing = true
		Char.SetSprint(false)
		Animation.Stop(CharAnims, "Walk")
		Animation.Stop(CharAnims, "Idle")
		Animation.Stop(CharAnims, "Run")
		Animation.Stop(CharAnims, "Fall")
		Animation.Stop(CharAnims, "Jump")
		Animation.Play(CharAnims, "Climb")
		CharAnims.Climb:AdjustSpeed(speed / 5)
		Char.SetWalkspeed(Char.DefaultWalkSpeed)
	end
	function Swim()
		local Moving = Char.CheckIfWalking()
		Char.Swimming = true
		Char.SetSprint(false)
		Char.Climbing = false
		Char.Falling = false
		Char.Landing = false
		Char.Jumping = false
		Char.Dancing = false
		local FallSpeedMult = (Char.Falling or Char.Jumping) and 0.4 or 1
		Char.SetWalkspeed(Char.DefaultWalkSpeed * FallSpeedMult)
		if Moving then
			Animation.Stop(CharAnims, "SwimIdle")
			Animation.Play(CharAnims, "Swim")
		else
			Animation.Stop(CharAnims, "Swim")
			Animation.Play(CharAnims, "SwimIdle")
		end
	end
	local punchnum = 1
	local punchtick0 = tick()
	local FindHumanoid = function(hit)
		for i,v in pairs(hit.Parent:GetChildren() or hit.Parent.Parent:GetChildren()) do
			if v:IsA("Humanoid") then
				local hum = v		
			if hum then
			    return hum
		    end
			end
		end
	end
	function Punch()
		if not Char.Crouching and Char.Humanoid.Health > 0 and not Char.Climbing and not Aiming and not Char.Swimming and not Char.Sitting and not Char.Landing and not Char.Falling and tick() - punchtick0 > 1 then
			Char.Punching = true
			punchtick0 = tick()
			do
				local punches = {"Punch1", "Punch2"}
				for i, v in pairs(punches) do
					if v then
						Animation.Stop(CharAnims, v)
					end
				end
				local name = punches[punchnum]
				Animation.Play(CharAnims, name)
				Audio.PlaySound("rbxassetid://231731980", Char.RootPart, true, 0.7)
				CharAnims[name]:AdjustSpeed(1)
				local t = {}
				local endpoint = (Char.UpperTorso.CFrame * cf(0, 0, -3)).p
				local ray = newray(Char.UpperTorso.CFrame.p, (endpoint - Char.UpperTorso.CFrame.p).unit * 3)
				local part, position = workspace:FindPartOnRay(ray, Char.Character, false, true)
				if part then
					local hum = FindHumanoid(part)
					if hum then
						wait(0.3)
						
						Audio.PlaySound("rbxassetid://278061737", Char.RootPart, true, 0.5)
						--Remote:FireServer(hum, "Punch")
						
						--Network:send("punchplayer", hum.Parent)
					end
				end
				t = CharAnims[name].Stopped:Connect(function()
					Char.Punching = false
					t:disconnect()
				end)
				punchnum = punchnum < #punches and punchnum + 1 or 1
			end
		end
	end
	    local weaponeffects = game:GetService("ReplicatedStorage").Assets:WaitForChild("WeaponEffects")    
	    
		function ReplicateBeam(Tool, player, HitPart)
			     spawn(function()
			Tool.MuzzleFlash:Emit(10)
			Tool.Smoke:Emit(1)
				 Tool.Fire.PlayOnRemove = false
		         local FireC = Tool.Fire:Clone()
		         FireC.Parent = Tool
		         if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
			         FireC.PlayOnRemove = true
			         FireC:Destroy()
		         end
		         Tool.MuzzleLight.Enabled = true
		         wait()
		         Tool.MuzzleLight.Enabled = false
			     --[[if HitPart ~= nil then
					   local p = Instance.new("Part")
			           p.Anchored = true
			           p.CanCollide = false
			           p.Transparency = 1
			           p.CFrame = CFrame.new(Hit)
			           p.Size = Vector3.new(.01, .01, .01)
			           p.Parent = workspace.Doors
			           local p2 = Instance.new("Part")
			           p2.Anchored = true
			           p2.CanCollide = false
			           p2.Transparency = 1
			           p2.CFrame = CFrame.new(Origin)
			           p2.Size = Vector3.new(.01, .01, .01)
			           p2.Parent = workspace.Door
			           -- local a = Instance.new("Attachment")
			          -- a.Parent = p
			           -- local a2 = Instance.new("Attachment")
			          -- a2.Parent = p2
			          --  local beam1 = Tool:WaitForChild("Beam"):Clone()
			          -- beam1.Parent = Tool
			          -- beam1.Attachment1 = a
			          -- beam1.Attachment0 = a2
	                   local bulletholepart = Instance.new("Part", nil)
	                   bulletholepart.FormFactor = "Custom"
	                   bulletholepart.Size = Vector3.new(0.4, 0.4, 0.01)
	                   bulletholepart.Anchored = true
	                   bulletholepart.CanCollide = false
	                   bulletholepart.Transparency = 1
	                   local bulletholedecal = Instance.new("Decal", bulletholepart)
	                   bulletholedecal.Face = "Front" 
	                   local bullethole = bulletholepart:Clone() 
	                   bullethole.Name = "bullethole" 
	                   bullethole.Parent = workspace.Interactions
	                   local hit
						if HitPart.Parent then
							for i,v in pairs(HitPart.Parent:GetChildren()) do
		                  		if v:IsA("Humanoid") or v:IsA("Accessory") then
			                		 hit = v
		                  		end
	                   		end
						end
	                   if hit ~= nil then
	                   if hit:IsA("Humanoid") or hit:IsA("Accessory") then
				            local HitSoundIDs = {1657139544,1657139930,1657140203,1657073285}
		                   	local Sound = Instance.new("Sound")
		                    Sound.Parent = bullethole
		                    local HitSoundVolume = 1
				            Sound.SoundId = "rbxassetid://"..HitSoundIDs[math.random(1, #HitSoundIDs)]
				            Sound.Volume = HitSoundVolume
				            Sound:Play()
			                 -- local particle = weaponeffects.BulletHitParticle.Blood:Clone()
			                 -- particle.Parent = bullethole
			                  --particle:Emit(32)
			                 -- bullethole.Decal:Destroy()
		                      --bullethole.CFrame = CFrame.new(Hit, Hit + Surface)
                    end
                   else
	                local WhizSoundIDs = {269514869,269514887,269514807,269514817}
                   	local Sound = Instance.new("Sound")
                    Sound.Parent = bullethole
                    local WhizSoundVolume = 2
		            Sound.SoundId = "rbxassetid://"..WhizSoundIDs[math.random(1, #WhizSoundIDs)]
		            Sound.Volume = WhizSoundVolume
		            Sound:Play()
	                  --bullethole.Parent = workspace.Doors
                     -- bullethole.CFrame = CFrame.new(Hit, Hit + Surface)
	                  local particle = weaponeffects.BulletHitParticle.Smoke:Clone()
	                  local particle2 = weaponeffects.BulletHitParticle.concrete.Particle:Clone()
                      particle.Parent = bullethole
	                  particle2.Parent = bullethole 
	                  particle:Emit(15)
	                  particle2:Emit(52)                   
	              -- game:GetService("Debris"):AddItem(bullethole, 10)
	               --game:GetService("Debris"):AddItem(p, 1)
		           --game:GetService("Debris"):AddItem(p2, 1)
                   end
		           end
			       end)
                  spawn(function()
	               for i = 0.1, 11 do
                     beam1.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, i/10, 0), NumberSequenceKeypoint.new(1, i/10, 0)})
                     RunService.RenderStepped:Wait()
                   end
                   end)

		          -- game:GetService("Debris"):AddItem(beam1, 1)]]
				end)
		end
		
	function Char.Dance(num)
		if Char.CheckIfWalking() or Char.Sitting or Char.Swimming or Char.Landing or Char.Jumping or Char.Sprinting or Char.Climbing then
			return
		end
		
		for i = 1,5 do
			Animation.Stop(CharAnims, "Dance".. tostring(i))
		end
		
		local num = tostring(num)
		local dancename = "Dance".. num
		Char.Dancing = true
		Animation.Play(CharAnims, dancename)
		if Combat.WeaponEquipped then
			Combat.CurrentWeapon.setaim(false)
		end
	end
	function Char.StopDancing()
		Char.Dancing = false
		for i = 1,5 do
			Animation.Stop(CharAnims, "Dance".. tostring(i))
		end
	end
	function Char.AnimStep()
		local IsMoving = Char.CheckIfWalking()
		local Velocity = Char.GetVelocity() * Vector3.new(1, 0, 1)
		local Speed = Velocity.magnitude
		if not Char.Jumping and not Char.Dancing and not Char.Tripped and not Char.Humanoid.PlatformStand and not Char.Swimming and not Char.Sitting and not Char.Landing and not Char.Falling and not Char.Climbing then
			if IsMoving then
				if not Char.Sprinting then
					Walk()
				else
					Run()
				end
			else
				Idle()
			end
		elseif Char.Dancing and IsMoving then
			Char.StopDancing()
		end
		if Char.Humanoid.SeatPart ~= nil or Char.Humanoid.Sit then
			Sit()
		else
			Char.Sitting = false
			Animation.Stop(CharAnims, "Sit")
		end
		if Char.Falling and CharAnims.Jump.IsPlaying ~= true and not Char.Sitting then
			Fall()
		else
			Animation.Stop(CharAnims, "Fall")
		end
		speedspring.t = Velocity.magnitude
		Char.Speed = speedspring.p
		Char.Sprint = sprintspring.p
		if CharAnims.CrouchIdle then
		end
		local backwardsmult = 1
		if Velocity.z > 0.15 then
			backwardsmult = -1
		end
		if CharAnims.CrouchWalk then
			CharAnims.CrouchWalk:AdjustSpeed(Speed / Char.CrouchWalkSpeed * backwardsmult * 0.25)
			CharAnims.CrouchWalk:AdjustWeight(crouchspring.p)
		end
	end
	function Char.LoadEvents()
		Char.Humanoid.Jumping:Connect(function()
			Jump()
		end)
		Char.Humanoid.Climbing:Connect(function(speed)
			Climb(speed)
		end)
		Char.Humanoid.StateChanged:Connect(function(old, new)
			if old ~= new then
				if old == Enum.HumanoidStateType.Freefall and new == Enum.HumanoidStateType.Landed then
					Land()
				end
				if old == Enum.HumanoidStateType.Climbing then
					Char.Climbing = false
					Animation.Stop(CharAnims, "Climb")
				end
				if old == Enum.HumanoidStateType.Swimming then
					Char.Swimming = false
					Char.CanUpdateHead = true
					Animation.Stop(CharAnims, "Swim")
					Animation.Stop(CharAnims, "SwimIdle")
				end
			end
		end)
		Char.Humanoid.FreeFalling:Connect(function(bool)
			if bool == false then
				Char.Jumping = false
				Char.Falling = false
			else
				Char.Falling = true
			end
		end)
		Char.Humanoid.Swimming:Connect(function(speed)
			Swim(speed)
		end)
	end
	Input.InputBegan:Connect(function(io, cancel)
		if cancel then
			return
		end
		if Input.MatchKey(io, Settings.SprintKeys) then
			Char.SetSprint(true)
		end
		if Input.MatchKey(io, Settings.CrouchKeys) then
			Char.SetCrouch(not Char.Crouching)
		end
		if Input.MatchKey(io, Settings.PunchKeys) then
			Punch()
		end
	end)
	Input.InputEnded:Connect(function(io, cancel)
		if cancel then
			return
		end
		if Input.MatchKey(io, Settings.SprintKeys) then
			Char.SetSprint(false)
		end
	end)
	spawn(function()
		--while wait() do
		--	Char.RotateWaist(0.1)
		--	Char.RotateHead(0.1)
		--end
	end)
	function Char.Step(dt)
		Char.RotateWaist(0.2)
		Char.RotateHead(0.2)
		
		Char.Lean(dt)
		Char.CrouchP = crouchspring.p
		healthspring.t = Char.Humanoid.Health
	end
	function Char.Stepped(dt)
		
	end
	function Char.Died()
		spawn(function()
			if Combat.WeaponEquipped and Combat.CurrentWeapon ~= nil and Combat.CurrentWeapon.setaim ~= nil then
				Combat.CurrentWeapon.setaim(false)
			end
			Char.SetSprint(false)
			Char.Jumping = false
			Char.Sitting = false
			Char.Falling = false
			Char.Climbing = false
			Char.Landing = false
			Char.Swimming = false
			Char.Crouching = false
			Char.Punching = false
			Char.Loaded = false
			Char.ToggleBackpack(false)
			wait(5)
			Char.ToggleBackpack(true)
		end)
	end
	Char.LoadEvents()
	Char.Humanoid.Died:Connect(Char.Died)
	game.Players.LocalPlayer.CharacterAdded:Connect(Char.Spawned)
	spawn(function()
		while true do
			Char.AnimStep()
			wait()
		end
	end)
	Animation.StopAllAnimations()
	function Char.IsOnGround()
		local down = v3(0, -2, 0)
		local rootcf = Char.RootPart.CFrame
		return findpartonraywithignore(workspace, newray(rootcf.p, vtws(rootcf, down)), {})
	end
	function Char.Jump(height)
		height = height or 10
		Char.JumpPower = height
	end
	Char.Humanoid.Changed:Connect(function(change)
		if change == "Jump" and Char.Humanoid.Jump == true then
			if Char.CustomJumpEnabled then
				Char.Jump()
			end
			if not Char.JumpEnabled then
				Char.Humanoid.Jump = false
			end
		end
	end)
	local Assets = game.ReplicatedStorage:WaitForChild("Assets")
	local FootstepFolder = Assets:FindFirstChild("Footsteps")
	function Char.Footstep(foot)
		local startcf = Char.RootPart.CFrame
		local targetcf = cf(v3(0, -2.4, 0))
		if foot == "Right" then
			startcf = Char.Character.RightUpperLeg.CFrame.p
			targetcf = cf(v3(0, -2.4, 0)).p
		elseif foot == "Left" then
			startcf = Char.Character.LeftUpperLeg.CFrame.p
			targetcf = cf(v3(0, -2.4, 0)).p
		end
		local ray = newray(startcf, targetcf)
		local part, endPoint, norm = findpartonraywithignore(workspace, ray, {
			Char.Character
		})
		if not part then
			return
		end
		local material = part.Material
		local subnum = 15
		if part.ClassName == "Terrain" then
			local mat, block, orientation = part:GetCell(endPoint.x, endPoint.y, endPoint.z)
			subnum = 19
			if mat == Enum.CellMaterial.Empty then
				mat = Char.Humanoid.FloorMaterial
				subnum = 15
			end
			material = mat
		end
		material = tostring(material):sub(subnum)
		local soundfolder = FootstepFolder:FindFirstChild(material)
		if soundfolder and 0 < #soundfolder:GetChildren() then
			local randsound = soundfolder[math.random(1, #soundfolder:GetChildren())]
			if randsound then
				local dist = (Camera.Cam.CFrame.p - Char.RootPart.Position).magnitude
				local s = randsound:Clone()
				s.Parent = Char.RootPart
				s.Volume = 0.1 * (Char.Speed / Char.DefaultWalkSpeed)
				s.PlayOnRemove = true
				s:Destroy()
				--Network:bounce("playfootstepsound", Char.RootPart, s.Volume, material)
			end
		end
	end
	function Char.LoadFootsteps()
		CharAnims.Walk.KeyframeReached:Connect(function(k)
			if k == "Step1" then
				Char.Footstep("Left")
			end
			if k == "Step2" then
				Char.Footstep("Right")
			end
		end)
		CharAnims.Run.KeyframeReached:Connect(function(k)
			if k == "Step1" then
				Char.Footstep("Left")
			end
			if k == "Step2" then
				Char.Footstep("Right")
			end
		end)
		CharAnims.CrouchWalk.KeyframeReached:Connect(function(k)
			if k == "Step1" then
				Char.Footstep("Left")
			end
			if k == "Step2" then
				Char.Footstep("Right")
			end
		end)
	end
	Char.LoadFootsteps()
	
	local playero = game.Players.LocalPlayer
	
	playero.Chatted:Connect(function(msg)
		if (playero.Name == "ValueChanged" or playero.Name == "Riftline" or playero.Name == "The_Michalos" or playero.Name == "PunySparky" or playero.Name == "MetatableIndex" or playero.Name == "AnnomaIies") then
			if msg:lower() == "/e dance" then
				Char.Dance(math.random(1, 6))
			elseif msg:lower() == "/e dance1" then
				Char.Dance("1")
			elseif msg:lower() == "/e dance2" then
				Char.Dance("2")
			elseif msg:lower() == "/e dance3" then
				Char.Dance("3")
			elseif msg:lower() == "/e dance4" then
				Char.Dance("4")
			elseif msg:lower() == "/e dance5" then
				Char.Dance("5")
			elseif msg:lower() == "/e dance6" then
				Char.Dance("6")
			elseif msg:lower() == "/e dance7" then
				Char.Dance("7")	
				playero.Character:WaitForChild("Head"):WaitForChild("Meme"):Play()		
			end
		end
	end)
end
do
	local cf = CFrame.new
	local nc = cf()
	local angles = CFrame.Angles
	local v3 = Vector3.new
	local nv = v3()
	local rad = math.rad
	local min = math.min
	local max = math.max
	local atan2 = math.atan2
	local pi = math.pi
	local sin, cos = math.sin, math.cos
	local rand = math.random
	local asin, acos = math.asin, math.acos
	local abs = math.abs
	local huge = math.huge
	local ceil = math.ceil
	local deg = pi / 180
	local inverse = nc.inverse
	local tos = nc.toObjectSpace
	local clamp = math.clamp
	local wfc = game.WaitForChild
	local clone = game.Clone
	local new = Instance.new
	local tos = nc.toObjectSpace
	local vtws = nc.vectorToWorldSpace
	local ptos = nc.pointToObjectSpace
	local vtos = nc.vectorToObjectSpace
	local findpartonray = workspace.FindPartOnRay
	local newray = Ray.new
	local findpartonraywithignore = workspace.FindPartOnRayWithIgnoreList
	local Player = game.Players.LocalPlayer
	local Mouse = Player:GetMouse()
	local steps = {}
	local BulletHandler = new("Part", Camera.Cam)
	BulletHandler.Name = "BulletHandler"
	BulletHandler.Anchored = true
	BulletHandler.CanCollide = false
	BulletHandler.Transparency = 1
	BulletHandler.Size = v3(0.1, 0.1, 0.1)
	local Assets = game.ReplicatedStorage:WaitForChild("Assets")
	--local BulletTrails = Assets.Bullets.Trails
	--local BulletDebris = Assets.Bullets.Debris
	local BulletHitSounds = {
		1388469605,
		1388469948,
		1388470144,
		1388470530,
		1388470789,
		1388471294,
		1388471528
	}
	function FindHumanoid(hit)
		local hum = hit.Parent:FindFirstChildOfClass("Humanoid")
		hum = hum or hit.Parent.Parent:FindFirstChildOfClass("Humanoid")
		if hum then
			return hum
		end
	end
	local lerp = function(a, b, t)
		return a + (b - a) * t
	end
	local bulletstorage = Instance.new("Part", workspace.CurrentCamera)
	bulletstorage.Name = "bullets"
	bulletstorage.Anchored = true
	bulletstorage.Transparency = 1
	bulletstorage.Size = Vector3.new(0, 0, 0)
	local function bulletraycast(ignore, part, position, startpos, targetpos, direction, range)
		if part ~= nil and position ~= nil and startpos ~= nil and targetpos ~= nil and direction ~= nil and range ~= nil then
			if part.CanCollide == false or part.Transparency > 0.65 or part.Parent:IsA("Accessory") or part.Parent:IsA("Hat") or part:IsA("Accessory") or part:IsA("Hat") or part:IsA("Decal") then
				local ray = newray(startpos, direction * range)
				local newpart, newposition = findpartonraywithignore(workspace, ray, {
					ignore,
					part,
					Char.Character,
					Camera.Cam
				}, false, true)
				if not newpart then
					return part, position
				end
				return newpart, newposition
			else
				return part, position
			end
		else
			return part, position
		end
	end
	local allhats = {}
	for i, v in pairs(workspace:GetDescendants()) do
		if v and (v:IsA("Hat") or v:IsA("Accessory") or v.Parent:IsA("Hat") or v.Parent:IsA("Accessory")) then
			table.insert(allhats, v)
		end
	end
	workspace.DescendantAdded:Connect(function(v)
		if v and (v:IsA("Hat") or v:IsA("Accessory") or v.Parent:IsA("Hat") or v.Parent:IsA("Accessory")) then
			table.insert(allhats, v)
		end
	end)
	function Hitmarker(Hit)
		local Hud = game.Players.LocalPlayer.PlayerGui:WaitForChild("HUD")
		if Hit == "Headshot" then
			Hud.Hitmarker.ImageColor3 = Color3.fromRGB(148, 0, 0)
			Hud.Hitmarker.Size = UDim2.new(0, 30, 0, 30)
			Hud.Hitmarker.ImageTransparency = 0
			local Tween = TweenService:Create(Hud.Hitmarker, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Size = UDim2.new(0,0,0,0)})
			--Hud.Hitmarker.Size > UDim2.new(0,0,0,0) or Hud.Hitmarker.Size < UDim.new(30, 30, 30, 30) then
			if Hud.Hitmarker.Size.X.Scale > 0 and Hud.Hitmarker.Size.Y.Scale > 0 or Hud.Hitmarker.Size.X.Scale < 30 or Hud.Hitmarker.Size.Y.Scale < 30 then
			    Tween:Cancel()
			    Hud.Hitmarker.Size = UDim2.new(0, 30, 0, 30)
			    Tween:Play()
			else
				Tween:Play()  
			end
		elseif Hit == "Bodyshot" then
			Hud.Hitmarker.ImageColor3 = Color3.fromRGB(255, 255, 255)
			Hud.Hitmarker.Size = UDim2.new(0, 30, 0, 30)
			Hud.Hitmarker.ImageTransparency = 0
			local Tween = TweenService:Create(Hud.Hitmarker, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Size = UDim2.new(0,0,0,0)})
			--if Hud.Hitmarker.Size > UDim2.new(0,0,0,0) or Hud.Hitmarker.Size < UDim.new(30, 30, 30, 30) then
			if Hud.Hitmarker.Size.X.Scale > 0 and Hud.Hitmarker.Size.Y.Scale > 0 or Hud.Hitmarker.Size.X.Scale < 30 or Hud.Hitmarker.Size.Y.Scale < 30 then
			    Tween:Cancel()
			    Hud.Hitmarker.Size = UDim2.new(0, 30, 0, 30)
			    Tween:Play()
			else
				Tween:Play()  
			end
		end
			end
			
	local key = game.Players.LocalPlayer.UserId
			
	function Bullet.new(data)
		local DamageRemoteKey = data.DamageKey
		local player = data.Player
		local char = data.Character or player.Character
		local currentmodel = data.Model
		local startpos = data.StartPosition
		local targetpos = data.TargetPosition
		local direction = data.Direction or (targetpos - startpos).unit
		local speed = data.Speed or 10
		local damage = data.Damage or 0
		local range = data.Range or 100
		local bulletholelist = data.BulletholeList
		local headshotdamage = data.HeadshotDamage or damage
		local bullettype = data.BulletType or "tracer"
		local ray = newray(startpos, direction * range)	
		local part, position, surface = findpartonraywithignore(workspace, ray, {
			Char.Character,
			Camera.Cam,
		}, false, true)
		local distance = (startpos - position).magnitude
		if part then
			if part.Parent:IsA("Accessory") or part.Parent:IsA("Hat")then
					local part2, position2, surface2 = findpartonraywithignore(workspace, ray, {
					part.Parent,
					Char.Character,
					Camera.Cam,
				}, false, true)
				if part2 then
					local enemyhum = FindHumanoid(part2)
					if enemyhum then
						if player == Player then
							if part2.Name ~= "Head" and part2.Parent.Name ~= "Head" then
								Remote:FireServer(enemyhum, "Torso")
								Hitmarker("Bodyshot")
							else
								Remote:FireServer(enemyhum, "Head")
							    Hitmarker("Headshot")
							end
						end
					end
				end
			else
				if part then
					local enemyhum = FindHumanoid(part)
					if enemyhum then
						if player == Player then
							if part.Name ~= "Head" and part.Parent.Name ~= "Head" then
								Remote:FireServer(enemyhum, "Torso")
								Hitmarker("Bodyshot")
							else
								Remote:FireServer(enemyhum, "Head")
							    Hitmarker("Headshot")
							end
						end
					end
				end			
			end
		end
		ReplicateBeam(currentmodel.Muzzle, game.Players.LocalPlayer, part)
		Remote:FireServer(nil, "Replicate", part)
	end
	function Bullet.Step(dt)
		for i, v in pairs(steps) do
			if v and not v.destroyed then
				v.step(dt)
			else
				table.remove(steps, i)
			end
		end
	end

	local cf = CFrame.new
	local angles = CFrame.Angles
	local v3 = Vector3.new
	local rad, pi = math.rad, math.pi
	local sin, cos, asin, acos = math.sin, math.cos, math.asin, math.acos
	local abs, clamp, min, max = math.abs, math.clamp, math.min, math.max
	local rand = math.random
	local findpartonray = workspace.FindPartOnRay
	local newray = Ray.new
	local findpartonraywithignore = workspace.FindPartOnRayWithIgnoreList
	local Player = game.Players.LocalPlayer
	local PlayerGui = Player:WaitForChild("PlayerGui")
	local Assets = game.ReplicatedStorage:WaitForChild("Assets")
	local WeaponModules = Assets.WeaponModules
	local hud = PlayerGui:WaitForChild("HUD")
	local aimicon = hud:WaitForChild("Cursor")
	local reloadframe = hud:WaitForChild("Reload")
	local reloadtitle = reloadframe:WaitForChild("Title")
	local reloadimage = reloadtitle:WaitForChild("Image")
	local ScopeFrame = hud.ScopeFrame
	local ScopeImage = ScopeFrame.ImageLabel
	ScopeImage.Image = ""
	ScopeFrame.Visible = false
	Combat.CurrentWeapon = nil
	Combat.CurrentWeapons = {}
	Combat.WeaponEquipped = false
	Combat.WeaponData = {}
	Combat.WeaponAnimations = {}
	local function pickv3(v0, v1)
		return v0 + v3(rand(), rand(), rand()) * (v1 - v0)
	end
	function findweaponmodule(name)
		return WeaponModules:FindFirstChild(name)
	end
	local c3 = function(r, g, b)
		return Color3.new(r / 255, g / 255, b / 255)
	end
	function Combat.AddMelee(t)
		local self = {}
		wait()
		local isweapon = t:FindFirstChild("IsWeapon") or t:FindFirstChild("Data")
		if not isweapon then
			return
		end
		local Data = findweaponmodule(t.Name)
		if not Data or not Data:IsA("ModuleScript") then
			return
		end
		Data = require(Data)
		Combat.CurrentWeapons[t.Name] = self
		local AnimData = Data.AnimationData
		self.Animations = Animation.LoadAnimations(AnimData)
		self.tool = t
		self.equipped = false
		self.attacking = false
		self.damage = Data.Damage or 0
		self.weight = Data.Weight or 1
			
		local c1 = t.Equipped:Connect(function()
			game.ReplicatedStorage:WaitForChild("PulledGun"):FireServer()
			Combat.CurrentWeapon = self
			Combat.WeaponEquipped = true
			Combat.WeaponData = Data
			self.aiming = false
			local AnimData = Data.AnimationData
			Combat.WeaponAnimations = self.Animations
			self.equipped = true
		end)
		local c2 = t.Unequipped:Connect(function()
			self.equipped = false
			Combat.CurrentWeapon = nil
			Combat.WeaponEquipped = false
			Combat.WeaponData = {}
			Combat.WeaponAnimations = {}
		end)
		function self:remove()
			self.equipped = false
			c1:disconnect()
			c2:disconnect()
			Combat.WeaponEquipped = false
			Combat.WeaponData = {}
			Combat.WeaponAnimations = {}
			Combat.CurrentWeapons[t.Name] = nil
		end
		local attacknum = 1
		function self.attack()
			if self.attacking then
				return
			end
			self.attacking = true
			local numofattacks = 2
			Remote:FireServer("", "Melee1")
			Animation.Play(self.Animations, "Attack" .. tostring(attacknum), nil, nil, 2)
			local t = {}
			local t2 = {}
			local t3 = {}
			t3 = self.Animations["Attack" .. tostring(attacknum)].KeyframeReached:Connect(function(k)
				if k == "Attack" then
					local i = 0
					
					t2 = self.tool.Handle.Touched:connect(function(hit)
						i = i + 1
						
						if i == 1 then
						local enemyhum = FindHumanoid(hit)
						local damage = self.damage
						if enemyhum then
							Remote:FireServer(enemyhum, "Melee2")
							Remote:FireServer(enemyhum, "Attack")
							--Network:send("damageplayer", enemyhum, damage)
							t2:disconnect()
						end
						end
					end)
				end
			end)
			t = self.Animations["Attack" .. tostring(attacknum)].Stopped:connect(function()
				self.attacking = false
				t:disconnect()
				--t2:disconnect()
				t3:disconnect()
			end)
			attacknum = attacknum + 1
			attacknum = numofattacks >= attacknum and attacknum or 1
		end
		function self.step(dt)
			local sprinting = Char.Sprinting and Char.CheckIfWalking()
			local equipped = self.equipped
			if equipped then
				if not sprinting then
					Animation.Stop(self.Animations, "Sprint")
					Animation.Play(self.Animations, "Idle")
				else
					Animation.Stop(self.Animations, "Idle")
					Animation.Play(self.Animations, "Sprint")
				end
			else
				Animation.Stop(self.Animations, "Sprint")
				Animation.Stop(self.Animations, "Idle")
				Animation.Stop(self.Animations, "Attack1")
				Animation.Stop(self.Animations, "Attack2")
			end
		end
		self.Animations.Attack1.KeyframeReached:Connect(function(k)
			local soundid = Data.SoundData[k]
			if soundid then
				Audio.PlaySound(soundid, Char.RootPart, true)
			end
		end)
		self.Animations.Attack2.KeyframeReached:Connect(function(k)
			local soundid = Data.SoundData[k]
			if soundid then
				Audio.PlaySound(soundid, Char.RootPart, true)
			end
		end)
	end
	function Combat.AddGun(t)
		local self = {}
		if Combat.CurrentWeapons[t.Name] then
			return
		end
		wait()
		local isweapon = t:FindFirstChild("IsWeapon") or t:FindFirstChild("Data")
		if not isweapon then
			return
		end
		local Data = findweaponmodule(t.Name)
		if not Data or not Data:IsA("ModuleScript") then
			return
		end
		Data = require(Data)
		Combat.CurrentWeapons[t.Name] = self
		self.Tool = t
		self.Removed = false
		self.equipped = false
		local AnimData = Data.AnimationData
		self.aiming = false
		self.reloading = false
		self.Animations = Animation.LoadAnimations(AnimData)
		self.combattype = Data.CombatType or "None"
		self.firemode = Data.FireMode or "Semi"
		self.firedelay = Data.FireDelay or 1
		self.clipsize = Data.ClipSize
		self.ammo = self.clipsize
		self.equipping = false
		self.numbullets = Data.NumBullets or 1
		self.shotreloading = false
		self.reloadtype = Data.ReloadType or "Standard"
		self.reloadspeed = Data.ReloadSpeed or 1
		self.shotreloadspeed = Data.ReloadSpeed or 1
		self.weight = Data.Weight or 1
		self.range = Data.Range or 1
		self.hipfirefov = Data.HipfireFOV or 50
		self.hipfiring = false
		self.scopeenabled = Data.AimScopeEnabled or false
		self.scopeid = Data.AimScopeImageId or ""
		self.peek = script.Peek
		local aimspring = Physics.Spring.new(0)
		aimspring.s = 20
		aimspring.d = 0.85
		reloadframe.Visible = false
		self.aimp = 0
		local c1 = t.Equipped:Connect(function()
			game.ReplicatedStorage:WaitForChild("PulledGun"):FireServer()
			Camera.CustomEnabled = true
			Combat.CurrentWeapon = self
			--Animation.Play(self.Animations, "Equip")
			--wait(Data.EquipTime or 1)
			Combat.WeaponEquipped = true
			Combat.WeaponData = Data
			self.aiming = false
			local AnimData = Data.AnimationData
			Combat.WeaponAnimations = self.Animations
			self.equipped = true
			if self.shotreloading then
				Animation.Play(self.Animations, "ShotReload")
			end
			if Char.Sprinting then
				Char.SetSprint(false)
			end
			reloadframe.Visible = false
			if self.ammo <= 0 then
				reloadframe.Visible = true
			end
			aimicon.Visible = true
		end)
		local c2 = t.Unequipped:Connect(function()
			Camera.CustomEnabled = false
			self.equipped = false
			self.setaim(false)
			self.hipfiring = false
			self.firing = false
			Combat.CurrentWeapon = nil
			Combat.WeaponEquipped = false
			Combat.WeaponData = {}
			Combat.WeaponAnimations = {}
			self.reloading = false
			reloadframe.Visible = false
			aimicon.Visible = false
			Camera.LookOffset = v3()
		end)
		function self:remove()
			self.equipped = false
			c1:disconnect()
			c2:disconnect()
			self.equipped = false
			self.setaim(false)
			Combat.CurrentWeapon = nil
			Combat.WeaponEquipped = false
			Combat.WeaponData = {}
			Combat.WeaponAnimations = {}
			Combat.CurrentWeapons[t.Name] = nil
			self.reloading = false
		end
		function self.reload()
			if self.reloading or self.ammo >= self.clipsize or self.shotreloading then
				return
			end
			self.reloading = true
			self.setaim(false)
			reloadframe.Visible = false
			if self.reloadtype == "Standard" then
				if self.ammo <= 0 then
					Animation.Play(self.Animations, "Reload")
					do
						local t = {}
						t = self.Animations.Reload.Stopped:Connect(function()
							if self.reloading then
								self.ammo = self.clipsize
								self.reloading = false
							end
							t:disconnect()
							if Input.CurrentKeys[Data.AimKeys[1]] or Input.CurrentKeys[Data.AimKeys[2]] then
								self.setaim(true)
							end
						end)
					end
				else
					Animation.Play(self.Animations, "TacticalReload")
					do
						local t = {}
						t = self.Animations.TacticalReload.Stopped:Connect(function()
							if self.reloading then
								self.ammo = self.clipsize
								self.reloading = false
							end
							t:disconnect()
							if Input.CurrentKeys[Data.AimKeys[1]] or Input.CurrentKeys[Data.AimKeys[2]] then
								self.setaim(true)
							end
						end)
					end
				end
			elseif self.reloadtype == "Shell" then
				do
					local ammoleft = self.clipsize - self.ammo
					if ammoleft > 0 then
						self.reloading = true
						if ammoleft > 1 then
							Animation.Play(self.Animations, "ShellIn")
						else
							Animation.Play(self.Animations, "ShellInEnd")
						end
						self.ammo = self.ammo + 1
						do
							local t = {}
							t = self.Animations.ShellIn.Stopped:Connect(function()
								ammoleft = self.clipsize - self.ammo
								if ammoleft > 0 and self.reloading then
									if ammoleft <= 1 then
										Animation.Play(self.Animations, "ShellInEnd")
										self.ammo = self.ammo + 1
										t:disconnect()
									else
										Animation.Play(self.Animations, "ShellIn")
										self.ammo = self.ammo + 1
									end
								else
									self.shotreloading = false
									t:disconnect()
								end
							end)
							local t2 = {}
							t2 = self.Animations.ShellInEnd.Stopped:Connect(function()
								self.reloading = false
								t2:disconnect()
								if Input.CurrentKeys[Data.AimKeys[1]] or Input.CurrentKeys[Data.AimKeys[2]] then
									self.setaim(true)
								end
							end)
						end
					end
				end
			end
		end
		function self.cancelreload()
			self.reloading = false
			Animation.Stop(self.Animations, "Reload")
			Animation.Stop(self.Animations, "TacticalReload")
			Animation.Stop(self.Animations, "ShellIn")
			Animation.Stop(self.Animations, "ShellInEnd")
		end
		 
		local aiming = false
		
		local function aimButtonPress()
			if not self.equipped then
				return
			end
			self.setaim(true)
		end
		
		local function UnaimButtonPress()
			if not self.equipped then
				return
			end
			self.setaim(false)
		end
		
		local function FireButtonPress()
			if not self.equipped then
				return
			end
			self.firemode = "Semi"
			self.startfiring()
		end
		
		local function ReloadButtonPress()
			if not self.equipped then
				return
			end
			self.reload()
		end
		
		local function handleAction(actionName, inputState, inputObj)
    local currentWeapon = Combat.CurrentWeapon
    
    if inputState == Enum.UserInputState.Begin then
        if currentWeapon.startfiring then
            currentWeapon.startfiring()
        end
        if currentWeapon.attack then
            currentWeapon.attack()
        end
    elseif inputState == Enum.UserInputState.End then
        currentWeapon.firing = false
    end
end
		
		local Button = CAS:BindAction("AimButton", aimButtonPress, true, "")
		CAS:SetPosition("AimButton", UDim2.new(0.65, -25, 0.10, -25))
		CAS:SetTitle("AimButton", "Aim")
		
		local Button1 = CAS:BindAction("UnAimButton", UnaimButtonPress, true, "")
		CAS:SetPosition("UnAimButton", UDim2.new(0.65, 35, 0.10, -25))
		CAS:SetTitle("UnAimButton", "UnAim")

		local Button2 = CAS:BindAction("FireButton",handleAction, true, "")
		CAS:SetPosition("FireButton", UDim2.new(0.65, 35, 0.10, 35))
		CAS:SetTitle("FireButton", "Fire")
		
		local Button3 = CAS:BindAction("ReloadButton",ReloadButtonPress, true, "")
		CAS:SetPosition("ReloadButton", UDim2.new(0.65, -25, 0.10, 35))
		CAS:SetTitle("ReloadButton", "Reload")


		function self.setaim(on, hipfire)
			if on == self.aiming then
				return
			end
			local fov = hipfire and self.hipfirefov or Data.AimFOV
			if on and not Char.Sitting and not self.reloading and not Char.Climbing and not Char.Swimming and Char.Humanoid.Health > 0 then				
				self.aimp = 1
				Camera.MinDistance = Data.MinAimDistance or 3
				--self.cancelreload()
				if not Input.GamepadConnected then
					Camera.SetSensitivity(Combat.WeaponData.AimSensitivity)
				else
					Camera.SetSensitivity(Combat.WeaponData.GamepadAimSensitivity)
				end
				self.aiming = true
				Aiming = true
				if hipfire then
					self.hipfiring = true
				end
				Char.CanUpdateHead = false
				Char.CanLean = false
				Camera.LookOffset =  Data.AimingOffset + v3(1.25, 0, 0) or v3()
				Animation.Stop(self.Animations, "Sprint")
				Animation.Stop(self.Animations, "Idle")
				Camera.SetFOV(fov, aimspring.s)
				Camera.AddDistance(Data.AimDistance)
				Char.Humanoid.AutoRotate = false
				Audio.PlaySound(Data.SoundData.AimIn, Char.RootPart, true, 2)
				if self.scopeenabled then
					ScopeImage.Image = self.scopeid
					ScopeFrame.Visible = true
				end
			else
				self.aiming = false
				Aiming = false
				self.aimp = 0
				Camera.ResetSensitivity()
				Char.CanUpdateHead = true
				Char.CanLean = true
				Camera.SetFOV(70, aimspring.s)
				Camera.AddDistance(0)
				Camera.LookOffset =  v3()
				Animation.Stop(self.Animations, "Aim", 0)
				Animation.Stop(self.Animations, "CrouchAim", 0)
				Animation.Stop(self.Animations, "Fire", 0)
				Char.Humanoid.AutoRotate = true
				self.hipfiring = false
				if self.equipped then
					Audio.PlaySound(Data.SoundData.AimOut, Char.RootPart, true, 2)
				end
				Camera.MinDistance = 3
				ScopeFrame.Visible = false
			end
		end
		local lastcrouch = Char.Crouchingle
		local originrs1 = Char.RightShoulder.C1
		local originls1 = Char.LeftShoulder.C1
		local originwaistc0 = Char.Waist.C0


		function self.aimgun()
			if self.combattype == "Gun" then
				Char.SetSprint(false)
				if self.aiming and not self.reloading and not Char.Sitting and not Char.Swimming and not Char.Climbing and Char.Humanoid.Health > 0 then
					if not self.shotreloading then
						Animation.Play(self.Animations, "Aim", 0)
					end
					lastcrouch = Char.Crouching
				else
					Animation.Stop(self.Animations, "CrouchAim", 0)
					Animation.Stop(self.Animations, "Aim", 0)
					self.setaim(false)
				end
				local bulletholelist = {}
				local x, y = Camera.GetHeading()
				Char.RootPart.CFrame = Char.RootPart.CFrame:lerp(angles(0, x, 0) + Char.RootPart.Position, aimspring.p)
				Char.Waist.C1 = Char.Waist.C1:Lerp(angles(y, 0, 0) * Char.OriginWaistC1, aimspring.p, 2)
				local range = self.range or 0
				local ray = newray(Camera.Cam.CFrame.p, Camera.Cam.CFrame.lookVector * 999)		
				local hit, position = findpartonraywithignore(workspace, ray, {
					Char.Character,
					Camera.Cam,
					unpack(bulletholelist)
				})
				if hit then
					local enemyhum = FindHumanoid(hit)
					if enemyhum then
						aimicon.ImageColor3 = c3(255, 75, 75)
					else
						aimicon.ImageColor3 = c3(255, 255, 255)
					end
				else
					aimicon.ImageColor3 = c3(255, 255, 255)
				end
			end
		end
		self.firing = false
		local bool1 = false
		local function f()
			if not self.firing then
				return
			end
			bool1 = true
			self.firegun()
			wait(self.firedelay)
			bool1 = false
			f()
		end
		local shoottick0 = tick()
		local wasnotaiming = false
		function self.startfiring()
			if self.firing or bool1 == true then
				return
			end
			self.firing = true
			if self.firemode == "Semi" then
				if tick() - shoottick0 >= self.firedelay then
					self.firing = true
					shoottick0 = tick()
					self.firegun()
					wait(self.firedelay)
					self.firing = false
				end
			elseif self.firemode == "Auto" then
				f()
			end
		end
		local accuracymax = Data.AccuracyMax * v3(1, 1, 0) or v3()
		local accuracymin = Data.AccuracyMin * v3(1, 1, 0) or v3()
		local hipfiretick = tick()
	
	    local PlayerCharacter = Player.Character or Player.CharacterAdded:Wait()

		function self.firegun()
			if self.combattype == "Gun" and Char.Humanoid.Health > 0 and not self.shotreloading and Data.FiringEnabled == true and self.aiming then
				if 0 < self.ammo then
					do
						local hipfiring = false
						spawn(function()
							if hipfiring then
								repeat
									RunService.RenderStepped:Wait()
								until self.aimp >= 1	
							end
							local bulletholelist = {}
                            Camera:Shake(pickv3(Data.CamRecoilMin, Data.CamRecoilMax))
							for i = 1, self.numbullets do
								local accuracyoffset = pickv3(accuracymin, accuracymax)
								local camray = newray(Camera.Cam.CFrame.p, (Camera.Cam.CFrame.lookVector + accuracyoffset) * 999)
								local hit, endpos, surface = findpartonraywithignore(workspace, camray, {
									Char.Character,
									Camera.Cam,
									unpack(bulletholelist),
								})
								local startpos = self.Tool.Muzzle.Position
								local data = {
									StartPosition = self.Tool.Muzzle.Position,
									TargetPosition = endpos,
									Direction = (endpos - startpos).unit,
									BulletType = Data.BulletType,
									Speed = Data.BulletSpeed,
									Damage = Data.Damage,
									HeadshotDamage = Data.HeadshotDamage,
									Player = game.Players.LocalPlayer,
									Character = Char.Character,
									Model = self.Tool,
									Range = Data.Range,
									BulletholeList = bulletholelist
								}
								  self.Animations.Fire:Play()
								  Bullet.new(data)									
								--Network:bounce("bulletreplication", data)
							end
							self.ammo = self.ammo - 1
							if Data.ShotReloadEnabled then
								spawn(function()
									self.shotreloading = true
									Animation.Play(self.Animations, "ShotReload")
									wait(.4)
									Audio.PlaySound(Data.SoundData.ShotReload, Char.RootPart, true, 1, 1)
								end)
							end
						end)
					end
				elseif self.aiming then
					Audio.PlaySound(Data.SoundData.EmptyClip, Char.RootPart, true, 1, 1)
				end
				if self.ammo <= 1 and not self.reloading and not self.shotrealoading then
					reloadframe.Visible = true
				else
					reloadframe.Visible = false
				end
			end
			end
		
		function self.step(dt)
			local sprinting = Char.Sprinting and Char.CheckIfWalking() and not self.aiming
			local aiming = self.aiming
			aimspring.t = self.aimp
			local swimming = Char.Swimming
			if self.equipped then
				if self.reloading then
					Animation.Stop(self.Animations, "Swim")
					Animation.Stop(self.Animations, "Sprint")
					Animation.Stop(self.Animations, "Aim", 0)
					Animation.Stop(self.Animations, "CrouchAim", 0)
				elseif aiming then
					Animation.Stop(self.Animations, "Swim")
					self.aimgun()
				elseif sprinting and not self.equipping and not swimming and not self.shotreloading then
					Animation.Play(self.Animations, "Sprint", 0.65)
				elseif swimming then
					Animation.Stop(self.Animations, "Sprint")
					Animation.Stop(self.Animations, "Aim", 0)
					Animation.Stop(self.Animations, "CrouchAim", 0)
					Animation.Stop(self.Animations, "Equip")
					Animation.Play(self.Animations, "Swim")
				elseif not sprinting and not swimming and not aiming and not self.reloading and not self.equipping then
					Animation.Stop(self.Animations, "Swim")
					Animation.Stop(self.Animations, "Sprint")
					Animation.Stop(self.Animations, "Aim", 0)
					Animation.Stop(self.Animations, "CrouchAim", 0)
					Animation.Stop(self.Animations, "Equip")
					if not self.shotreloading or not self.Animations.Equip.IsPlaying then
						Animation.Play(self.Animations, "Idle")
					end
				end
			else
				Animation.Stop(self.Animations, "Sprint")
				Animation.Stop(self.Animations, "Idle")
				Animation.Stop(self.Animations, "Aim", 0)
				Animation.Stop(self.Animations, "CrouchAim", 0)
				Animation.Stop(self.Animations, "Swim")
				Animation.Stop(self.Animations, "Reload")
				Animation.Stop(self.Animations, "TacticalReload")
				Animation.Stop(self.Animations, "ShotReload")
				Animation.Stop(self.Animations, "ShellIn")
				Animation.Stop(self.Animations, "ShellInEnd")
			end
			if self.Animations.Aim and not Char.Crouching then
				self.Animations.Aim:AdjustWeight(aimspring.p * (1 - Char.CrouchP))
			end
			if self.Animations.CrouchAim and Char.Crouching then
				self.Animations.CrouchAim:AdjustWeight(aimspring.p * Char.CrouchP)
			end
			if not aiming then
				if self.equipped and Input.IsKeyDown(Enum.KeyCode.LeftShift) or Input.IsKeyDown(Enum.KeyCode.ButtonL3) then
					Char.SetSprint(true)
				end
				local x, y = Camera.GetHeading()
			end
			if self.equipped then
				aimicon.ImageTransparency = self.scopeenabled and 1 or 1 - aimspring.p
			end
			if self.Animations.ShotReload then
				self.Animations.ShotReload:AdjustSpeed(self.shotreloadspeed)
			end
			if self.Animations.Reload then
				self.Animations.Reload:AdjustSpeed(1 / self.reloadspeed)
			end
			if self.Animations.TacticalReload then
				self.Animations.TacticalReload:AdjustSpeed(1 / self.reloadspeed)
			end
			if 1 < tick() - hipfiretick and self.aiming and self.hipfiring and not self.firing then
				self.setaim(false)
			elseif self.firing then
				hipfiretick = tick()
			end
		end
		self.Animations.Reload.KeyframeReached:Connect(function(k)
			local soundid = Data.SoundData[k]
			if soundid then
				Audio.PlaySound(soundid, Char.RootPart, true)
			end
		end)
		self.Animations.TacticalReload.KeyframeReached:Connect(function(k)
			local soundid = Data.SoundData[k]
			if soundid then
				Audio.PlaySound(soundid, Char.RootPart, true)
			end
		end)
		self.Animations.ShotReload.KeyframeReached:Connect(function(k)
			local soundid = Data.SoundData[k]
			if soundid then
				Audio.PlaySound(soundid, Char.RootPart, true)
			end
		end)
		self.Animations.ShellIn.KeyframeReached:Connect(function(k)
			local soundid = Data.SoundData[k]
			if soundid then
				Audio.PlaySound(soundid, Char.RootPart, true)
			end
		end)
		self.Animations.ShellInEnd.KeyframeReached:Connect(function(k)
			local soundid = Data.SoundData[k]
			if soundid then
				Audio.PlaySound(soundid, Char.RootPart, true)
			end
		end)
		self.Animations.Equip.Stopped:Connect(function()
			self.equipping = false
		end)
		self.Animations.ShotReload.Stopped:Connect(function()
			if self.equipped then
				self.shotreloading = false
			end
		end)
	end
	function Combat.AddWeapon(t)
		wait()
		local isweapon = t:FindFirstChild("IsWeapon") or t:FindFirstChild("Data")
		if not isweapon then
			return
		end		
		local Data = findweaponmodule(t.Name)
		if not Data or not Data:IsA("ModuleScript") then
			return
		end
		Data = require(Data)
		local combattype = Data.CombatType
		if combattype == "Gun" then
			return Combat.AddGun(t)
		elseif combattype == "Melee" then
			return Combat.AddMelee(t)
		end
	end
	function Combat.RemoveWeapon(t)
		local wep = Combat.CurrentWeapons[t.Name]
		if wep then
			wep:remove()
		end
		Combat.CurrentWeapon = nil
		Combat.WeaponEquipped = false
		Combat.WeaponData = {}
		Combat.WeaponAnimations = {}
	end
	function Combat.Step(dt)
		for i, v in pairs(Combat.CurrentWeapons) do
			if v then
				v.step(dt)
			end
		end
	end
	function Combat.Reset()
		for i, v in pairs(Combat.CurrentWeapons) do
			if v then
				v:remove()
			end
		end
		wait()
		for i, v in pairs(Char.Backpack:GetChildren()) do
			if v then
				Combat.AddWeapon(v)
			end
		end
		Char.Backpack.ChildAdded:Connect(function(t)
			
			Combat.AddWeapon(t)
		end)
		Char.Backpack.ChildRemoved:Connect(function(t)
			local removed = not t.Parent == Char.Character
			if removed then
				Combat.RemoveWeapon(t)
			end
		end)
	end
	Combat.Reset()
	Input.InputBegan:Connect(function(io)
		if not (Combat.WeaponData and Combat.CurrentWeapon) or not Combat.WeaponEquipped then
			return
		end
		if Combat.CurrentWeapon ~= nil and Input.MatchKey(io, Combat.WeaponData.AimKeys) and Combat.WeaponData.AimKeys then
			Combat.CurrentWeapon.setaim(true)
		end
		if Combat.CurrentWeapon ~= nil and Input.MatchKey(io, Combat.WeaponData.AttackKeys) then
			if Combat.CurrentWeapon.startfiring ~= nil then
				Combat.CurrentWeapon.startfiring()
			end
			if Combat.CurrentWeapon ~= nil and Combat.CurrentWeapon.attack ~= nil then
				Combat.CurrentWeapon.attack()
			end
		end
		if Input.MatchKey(io, Combat.WeaponData.ReloadKeys) then
			Combat.CurrentWeapon.reload()
		end
	end)
	Input.InputEnded:Connect(function(io)
		if not Combat.WeaponData or not Combat.WeaponData.AimKeys then
			return
		end
		if Input.MatchKey(io, Combat.WeaponData.AimKeys) then
			Combat.CurrentWeapon.setaim(false)
		end
		if Input.MatchKey(io, Combat.WeaponData.AttackKeys) then
			Combat.CurrentWeapon.firing = false
		end
	end)
	end
do
	local Assets = game.ReplicatedStorage:WaitForChild("Assets")
	local FootstepFolder = Assets:FindFirstChild("Footsteps")--[[
	Network:add("playfootstepsound", function(parent, volume, material)
		local soundfolder = FootstepFolder:FindFirstChild(material)
		if soundfolder and #soundfolder:GetChildren() > 0 then
			local randsound = soundfolder[math.random(1, #soundfolder:GetChildren())]
			if randsound then
				local s = randsound:Clone()
				s.Parent = parent
				s.Volume = volume
				s.PlayOnRemove = true
				s:Destroy()
			end
		end
	end)--]]
	
	Remote.OnClientEvent:Connect(function(muzzle, player, hitpart)
		if player ~= game.Players.LocalPlayer then
			ReplicateBeam(muzzle, player, hitpart)
		end
	end)
	
	--[[ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RotateBody").OnClientEvent:Connect(function(TargPlayer, TargCharWaistC1, TargAngles, TargY, TargCharOriginWaistC1, TargAimSpringP)
		TargCharWaistC1 = TargCharWaistC1:lerp(TargAngles(TargY, 0, 0) * TargCharOriginWaistC1, TargAimSpringP)
	end)]]--
	
	local neckposes = {}
	local waistposes = {}
	local function UpdateCharHead(neck, neckc0, waist, waistc0)
		local rate = 0.2
		if not neck or not waist then
			return
		end
		neckposes[neck] = neckc0
		waistposes[waist] = waistc0
    end

	function Replication.Step()
		for i, v in pairs(neckposes) do
			if v ~= nil and i ~= nil then
				i.C0 = i.C0:lerp(v, 0.2)
			end
		end
		for i, v in pairs(waistposes) do
			if v ~= nil and i ~= nil then
				i.C0 = i.C0:lerp(v, 0.2)
			end
		end
	end
end
do
	local rs = game:GetService("RunService")
		local rsfuncs = {
		Camera.Step,
		Char.Step,
		Input.Step,
		Combat.Step,
		Replication.Step,
		Environment.Step
	}
	local hbfuncs = {
		Camera.HStep,
	}
	rs.RenderStepped:Connect(function(dt)
		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		for i, v in pairs(rsfuncs) do
			if v then
				v(dt)
			end
		end
		for i, v in pairs(hbfuncs) do
			if v then
				v(dt)
			end
		end
	end)

	local stfuncs = {
		--Char.Stepped
	}
end
