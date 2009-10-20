TOOL.Category		= "Wire - Physics"
TOOL.Name			= "Piston"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "model" ] = "models/burak575/piston20.mdl"
TOOL.ClientConVar[ "length" ] = "20" -- cylinder length
TOOL.ClientConVar[ "sound" ] = "" -- piston sound
TOOL.ClientConVar[ "multiplier" ] = "" -- force multiplier
TOOL.ClientConVar[ "fx" ] = "" -- effects


if CLIENT then
    language.Add( "Tool_wire_piston_name", "Piston Tool (Wire)" )
    language.Add( "Tool_wire_piston_desc", "Makes a controllable piston" )
    language.Add( "Tool_wire_piston_0", "Primary: Place piston / Secondary: Connect to axle (if known axle model)" )
    language.Add( "WirePistonTool_model", "Model:" )
    language.Add( "WirePistonTool_length", "Cylinder Length:" )
	language.Add( "WirePistonTool_multiplier", "Force Multiplier:" )
	language.Add( "WirePistonTool_sound", "Sound Effect:" )
	language.Add( "WirePistonTool_fx", "Combustion Effect" )
	language.Add( "undone_wirepiston", "Undone Wire Piston" )
end

if SERVER then
	CreateConVar('sbox_maxwire_pistons', 25)
end

--[[
function GetPlayerPos()
	local mypos = LocalPlayer():GetPos()
	print("Player position: " .. mypos.x .. " - " .. mypos.y .. " - " .. mypos.z)
end
concommand.Add("GetPlayerPosition" , GetPlayerPos)
--]]

local function CreateSliderByTrace(fromtrace, totrace, offset)
	local Phys1 = fromtrace.Entity:GetPhysicsObject()
	local Phys2 = totrace.Entity:GetPhysicsObject()
	
	local Ent1,  Ent2  = fromtrace.Entity,	 	totrace.Entity
	local Bone1, Bone2 = fromtrace.PhysicsBone,	totrace.PhysicsBone
	local LPos1, LPos2 = Phys1:WorldToLocal(fromtrace.HitPos + offset) ,	Phys2:WorldToLocal(totrace.HitPos + offset)
	
	local ctr,rope = constraint.Slider( Ent1, Ent2, Bone1, Bone2, LPos1, LPos2, 0.5 )
	
	return ctr,rope
end

local function CreateRopeByTrace(fromtrace, totrace,length)
	local Phys1 = fromtrace.Entity:GetPhysicsObject()
	local Phys2 = totrace.Entity:GetPhysicsObject()
	
	local Ent1,  Ent2  = fromtrace.Entity,	 	totrace.Entity
	local Bone1, Bone2 = fromtrace.PhysicsBone,	totrace.PhysicsBone
	local LPos1, LPos2 = Phys1:WorldToLocal(fromtrace.HitPos) ,	Phys2:WorldToLocal(totrace.HitPos)
	
	local ctr,rope = constraint.Rope( Ent1, Ent2, Bone1, Bone2, LPos1, LPos2, length, 0, 0, 1, "cable/blue", false )
	
	return ctr,rope
end

function TOOL:Reload( trace )
	
end

function TOOL:LeftClick( trace )
	if ( trace.Entity:IsValid() && trace.Entity:IsPlayer() ) then return end
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	local ply = self:GetOwner()
	
	local force 		= self:GetClientNumber( "multiplier" )
	local sound 		= self:GetClientInfo( "sound" )
	local length 	= self:GetClientNumber( "length" )
	local model 		= self:GetClientInfo( "model" )
	local fx = self:GetClientInfo( "fx" )
	
	--print ( "Piston tool: " .. trace.Entity:GetClass() .. " - " .. tostring(trace.Entity.pl) )
	if trace.Entity:IsValid() and trace.Entity:GetClass() == "gmod_wire_piston" and trace.Entity.pl == ply then
		trace.Entity:Setup(force,length,sound,fx)
		--[[ trace.Entity:SetSound( sound )
		trace.Entity:SetCylLength( cylength )
		trace.Entity:SetForce( force ) --]]
		return true
	end
	
	if not self:GetSWEP():CheckLimit( "wire_pistons" ) then return false end
	
	print("Creating Piston...")
	
	--local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	--self:SetObject( 1, trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal )
	
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	
	local piston = MakeWirePiston(ply, trace.HitPos + (trace.HitNormal * 5), Ang, model,force,sound,length,fx)
	
	local pistonphys = piston:GetPhysicsObject()
	pistonphys:EnableMotion(false)
	
	piston:SetMotorBlock(trace.Entity)
	piston:SetCylinderHeadPos( trace.Entity:WorldToLocal(trace.HitPos) )	
	
	local tr = {}
	tr.start = trace.HitPos
	tr.endpos = tr.start + (trace.HitNormal * 10)
	tr.filter = {} 
	tr.filter[1] = self:GetOwner()
	if (trace.Entity:IsValid()) then
		tr.filter[2] = trace.Entity
	end
	
	local tr = util.TraceLine( tr )
	if ( !tr.Hit ) then
		piston:Remove()
		print("Piston placement failed")
		return
	end
	
	-- up, front , right , back , left
	local tracepoints = { Vector ( 0 , 2 , 0 ), Vector(0 , -2 , 0) }
	local rang = trace.HitNormal:Angle()
	local rotatedpoints = {}
	
	for _, pnt in pairs(tracepoints) do
		local rpnt = pnt
		rpnt:Rotate(rang)
		table.insert(rotatedpoints, rpnt)
	end
	
	--PrintTable(traces)
	
	local cs1,cr1 = CreateSliderByTrace(trace,tr,rotatedpoints[1])
	local cs2,cr2 = CreateSliderByTrace(trace,tr,rotatedpoints[2])
	--local cs3,cr3 = CreateSliderByTrace(tr,trace,rotatedpoints[3],rotatedpoints[3])
	--local cs4,cr4 = CreateSliderByTrace(tr,trace,rotatedpoints[4],rotatedpoints[4])
	local cs5,cr5 = CreateRopeByTrace(tr,trace,length)
	
	piston:SetPos(trace.HitPos)
	
	undo.Create( "wirepiston" )
		undo.AddEntity( cs1 )
		if cr1 then undo.AddEntity( cr1 ) end
		
		undo.AddEntity( cs2 )
		if cr2 then undo.AddEntity( cr2 ) end
		
		--[[undo.AddEntity( cs3 )
		if cr3 then undo.AddEntity( cr3 ) end
		
		undo.AddEntity( cs4 )
		if cr4 then undo.AddEntity( cr4 ) end --]]
		
		undo.AddEntity( cs5 )
		if cr5 then undo.AddEntity( cr5 ) end
		
		undo.AddEntity( piston )
		--undo.AddEntity( const )
		undo.SetPlayer( self:GetOwner() )
	undo.Finish()
	
	--pistonphys:EnableMotion(true)

	
	return true
end


function TOOL:UpdateGhostPiston( ent, player )

	if ( !ent || !ent:IsValid() ) then return end

	local tr 	= utilx.GetPlayerTrace( player, player:GetCursorAimVector() )
	local trace 	= util.TraceLine( tr )
	
	if (!trace.Hit || trace.Entity:IsPlayer() || trace.Entity:GetClass() == "gmod_wire_piston" ) then
		ent:SetNoDraw( true )
		return
	end
	
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local min = ent:OBBMins()
	ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
	ent:SetAngles( Ang )
	
	--[[local tracepoints = { Vector ( 0 , 0 , 2 ) , Vector ( 2 , 0 , 0 ), Vector( 0 , 2 , 0) , Vector (-2,0,0) , Vector (0,-2,0) }
	local rang = trace.HitNormal:Angle()
	
	ent:ClearBeams()
	for _, pnt in pairs(tracepoints) do
		local rpnt = pnt
		rpnt:Rotate(rang)
		
		--print("rang: " .. tostring(rang) .. " - rpnt: " .. tostring(rpnt))
		ent:AddBeam( trace.HitPos, trace.HitPos + rpnt )
	end --]]
	
	ent:SetNoDraw( false )
end


function TOOL:Think()
	if (!self.GhostEntity || !self.GhostEntity:IsValid() ) then
		self:MakeGhostEntity( self:GetClientInfo( "model" ), Vector(0,0,0), Angle(0,0,0) )
	end
	
	self:UpdateGhostPiston( self.GhostEntity, self:GetOwner() )
end



function TOOL.BuildCPanel(panel)

	--WireDermaExts.ModelSelect(panel, "wire_piston_model", Pistons, 1, true)
	
	panel:AddControl( "PropSelect", {
		Label = "#WirePistonTool_model",
		ConVar = "wire_piston_model",
		Category = "WirePistons",
		Models = list.Get( "Pistons" ) } )
		
	panel:NumSlider("#WirePistonTool_multiplier", "wire_piston_multiplier", 1, 10000, 0)
	panel:NumSlider("#WirePistonTool_length", "wire_piston_length", 1, 200, 0)
	
	local weaponSounds = {Label = "#WirePistonTool_sound", MenuButton = 0, Options={}, CVars = {}}
	weaponSounds["Options"]["#No Weapon"]	= { wire_piston_sound = "" }
	weaponSounds["Options"]["#Pistol"]		= { wire_piston_sound = "Weapon_Pistol.Single" }
	weaponSounds["Options"]["#SMG"]			= { wire_piston_sound = "Weapon_SMG1.Single" }
	weaponSounds["Options"]["#AR2"]			= { wire_piston_sound = "Weapon_AR2.Single" }
	weaponSounds["Options"]["#Shotgun"]		= { wire_piston_sound = "Weapon_Shotgun.Single" }
	weaponSounds["Options"]["#Floor Turret"]	= { wire_piston_sound = "NPC_FloorTurret.Shoot" }
	weaponSounds["Options"]["#Airboat Heavy"]	= { wire_piston_sound = "Airboat.FireGunHeavy" }
	weaponSounds["Options"]["#Zap"]	= { wire_piston_sound = "ambient.electrical_zap_3" }
	weaponSounds["Options"]["Thruster"] = { wire_piston_sound = "PhysicsCannister.ThrusterLoop" }
		
	panel:AddControl("ComboBox", weaponSounds )
	
	panel:AddControl( "Checkbox", { Label = "#WirePistonTool_fx", Command = "wire_piston_fx" } )
	
	--[[	
	panel:AddControl( "PropSelect", {
		Label = "#WirePistonTool_model",
		ConVar = "wire_piston_model",
		Category = "WirePistons",
		Models = list.Get( "Pistons" ) } )


	
	panel:AddControl("CheckBox", {
		Label = "#XQMWireHydraulicTool_fixed",
		Command = "xqm_wire_hydraulic_fixed"
	})

	panel:AddControl("Slider", {
		Label = "#XQMWireHydraulicTool_width",
		Type = "Float",
		Min = "1",
		Max = "20",
		Command = "xqm_wire_hydraulic_width"
	})	
	
	panel:AddControl("MaterialGallery", {
		Label = "#XQMWireHydraulicTool_material",
		Height = "64",
		Width = "28",
		Rows = "1",
		Stretch = "1",

		Options = {
			["Wire"] = { Material = "cable/rope_icon", xqm_wire_hydraulic_material = "cable/rope" },
			["Cable 2"] = { Material = "cable/cable_icon", xqm_wire_hydraulic_material = "cable/cable2" },
			["XBeam"] = { Material = "cable/xbeam", xqm_wire_hydraulic_material = "cable/xbeam" },
			["Red Laser"] = { Material = "cable/redlaser", xqm_wire_hydraulic_material = "cable/redlaser" },
			["Blue Electric"] = { Material = "cable/blue_elec", xqm_wire_hydraulic_material = "cable/blue_elec" },
			["Physics Beam"] = { Material = "cable/physbeam", xqm_wire_hydraulic_material = "cable/physbeam" },
			["Hydra"] = { Material = "cable/hydra", xqm_wire_hydraulic_material = "cable/hydra" },
		},

		CVars = {
			[0] = "xqm_wire_hydraulic_material"
		}
	})
	
	--]]
	
end



list.Set( "Pistons", "models/burak575/piston20.mdl", {} )