class RainbowShockProjectile extends Projectile 
    placeable;

var() Sound ComboSound;
var() float ComboDamage;
var() float ComboRadius;
var() float ComboMomentumTransfer;
var RainbowShockBall ShockBallEffect;
var() int ComboAmmoCost;
var class<DamageType> ComboDamageType;
var byte ReflectMaxNum, ReflectNum;
var float DampeningFactor, NewDamage;
var Pawn ComboTarget;
var Vector tempStartLoc;

replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
    ReflectNum;
}

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();

    if( Pawn(Owner) != None )
    {
        Instigator = Pawn( Owner );
	}
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer )
	{
        ShockBallEffect = Spawn(Class'mm_RainbowShockRifle.RainbowShockBall', self);
        ShockBallEffect.SetBase(self);
	}

    SetTimer(0.4, false);
    tempStartLoc = Location;

    Velocity = Speed * Vector(Rotation);
}

simulated function PostNetBeginPlay()
{
	local PlayerController PC;

	Super.PostNetBeginPlay();

	if ( Level.NetMode == NM_DedicatedServer )
	{
		return;
	}

	PC = Level.GetLocalPlayerController();
	if ( (Instigator != None) && (PC == Instigator.Controller) )
	{
		return;
	}
	if ( Level.bDropDetail || (Level.DetailMode == DM_Low) )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
	else if ( (PC == None) || (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 3000) )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
}

function Timer()
{
    SetCollisionSize(20, 20);
}

simulated function Destroyed()
{
    if (ShockBallEffect != None)
    {
		if ( bNoFX )
		{
			ShockBallEffect.Destroy();
		}
		else
		{
			ShockBallEffect.Kill();
		}
	}

	Super.Destroyed();
}

simulated function DestroyTrails()
{
    if (ShockBallEffect != None)
    {
        ShockBallEffect.Destroy();
	}
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
    if ( ReflectNum != 0 && Other == Instigator )
    {
		Explode(HitLocation, Normal(HitLocation-Other.Location));
	}
    else
    {
		Super.ProcessTouch(Other, HitLocation);
	}
}

simulated function HitWall( vector HitNormal, actor Wall )
{
    if ( !Wall.bStatic && !Wall.bWorldGeometry && ((Mover(Wall) == None) || Mover(Wall).bDamageTriggered) )
    {
        if ( Level.NetMode != NM_Client )
		{
	    	SetNewDamage();
            if ( Instigator == None || Instigator.Controller == None )
            {
		  		Wall.SetDelayedDamageInstigatorController( InstigatorController );
			}
            Wall.TakeDamage( NewDamage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
		}
        DestroyProjectile();
        return;
    }

    DoImpactEffects();
    if (ReflectNum < ReflectMaxNum)
    {
        BounceProjectile(HitNormal);
        return;
    }
    DestroyProjectile();
}

Simulated Function BounceProjectile(vector HitNormal)
{
    Const V_Absorbed = 0.80;
    local float V_Returned;

    V_Returned = 1 - V_Absorbed;

    Velocity = Normal( MirrorVectorByNormal(Velocity,HitNormal) ) * (VSize(Velocity) * V_Returned + V_Absorbed * VSize(Velocity) * (0.5 + 0.5 * (normal(velocity) dot hitnormal)));
    Acceleration = Normal(Velocity) * 1500.0;
    ReflectNum++;
}

Simulated Function DoImpactEffects()
{
    SetNewDamage();
    if ( Role == ROLE_Authority )
    {
		HurtRadius(NewDamage, DamageRadius, MyDamageType, MomentumTransfer, Location );
	}
    PlaySound(ImpactSound, SLOT_Misc);
    if ( EffectIsRelevant(Location,false) )
    {
    	Spawn(Class'mm_RainbowShockRifle.RainbowShockExplosionCore',,, Location);
	}
	if(!Level.bDropDetail && (Level.DetailMode != DM_Low))
	{
	    Spawn(Class'mm_RainbowShockRifle.RainbowShockExplosion',,, Location);
    }
}

simulated function Explode(vector HitLocation,vector HitNormal)
{
    if ( Role == ROLE_Authority )
    {
        HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
    }

   	PlaySound(ImpactSound, SLOT_Misc);
	if ( EffectIsRelevant(Location,false) )
	{
	    Spawn(Class'mm_RainbowShockRifle.RainbowShockExplosionCore',,, Location);
		if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) )
		{
			Spawn(Class'mm_RainbowShockRifle.RainbowShockExplosion',,, Location);
		}
	}
    SetCollisionSize(0.0, 0.0);
    SetNewDamage();
	DoImpactEffects();
    DestroyProjectile();
	Destroy();
}

simulated function SetNewDamage()
{
    NewDamage = Damage * ( (1-DampeningFactor) ** float(ReflectNum) );
}

event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
    if (DamageType == ComboDamageType)
    {
        Instigator = EventInstigator;
        SuperExplosion();
        if( EventInstigator.Weapon != None )
        {
			EventInstigator.Weapon.ConsumeAmmo(0, ComboAmmoCost, true);
            Instigator = EventInstigator;
        }
    }
}

function SuperExplosion()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;

	HurtRadius(ComboDamage, ComboRadius, class'DamTypeRainbowShockCombo', ComboMomentumTransfer, Location );

	Spawn(Class'mm_RainbowShockRifle.RainbowShockCombo');
	if ( (Level.NetMode != NM_DedicatedServer) && EffectIsRelevant(Location,false) )
	{
		HitActor = Trace(HitLocation, HitNormal,Location - Vect(0,0,120), Location,false);
		if ( HitActor != None )
		{
			Spawn(Class'mm_RainbowShockRifle.RainbowComboDecal',self,,HitLocation, rotator(vect(0,0,-1)));
		}
	}
	PlaySound(ComboSound, SLOT_None,1.0,,800);
    DestroyTrails();
    Destroy();
}

Simulated Function DestroyProjectile()
{
    SetCollisionSize(0.0, 0.0);
    Destroy();
}

function Monitor(Pawn P)
{
	ComboTarget = P;

	if ( ComboTarget != None )
	{
		GotoState('WaitForCombo');
	}
}

State WaitForCombo
{
	function Tick(float DeltaTime)
	{
		if ( (ComboTarget == None) || ComboTarget.bDeleteMe
			|| (Instigator == None) || (ShockRifle(Instigator.Weapon) == None) )
		{
			GotoState('');
			return;
		}

		if ( (VSize(ComboTarget.Location - Location) <= 0.5 * ComboRadius + ComboTarget.CollisionRadius)
			|| ((Velocity Dot (ComboTarget.Location - Location)) <= 0) )
		{
			ShockRifle(Instigator.Weapon).DoCombo();
			GotoState('');
			return;
		}
	}
}

defaultproperties
{
     ComboSound=Sound'WeaponSounds.ShockRifle.ShockComboFire'
     ComboDamage=200.000000
     ComboRadius=275.000000
     ComboMomentumTransfer=150000.000000
     ComboAmmoCost=2
     ComboDamageType=Class'mm_RainbowShockRifle.DamTypeRainbowShockBeam'
     ReflectMaxNum=5
     DampeningFactor=0.150000
     Speed=1150.000000
     MaxSpeed=1150.000000
     bSwitchToZeroCollision=True
     Damage=20.000000
     DamageRadius=150.000000
     MomentumTransfer=70000.000000
     MyDamageType=Class'mm_RainbowShockRifle.DamTypeRainbowShockBall'
     ImpactSound=Sound'WeaponSounds.ShockRifle.ShockRifleExplosion'
     ExplosionDecal=Class'mm_RainbowShockRifle.RainbowShockImpactScorch'
     MaxEffectDistance=7000.000000
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=195
     LightSaturation=85
     LightBrightness=255.000000
     LightRadius=4.000000
     DrawType=DT_Sprite
     CullDistance=4000.000000
     bDynamicLight=True
     bNetTemporary=False
     bOnlyDirtyReplication=True
     AmbientSound=Sound'WeaponSounds.ShockRifle.ShockRifleProjectile'
     LifeSpan=30.000000
     Texture=Texture'mm_RainbowShockRifle.RainbowShockRifle.RainbowNew_core_low'
     DrawScale=0.700000
     Skins(0)=Texture'mm_RainbowShockRifle.RainbowShockRifle.RainbowNew_core_low'
     Style=STY_Translucent
     FluidSurfaceShootStrengthMod=8.000000
     SoundVolume=50
     SoundRadius=100.000000
     CollisionRadius=10.000000
     CollisionHeight=10.000000
     bProjTarget=True
     bAlwaysFaceCamera=True
     ForceType=FT_Constant
     ForceRadius=40.000000
     ForceScale=5.000000
}
