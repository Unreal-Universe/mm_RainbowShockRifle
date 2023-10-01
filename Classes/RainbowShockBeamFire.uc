class RainbowShockBeamFire extends tk_ShockBeamFire;

var() class<RainbowShockBeamEffect> RainbowBeamEffectClass;
var() class<RainbowShockBeamEffectChild> RainbowBeamEffectClassChild;

var float DampeningFactor, NewDamage;
var bool bHitWithoutBounce;
var byte BounceNum, BounceMaxNum;

function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal, RefNormal;
    local Actor Other;
    local bool bDoReflect;
    local int ReflectNum;
    const MaxTrace = 45000;
    local float RemainingTrace;

    RemainingTrace = MaxTrace;

    bHitWithoutBounce = False;

    For (BounceNum = 0; BounceNum <= BounceMaxNum; BounceNum++)
    {
        MaxRange();
        ReflectNum = 0;

        TraceRange = fMin(RemainingTrace, TraceRange);

        if ( RemainingTrace < 15000 )
        {
            Break;
        }

        while (True)
        {
            bDoReflect = false;
            X = Vector(Dir);
            End = Start + TraceRange * X;

            Other = Weapon.Trace(HitLocation, HitNormal, End, Start, true);
            if ( Other != None && (Other != Instigator || ReflectNum > 0) )
            {
                if (bReflective && Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, DamageMin*0.25))
                {
                     bDoReflect = true;
                     HitNormal = Vect(0,0,0);
                }
                else if ( !Other.bWorldGeometry )
                {
                     SetNewDamage(BounceNum);
                     NewDamage *= DamageAtten;

                     if ( Other.IsA('Vehicle') || (!Other.IsA('Pawn') && !Other.IsA('HitScanBlockingVolume')) )
    			  WeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other, HitLocation, HitNormal);

                     Other.TakeDamage(NewDamage, Instigator, HitLocation, Momentum*X, DamageType);
                     bHitWithoutBounce = (BounceNum == 0);
                     BounceNum = BounceMaxNum + 1;
                     HitNormal = Vect(0,0,0);
                }
                else if ( WeaponAttachment(Weapon.ThirdPersonActor) != None )
    		     WeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other,HitLocation,HitNormal);
            }
            else
            {
                HitLocation = End;
                HitNormal = Vect(0,0,0);
    	        WeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other,HitLocation,HitNormal);
            }

            RemainingTrace -= VSize(Start - HitLocation);

            SpawnBeamEffect(Start, Dir, HitLocation, HitNormal, ReflectNum);

            if (bDoReflect && ++ReflectNum < 4)
            {
                Start = HitLocation;
                Dir = Rotator(RefNormal);
            }
            else
            {
                break;
            }
        }
        if (BounceNum <= BounceMaxNum && HitNormal != Vect(0,0,0))
        {
            Start = HitLocation;
            Dir = Rotator(MirrorVectorByNormal(Vector(Dir), HitNormal));
        }
        else
        {
            Break;
		}
    }
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
    local RainbowShockBeamEffect Beam;

    if (Weapon != None)
    {
        if (BounceNum > 0 && bHitWithoutBounce == False)
        {
       		Beam = Weapon.Spawn(RainbowBeamEffectClassChild,,, Start, Dir);
		}
        else
        {
            Beam = Weapon.Spawn(RainbowBeamEffectClass,,, Start, Dir);
		}

        if (ReflectNum != 0)
        {
        	Beam.Instigator = None;
		}

       	Beam.AimAt(HitLocation, HitNormal);
    }
}

Function SetNewDamage(byte BounceNum)
{
     NewDamage = DamageMin * ((1-DampeningFactor) ** float(BounceNum));
}

defaultproperties
{
     RainbowBeamEffectClass=Class'mm_RainbowShockRifle.RainbowShockBeamEffect'
     RainbowBeamEffectClassChild=Class'mm_RainbowShockRifle.RainbowShockBeamEffectChild'
     DampeningFactor=0.150000
     BounceMaxNum=2
     DamageType=Class'mm_RainbowShockRifle.DamTypeRainbowShockBeam'
     DamageMin=30
     DamageMax=30
     TraceRange=40000.000000
     Momentum=100000.000000
     AmmoClass=Class'mm_RainbowShockRifle.RainbowShockAmmo'
     FlashEmitterClass=Class'mm_RainbowShockRifle.RainbowShockBeamMuzFlash'
     aimerror=600.000000
}
