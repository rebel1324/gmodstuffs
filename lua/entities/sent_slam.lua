
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "SLAM"
ENT.Author = "Black Tea"
ENT.Information = "SLAM"
ENT.Category = "Weapons"

ENT.Editable = true
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end

	local size = math.random( 16, 48 )

	local ent = ents.Create( ClassName )
	ent:Spawn()
	ent:Activate()


	local nAngle = (tr.HitNormal * -1):Angle()

	nAngle:RotateAroundAxis(nAngle:Right(), 90)

	ent:SetPos(tr.HitPos + tr.HitNormal * 5)
	ent:SetAngles(nAngle)
	ent:SetMoveType(MOVETYPE_NONE)
	ent.activated = true

	ent:EmitSound("weapons/slam/mine_mode.wav")

	if (tr.HitEntity and tr.HitEntity:GetClass() != "worldspawn") then
		ent:SetParent(tr.HitEntity)
	end

	timer.Simple(0.5, function()
		if (ent and ent:IsValid()) then
			ent:EmitSound("HL1/fvox/beep.wav", 100, 200)

			ent:SetDTBool(0, true)
		end
	end)

	local physObj = ent:GetPhysicsObject()
	if (IsValid(physObj)) then
		physObj:Sleep()
		physObj:EnableMotion(false)
	end

	return ent
end

function ENT:Initialize()
	if ( CLIENT ) then return end

	self:SetModel( "models/weapons/w_slam.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetBodygroup(0, 1)
	self.health = 15

	local physObj = self:GetPhysicsObject()
	if (IsValid(physObj)) then
		physObj:Wake()
	end
end


local BounceSound = Sound( "garrysmod/balloon_pop_cute.wav" )
function ENT:PhysicsCollide( data, physobj )
	if (self.activated) then return end

	local nAngle = data.HitNormal:Angle()

	nAngle:RotateAroundAxis(nAngle:Right(), 90)

	self:SetPos(data.HitPos - data.HitNormal * 5)
	self:SetAngles(nAngle)
	self:SetMoveType(MOVETYPE_NONE)
	self.activated = true

	self:EmitSound("weapons/slam/mine_mode.wav")

	if (data.HitEntity and data.HitEntity:GetClass() != "worldspawn") then
		self:SetParent(data.HitEntity)
	end

	timer.Simple(0.5, function()
		if (self and self:IsValid()) then
			self:EmitSound("HL1/fvox/beep.wav", 100, 200)
			self:SetDTBool(0, true)
		end
	end)

	local physObj = self:GetPhysicsObject()
	if (IsValid(physObj)) then
		physObj:Sleep()
		physObj:EnableMotion(false)
	end
end

function ENT:Explode()
	local effectData = EffectData()
	effectData:SetStart(self:GetPos())
	effectData:SetOrigin(self:GetPos())
	util.Effect("Explosion", effectData, true, true)
	
	util.BlastDamage(self, self, self:GetPos() + Vector( 0, 0, 1 ), 256, 120 )

	self:Remove()
end

if (SERVER) then
	timer.Create("slamTime", .5, 0, function()
		for k, v in ipairs(ents.GetAll()) do
			if (v:IsNPC() or v:IsPlayer()) then
				for _, slam in ipairs(ents.FindByClass("sent_slam")) do
					if (slam:GetDTBool(0)) then
						local dist = v:GetPos():Distance(slam:GetPos())

						if (dist < 128) then
							slam:Explode()
						end
					end
				end
			end
		end
	end)
end

--[[---------------------------------------------------------
	Name: OnTakeDamage
-----------------------------------------------------------]]
function ENT:OnTakeDamage( dmginfo )
	if (self.explode == true) then return end
	self.explode = true

	if (dmginfo:GetInflictor() != self) then
		self:Explode()
	end
end

--[[---------------------------------------------------------
	Name: Use
-----------------------------------------------------------]]
function ENT:Use( activator, caller )
end

if ( SERVER ) then return end -- We do NOT want to execute anything below in this FILE on SERVER

function ENT:Initialize()
	self.wow = math.Rand(1, -1)
end

local GLOW_MATERIAL = Material("sprites/glow04_noz.vmt")
function ENT:Draw()
	self:SetModelScale(2,0)
	self:DrawModel()

	local pos = self:GetPos()
	pos = pos + self:GetForward() * -4
	pos = pos + self:GetRight() * -3
	pos = pos + self:GetUp() * 1

	render.SetMaterial(GLOW_MATERIAL)
	local beep = math.max(math.sin(RealTime()*20 + self.wow), 0) * 16

	if (self:GetDTBool(0)) then
		render.DrawSprite(pos, 0 + beep, 0 + beep, Color( 255, 44, 44, 255 ) )
	end
end
