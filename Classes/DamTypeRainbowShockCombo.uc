class DamTypeRainbowShockCombo extends WeaponDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth )
{
    HitEffects[0] = class'HitSmoke';
}

static function IncrementKills(Controller Killer)
{
	local xPlayerReplicationInfo xPRI;

	xPRI = xPlayerReplicationInfo(Killer.PlayerReplicationInfo);
	if ( xPRI != None )
	{
		xPRI.combocount++;
		if ( (xPRI.combocount == 5) && (UnrealPlayer(Killer) != None) ) //was 15
			UnrealPlayer(Killer).ClientDelayedAnnouncementNamed('ComboWhore',15);
	}
}

defaultproperties
{
     WeaponClass=Class'mm_RainbowShockRifle.RainbowShockRifle'
     DeathString="%o couldn't avoid the blast from %k's Rainbow shock combo."
     FemaleSuicide="%o made a tactical error with her Rainbow shock combo."
     MaleSuicide="%o made a tactical error with his Rainbow shock combo."
     bAlwaysSevers=True
     bDetonatesGoop=True
     bThrowRagdoll=True
}
