TOOL.Category		= "Wire - Physics"
TOOL.Name			= "Piston"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "model" ] = "models/burak575/piston20.mdl"
TOOL.ClientConVar[ "length" ] = "20" -- cylinder length
TOOL.ClientConVar[ "sound" ] = "" -- piston sound
TOOL.ClientConVar[ "multiplier" ] = "" -- force multiplier
TOOL.ClientConVar[ "fx" ] = "" -- effects
TOOL.ClientConVar[ "invisconst" ] = "" -- invisible constraint

if ( SERVER ) then
	CreateConVar('sbox_maxwire_pistons', 25)
	
	-- The idea comes from Wire Hydroaulics
	function MakeWirePiston( ply, Pos, Ang, model, force, sound, length,fx )
		if not ply:CheckLimit( "wire_pistons" ) then return nil end
	
		local piston = ents.Create( "gmod_wire_piston" )
		if not piston:IsValid() then return false end
		
		piston:SetPos( Pos )
		piston:SetAngles( Ang )
		
		piston:SetModel( model )
		
		piston:Spawn()
		
		piston:Setup(force,length,sound,fx)
		piston:SetPlayer( ply )
		
		
		-- Defaulty No Collide It
		piston:GetPhysicsObject():EnableCollisions( false ) -- Is it true to put this here? or should i put it to LeftClick function? When they duplicated...
		piston:GetPhysicsObject():EnableMotion(false) -- Is it true to put this here? or should i put it to LeftClick function? When they duplicated...
		
		local ttable = {
			pl			= ply,
			force		= force,
			sound		= sound,
			length		= length,
			fx			= fx
		}
		table.Merge( piston:GetTable(), ttable )
		
		return piston
	end
	
	duplicator.RegisterEntityClass( "gmod_wire_piston", MakeWirePiston, "Pos", "Ang", "Model", "force", "sound", "length","fx" )
	
	function MakeWirePistonConstFromTable( ct )
		return MakeWirePistonConstraint( ct["pl"] , ct["Ent1"],ct["Ent2"],ct["Bone1"],ct["Bone2"],ct["LPos1"],ct["LPos2"],ct["Invis"],ct["Length"])
	end
	
	function MakeWirePistonConstraint( pl, Piston, Block, Bone1,Bone2, LPos1, LPos2, Invis, Length )
		if ( !constraint.CanConstrain( Piston, Bone1 ) ) then return false end
		if ( !constraint.CanConstrain( Block, Bone2 ) ) then return false end
		
		local Phys1 = Piston:GetPhysicsObjectNum( Bone1 )
		local Phys2 = Block:GetPhysicsObjectNum( Bone2 )
		local WPos1 = Phys1:LocalToWorld( LPos1 )
		local WPos2 = Phys2:LocalToWorld( LPos2 )
		
		if ( Phys1 == Phys2 ) then return false end
		
		local ropesize = 1.0
		if (Invis == 1 ) then ropesize = 0 end
				
		local const,rope = constraint.Rope( Piston, Block, Bone1, Bone2, LPos1, LPos2, Length, 0, 0, ropesize, "cable/blue", false )	
		if ( !const ) then return nil, rope end
		
		local sli,srope = constraint.Slider( Piston, Block, Bone1, Bone2, LPos1, LPos2, ropesize )
		sli:SetTable( {} ) -- wtf is that? possibly avoid from duping it?
		
		
		local ctable = {
			Type     = "WirePistonConst",
			pl       = pl,
			Ent1   	 = Piston,
			Ent2     = Block,
			Bone1    = Bone1,
			Bone2    = Bone2,
			LPos1    = LPos1,
			LPos2    = LPos2,
			Invis    = Invis,
			Length 	 = Length
		}
		const:SetTable( ctable )
		
		Piston.const = const
		Piston.constrope = rope
		Piston.slider = sli
		Piston.slirope = srope
		--Piston.MBlock = Block
		
		Piston:SetMotorBlock(Block)
		Piston:SetCylinderHeadPos( LPos2 )
		
		Piston:DeleteOnRemove( const )
		Piston:DeleteOnRemove( sli )
		
		--[[print( "Const: " .. tostring(const))
		print( "Sli: " .. tostring( sli))
		print( "SRope: " .. tostring(srope))
		print( "Rope: " .. tostring(rope))
		
		if ( rope ) then rope:Fire("SetLength", Length + 100, 0) end
		if ( srope ) then srope:Fire("SetLength", Length + 100, 0) end
		if ( sli ) then sli:Fire("SetLength", Length + 100, 0) end
		if ( const ) then const:Fire("SetLength", Length + 100, 0) end]]-- MMh it doesnt changes the real Length Limit... only visual rope...
		
		if ( rope ) then Piston:DeleteOnRemove( rope )end
		if ( srope ) then Piston:DeleteOnRemove( srope ) end
		
		if ( const ) then
			if sli then const:DeleteOnRemove( sli ) end
			if srope then const:DeleteOnRemove( srope ) end
			if rope then const:DeleteOnRemove( rope ) end
		end
		
		Block:DeleteOnRemove( Piston )
		
		
		--const:DeleteOnRemove( Piston )
		--sli:DeleteOnRemove( Piston )
		
		return const, rope
	end
	
	duplicator.RegisterConstraint( "WirePistonConst", MakeWirePistonConstraint, "pl", "Ent1", "Ent2", "Bone1", "Bone2", "LPos1", "LPos2", "Invis", "Length" )	
end

if CLIENT then
    language.Add( "Tool_wire_piston_name", "Piston Tool (Wire)" )
    language.Add( "Tool_wire_piston_desc", "Makes a controllable piston" )
    language.Add( "Tool_wire_piston_0", "Primary: Place piston, Reload: Change all piston paramaters that in hull of target prop" )
    language.Add( "WirePistonTool_model", "Model:" )
    language.Add( "WirePistonTool_length", "Cylinder Length:" )
	language.Add( "WirePistonTool_multiplier", "Force Multiplier:" )
	language.Add( "WirePistonTool_sound", "Sound Effect:" )
	language.Add( "WirePistonTool_fx", "Combustion Effect" )
	language.Add( "WirePistonTool_invisconst", "Invisible Constraints" )
	
	language.Add( "undone_wirepiston", "Undone Wire Piston" )
end


--[[
function GetPlayerPos()
	local mypos = LocalPlayer():GetPos()
	print("Player position: " .. mypos.x .. " - " .. mypos.y .. " - " .. mypos.z)
end
concommand.Add("GetPlayerPosition" , GetPlayerPos)
--]]


function TOOL:Reload( trace )
	if ( trace.Entity:IsValid() && trace.Entity:IsPlayer() ) then return end
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	local ply = self:GetOwner()
	
	local force 		= self:GetClientNumber( "multiplier" )
	local sound 		= self:GetClientInfo( "sound" )
	local length 	= self:GetClientNumber( "length" )
	local model 		= self:GetClientInfo( "model" )
	local fx = self:GetClientInfo( "fx" )
	local invisconst = self:GetClientNumber( "invisconst" )
	
	if trace.Entity:IsValid() then
		
		--trace.Entity:Setup(force,length,sound,fx)
		local blockmin = trace.Entity:LocalToWorld(trace.Entity:OBBMins())
		local blockmax = trace.Entity:LocalToWorld(trace.Entity:OBBMaxs())
		local updatedpistons = 0
		
		local pistonsents = ents.FindInBox( blockmin, blockmax )
		
		for _,ent in pairs(pistonsents) do
			if ent:IsValid() and ent:GetClass() == "gmod_wire_piston" and ent.pl == ply then
				ent:Setup(force,length,sound,fx)
				updatedpistons = updatedpistons + 1
			end
		end
		
		--print ( updatedpistons .. " piston parameters changed" )
		--GM:AddNotify("Obey the rules.", NOTIFY_GENERIC, 5);
		WireLib.AddNotify(ply,  updatedpistons .. " pistons updated", NOTIFY_HINT, 4 )
		return true
	end
	
end

function TOOL:RightClick( trace )
	if ( !trace.Entity || !trace.Entity:IsValid() || trace.Entity:IsPlayer() ||trace.Entity.IsWorld() ) then return false end
	-- should print relative hit pos
	--local hpos = trace.HitPos			-- hit position
	--local epos = trace.Entity:GetPos()	-- entity position
	--local rpos = epos - hpos	-- result position
	local rpos = trace.Entity:WorldToLocal( trace.HitPos )
	constraint.RemoveConstraints( trace.Entity, "WirePistonConst" )
	print( tostring(rpos) .. " Bone:" .. tostring(trace.PhysicsBone) )
end

function TOOL:GetAttachPosForModel( enti )
	local mdls = list.GetForEdit("Pistons")
	
	
	local mdlData = mdls[ enti:GetModel() ]
	
	-- Debug functions
	--print( "Entity:" .. tostring(enti) )
	--print( "Mdl Table:" .. table.ToString(mdls,"models",false) )
	--print( "Mdl Name:" .. tostring(enti:GetModel()) )
	--print( "Mdl Data:" .. table.ToString(mdlData,"mdl data",false) )
	
	if ( !mdlData ) then mdlData = { Flags = "cZ" } end
	
	--print( "Mdl Data After:" .. table.ToString(mdlData,"mdl data",false) )
	local mdlFlags = mdlData["Flags"]
	
	local center, axis
	
	if ( mdlFlags:find ( "c" ) > 0 ) then
		center = true
		--print("Center flag set!")
	end
	
	if (mdlFlags:find ( "Z" ) > 0 ) then
		axis = "z"
		--print("Z axis set!")
	end
	
	local obMax = enti:OBBMaxs()
	local obMin = enti:OBBMins()
	
	if (center) then
		if ( axis == "z") then
			if ( enti:GetReversed() ) then
				return Vector( 0, 0, obMax.z )
			else
				return Vector( 0 , 0 , obMin.z )
			end
		end

		if ( axis == "x") then
			if ( enti:GetReversed() ) then
				return Vector( obMax.x, 0, 0)
			else
				return Vector( obMin.x , 0 , 0 )
			end
		end

		if ( axis == "y") then
			if ( enti:GetReversed() ) then
				return Vector( 0, obMax.y, 0)
			else
				return Vector( 0 , obMin.y , 0 )
			end
		end
	end
	
	

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
	local invisconst = self:GetClientNumber( "invisconst" )
	
	--print ( "Piston tool: " .. trace.Entity:GetClass() .. " - " .. tostring(trace.Entity.pl) )
	if trace.Entity:IsValid() and trace.Entity:GetClass() == "gmod_wire_piston" and trace.Entity.pl == ply then
		trace.Entity:Setup(force,length,sound,fx)
		--[[ trace.Entity:SetSound( sound )
		trace.Entity:SetCylLength( cylength )
		trace.Entity:SetForce( force ) --]]
		return true
	end
	
	if not ply:CheckLimit( "wire_pistons" ) then return false end
	
	print("Creating Piston...")
	
	--local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	--self:SetObject( 1, trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal )
	
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	
	-- HERE COMES DIRTY FIX FOR SPAZZING SLIDER
	local bUp = trace.Entity:GetUp() -- motor block up vector
	local pUp = trace.HitNormal * -1 -- piston up vector
	local dUp = bUp:Distance(pUp) -- distance between them	
	
	--print( "Block Up: " .. tostring(bUp) .. "  Piston Up: " .. tostring(pUp) .. " Dist:" .. dUp  )	
	
	local shouldfix = false
	
	if (dUp < 0.10) then
		shouldfix = true
		Ang.pitch = Ang.pitch - 180
		print("Piston reversed!!! (for fixing slider spazz)")
	end
	
	local piston = MakeWirePiston(ply, trace.HitPos + (trace.HitNormal * 10), Ang, model,force,sound,length,fx)
	
	if !piston:IsValid() then
		print "Piston creation failed!"
		return
	end
	piston:SetReversed(shouldfix)
	
	local Block = trace.Entity
	local BonePiston = 0
	local BoneBlock = trace.PhysicsBone
	local LPosPiston = self:GetAttachPosForModel( piston )
	local LPosBlock = Block:GetPhysicsObject():WorldToLocal(trace.HitPos)
	
	--print( tostring(LPosPiston) .. " <- piston attach position" )
	
	
	local const,rope = MakeWirePistonConstraint( ply , piston, Block, BonePiston, BoneBlock, LPosPiston, LPosBlock, invisconst, length )

	if ( shouldfix ) then
		local max = piston:OBBMaxs()
		piston:SetPos( trace.HitPos + trace.HitNormal * max.z )
	else
		local min = piston:OBBMins()
		piston:SetPos( trace.HitPos - trace.HitNormal * min.z )
	end

	
	undo.Create( "wirepiston" )
		if const then undo.AddEntity( const ) end
		if rope then undo.AddEntity( rope) end
		if piston then undo.AddEntity( piston) end
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
	panel:AddControl( "Checkbox", { Label = "#WirePistonTool_invisconst", Command = "wire_piston_invisconst" } )
	
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



list.Set( "Pistons", "models/burak575/piston20.mdl", { Flags = "cZ" } ) -- Center And Z is the axis