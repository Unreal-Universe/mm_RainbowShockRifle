class RainbowShockAmmoPickup extends UTAmmoPickup;

defaultproperties
{
     AmmoAmount=10
     InventoryType=Class'mm_RainbowShockRifle.RainbowShockAmmo'
     PickupMessage="You picked up a Rainbow Shock Core."
     PickupSound=Sound'PickupSounds.ShockAmmoPickup'
     PickupForce="ShockAmmoPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.ShockAmmoPickup'
     DrawScale3D=(X=0.800000,Z=0.500000)
     PrePivot=(Z=32.000000)
     CollisionHeight=32.000000
}
