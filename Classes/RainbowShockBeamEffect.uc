class RainbowShockBeamEffect extends xEmitter;

var Vector HitNormal;
var class<RainbowShockBeamCoil> CoilClass;
var class<RainbowShockMuzFlash> MuzFlashClass;
var class<RainbowShockMuzFlash3rd> MuzFlash3Class;

replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
        HitNormal;
}

function AimAt(Vector hl, Vector hn)
{
    HitNormal = hn;
    mSpawnVecA = hl;
    if (Level.NetMode != NM_DedicatedServer)
        SpawnEffects();
}

simulated function PostNetBeginPlay()
{
    if (Role < ROLE_Authority)
        SpawnEffects();
}

simulated function SpawnImpactEffects(rotator HitRot, vector EffectLoc)
{
	Spawn(class'RainbowShockImpactFlare',,, EffectLoc, HitRot);
	Spawn(class'RainbowShockImpactRing',,, EffectLoc, HitRot);
	Spawn(class'RainbowShockImpactScorch',,, EffectLoc, Rotator(-HitNormal));
	Spawn(class'RainbowShockExplosionCore',,, EffectLoc+HitNormal*8, HitRot);
}

simulated function bool CheckMaxEffectDistance(PlayerController P, vector SpawnLocation)
{
	return !P.BeyondViewDistance(SpawnLocation,3000);
}

simulated function SpawnEffects()
{
    local RainbowShockBeamCoil Coil;
    local xWeaponAttachment Attachment;

    if (Instigator != None)
    {
        if ( Instigator.IsFirstPerson() )
        {
			if ( (Instigator.Weapon != None) && (Instigator.Weapon.Instigator == Instigator) )
				SetLocation(Instigator.Weapon.GetEffectStart());
			else
				SetLocation(Instigator.Location);
            Spawn(MuzFlashClass,,, Location);
        }
        else
        {
            Attachment = xPawn(Instigator).WeaponAttachment;
            if (Attachment != None && (Level.TimeSeconds - Attachment.LastRenderTime) < 1)
                SetLocation(Attachment.GetTipLocation());
            else
                SetLocation(Instigator.Location + Instigator.EyeHeight*Vect(0,0,1) + Normal(mSpawnVecA - Instigator.Location) * 25.0);
            Spawn(MuzFlash3Class);
        }
    }

    if ( EffectIsRelevant(mSpawnVecA + HitNormal*2,false) && (HitNormal != Vect(0,0,0)) )
		SpawnImpactEffects(Rotator(HitNormal),mSpawnVecA + HitNormal*2);

    if ( (!Level.bDropDetail && (Level.DetailMode != DM_Low) && (VSize(Location - mSpawnVecA) > 40) && !Level.GetLocalPlayerController().BeyondViewDistance(Location,0))
		|| ((Instigator != None) && Instigator.IsFirstPerson()) )
    {
	    Coil = Spawn(CoilClass,,, Location, Rotation);
	    if (Coil != None)
		    Coil.mSpawnVecA = mSpawnVecA;
    }
}

defaultproperties
{
     CoilClass=Class'mm_RainbowShockRifle.RainbowShockBeamCoil'
     MuzFlashClass=Class'mm_RainbowShockRifle.RainbowShockMuzFlash'
     MuzFlash3Class=Class'mm_RainbowShockRifle.RainbowShockMuzFlash3rd'
     mParticleType=PT_Beam
     mMaxParticles=3
     mLifeRange(0)=0.750000
     mRegenDist=150.000000
     mSizeRange(0)=12.000000
     mSizeRange(1)=24.000000
     mAttenKa=0.100000
     bReplicateInstigator=True
     bReplicateMovement=False
     RemoteRole=ROLE_SimulatedProxy
     NetPriority=3.000000
     LifeSpan=0.750000
     Texture=Texture'mm_RainbowShockRifle.RainbowShockRifle.RainbowBeamTex'
     Skins(0)=Texture'mm_RainbowShockRifle.RainbowShockRifle.RainbowBeamTex'
     Style=STY_Additive
}
