class DamTypeRainbowShockBeam extends WeaponDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth )
{
    HitEffects[0] = class'HitSmoke';
}

defaultproperties
{
     WeaponClass=Class'mm_RainbowShockRifle.RainbowShockRifle'
     DeathString="%o was fatally enlightened by %k's Rainbow shock beam."
     FemaleSuicide="%o somehow managed to shoot herself with the Rainbow shock rifle."
     MaleSuicide="%o somehow managed to shoot himself with the Rainbow shock rifle."
     bDetonatesGoop=True
     DamageOverlayMaterial=Shader'mm_RainbowShockRifle.RainbowShockRifle.RainbowHitShader'
     DamageOverlayTime=0.800000
     GibPerterbation=0.750000
     VehicleDamageScaling=0.850000
     VehicleMomentumScaling=0.500000
}
