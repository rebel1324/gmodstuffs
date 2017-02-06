
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
	ent:SetPos( tr.HitPos + tr.HitNormal * size )
	ent:SetBallSize( size )
	ent:Spawn()
	ent:Activate()

	return ent

end

--[[---------------------------------------------------------
	Name: Initialize
-----------------------------------------------------------]]
function ENT:Initialize()
	-- We do NOT want to execute anything below in this FUNCTION on CLIENT
	if ( CLIENT ) then return end

	-- Use the helibomb model just for the shadow (because it's about the same size)
	self:SetModel( "models/weapons/w_slam.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetBodygroup(0, 1)

	local physObj = self:GetPhysicsObject()
	if (IsValid(physObj)) then
		physObj:Wake()
	end
end


local BounceSound = Sound( "garrysmod/balloon_pop_cute.wav" )
function ENT:PhysicsCollide( data, physobj )
	local nAngle = data.HitNormal:Angle()

	nAngle:RotateAroundAxis(nAngle:Right(), 90)

	self:SetPos(data.HitPos - data.HitNormal * 5)
	self:SetAngles(nAngle)

	self:EmitSound("weapons/slam/mine_mode.wav")
	PrintTable(data)
	if (data.HitEntity and data.HitEntity:GetClass() != "worldspawn") then
		self:SetParent(data.HitEntity)
	end

	timer.Simple(0.5, function()
		if (self and self:IsValid()) then
			self:EmitSound("HL1/fvox/beep.wav", 100, 200)
		end

		self:SetDTBool(0, true)
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
	timer.Create("slamTime", .4, 0, function()
		for k, v in ipairs(ents.GetAll()) do
			if (v:IsNPC()) then
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
	-- React physically when shot/getting blown
	self:TakePhysicsDamage( dmginfo )
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
