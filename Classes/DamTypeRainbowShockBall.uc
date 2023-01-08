class DamTypeRainbowShockBall extends WeaponDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth )
{
    HitEffects[0] = class'HitSmoke';
}

defaultproperties
{
     WeaponClass=Class'tk_RainbowShockRifle.RainbowShockRifle'
     DeathString="%o was wasted by %k's Rainbow shock core."
     FemaleSuicide="%o snuffed herself with the Rainbow shock core."
     MaleSuicide="%o snuffed himself with the Rainbow shock core."
     bDetonatesGoop=True
     bDelayedDamage=True
     DamageOverlayMaterial=Shader'tk_RainbowShockRifle.RainbowShockRifle.RainbowHitShader'
     DamageOverlayTime=0.800000
}
