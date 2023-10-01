class RainbowShockProjFire extends tk_ProjectileFire;

function InitEffects()
{
    Super.InitEffects();
    if ( FlashEmitter != None )
		Weapon.AttachToBone(FlashEmitter, 'tip');
}

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    p = Super.SpawnProjectile(Start,Dir);
	if ( (RainbowShockRifle(Instigator.Weapon) != None) && (p != None) )
		RainbowShockRifle(Instigator.Weapon).SetComboTarget(RainbowShockProjectile(P));
	return p;
}

defaultproperties
{
     ProjSpawnOffset=(X=24.000000,Y=8.000000,Z=0.000000)
     bSplashDamage=True
     TransientSoundVolume=0.400000
     FireAnim="AltFire"
     FireAnimRate=1.500000
     FireSound=SoundGroup'WeaponSounds.ShockRifle.ShockRifleAltFire'
     FireForce="ShockRifleAltFire"
     FireRate=0.600000
     AmmoClass=Class'mm_RainbowShockRifle.RainbowShockAmmo'
     AmmoPerFire=2
     ShakeRotMag=(X=60.000000,Y=20.000000)
     ShakeRotRate=(X=1000.000000,Y=1000.000000)
     ShakeRotTime=2.000000
     ProjectileClass=Class'mm_RainbowShockRifle.RainbowShockProjectile'
     BotRefireRate=0.350000
     FlashEmitterClass=Class'mm_RainbowShockRifle.RainbowShockProjMuzFlash'
}
