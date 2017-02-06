AddCSLuaFile()

if( CLIENT ) then
	SWEP.PrintName = "Ammo Supply";
	SWEP.Slot = 0;
	SWEP.SlotPos = 0;
	SWEP.CLMode = 0
end

SWEP.HoldType = "fists"

SWEP.Category = "Co-op"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"

SWEP.ViewModelFOV	= 55
SWEP.Primary.Delay			= 1
SWEP.Primary.Recoil			= 0	
SWEP.Primary.Damage			= 0
SWEP.Primary.NumShots		= 0
SWEP.Primary.Cone			= 0 	
SWEP.Primary.ClipSize		= -1	
SWEP.Primary.DefaultClip	= -1	
SWEP.Primary.Automatic   	= false	
SWEP.Primary.Ammo         	= "none"
 
SWEP.Secondary.Delay		= 0.9
SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= 0
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

function SWEP:Initialize()
	self:SetWeaponHoldType("slam")
end

function SWEP:Think()
end

local gridsize = .5

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_SLAM_THROW_ND_DRAW)
end

function SWEP:PrimaryAttack()

		self:SendWeaponAnim(ACT_SLAM_THROW_THROW_ND)
		self:SetNextPrimaryFire(CurTime() + 1.6)

	timer.Simple(.5, function()
		self:SendWeaponAnim(ACT_SLAM_THROW_THROW_ND2)
		self:EmitSound("weapons/slam/throw.wav")

		timer.Simple(.1, function()
			self:SendWeaponAnim(ACT_SLAM_THROW_ND_DRAW)
		end)

		if (SERVER) then
			local e = ents.Create("sent_slam")
			e:SetPos(self.Owner:EyePos())
			e:SetAngles(AngleRand())
			e:Spawn()
			e.owner = self.Owner 
			
			local phys = e:GetPhysicsObject()
			phys:SetVelocity(self.Owner:GetAimVector()*phys:GetMass()*600)
			phys:AddAngleVelocity(VectorRand()*1000)

			timer.Simple(30, function()
				if e:IsValid() then
					e:Remove()
				end
			end)
		end
	end)
end

function SWEP:SecondaryAttack()
end
