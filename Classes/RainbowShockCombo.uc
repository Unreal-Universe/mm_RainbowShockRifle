class RainbowShockCombo extends Actor;

var RainbowShockComboFlare Flare;

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Level.NetMode != NM_DedicatedServer)
    {
        Spawn(Class'tk_RainbowShockRifle.RainbowShockComboExpRing');
        Flare = Spawn(Class'tk_RainbowShockRifle.RainbowShockComboFlare');
        Spawn(Class'tk_RainbowShockRifle.RainbowShockComboCore');
        Spawn(Class'tk_RainbowShockRifle.RainbowShockComboSphereDark');
        Spawn(Class'tk_RainbowShockRifle.RainbowShockComboVortex');
        Spawn(Class'tk_RainbowShockRifle.RainbowShockComboWiggles');
        Spawn(Class'tk_RainbowShockRifle.RainbowShockComboFlash');
    }
}

auto simulated state Combo
{
Begin:
    Sleep(0.9);
    if ( Flare != None )
    {
		Flare.mStartParticles = 2;
		Flare.mRegenRange[0] = 0.0;
		Flare.mRegenRange[1] = 0.0;
		Flare.mLifeRange[0] = 0.3;
		Flare.mLifeRange[1] = 0.3;
		Flare.mSizeRange[0] = 150;
		Flare.mSizeRange[1] = 150;
		Flare.mGrowthRate = -500;
		Flare.mAttenKa = 0.9;
	}
    LightType = LT_None;
}

defaultproperties
{
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=195
     LightSaturation=100
     LightBrightness=255.000000
     LightRadius=10.000000
     DrawType=DT_None
     bDynamicLight=True
     bNetTemporary=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=2.000000
     bCollideActors=True
     ForceType=FT_Constant
     ForceRadius=300.000000
     ForceScale=-500.000000
}
