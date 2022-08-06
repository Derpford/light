class FlareTosser : Weapon {
    // wield it

    default {
        Weapon.AmmoType "FlarePickup";
        Weapon.AmmoUse 1;
    }

    action void TossFlare() {
        let flr = RoadFlare(A_FireProjectile("RoadFlare"));
        if (flr) {
            flr.spin = frandom(-5,5);
        }
    }

    states {
        Select:
            TNT1 A 1 A_Raise(35);
            Loop;
        Deselect:
            TNT1 A 1 A_Lower(35);
            Loop;
        
        Ready:
            TNT1 A 1 A_WeaponReady();
            Loop;
        Fire:
            TNT1 A 1 TossFlare();
            TNT1 A 0;
        Hold:
            TNT1 A 1;
            TNT1 A 1 A_ReFire("Hold");
            TNT1 A 0;
            Goto Ready;
    }
}