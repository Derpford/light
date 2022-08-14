mixin class reassure {
    // reassuring

    void Reassure(double rad, bool flicker = false) {
        A_RadiusGive("reassurance",rad,RGF_PLAYERS);
        if (!flicker || GetAge() % 5 == 0) {
            A_SpawnParticle("FFFFFF",SPF_FULLBRIGHT|SPF_RELATIVE,4,8,frandom(0,360),xoff:128,zoff:4,velz:2);
        }
    }
}

class RoadFlare : Actor {
    // brilliant, temporary
    mixin reassure;
    double time;
    double spin;
    Property Time : time;
    default {
        +FLATSPRITE;
        +MISSILE;
        +ACTIVATEIMPACT
        +ACTIVATEPCROSS
        DamageFunction (1); // bonk
        RoadFlare.Time 60; // One minute of burn time.
        Speed 30; // For flaretosser.
    }

    override void Tick() {
        Super.Tick();
        // burn bright
        if (time > 0) {
            A_SpawnParticle("FFDDDD",SPF_FULLBRIGHT|SPF_RELATIVE,12,frandom(8,16),xoff:-4,yoff:16,velx:frandom(-2,4),vely:frandom(-2,4),velz:frandom(4,8),accelz:-0.5,sizestep:frandom(-1,1));
            time -= 1./35.;
            if (time < 10) {
                SetState(ResolveState("Flicker"));
            }

            // reassuring
            Reassure(128,(time < 10));
        } else {
            SetState(ResolveState("Dead"));
        }

        angle += spin;
        if (floorz == pos.z) {
            spin = spin * 0.7;
        }
    }

    states {
        Spawn:
        Death:
            FLAR A -1 Light("flare");
            Stop;
        Flicker:
            FLAR A -1 Light("flare2");
            Stop;
        Dead:
            FLAR A -1;
            Stop;
    }
}

class TitleScreenFlare : Actor {
    // burns forever
    default {
        +FLATSPRITE;
    }

    override void tick() {
        A_SpawnParticle("FFDDAA",SPF_FULLBRIGHT|SPF_RELATIVE,12,frandom(8,16),xoff:-4,yoff:16,velx:frandom(-2,4),vely:frandom(-2,4),velz:frandom(4,8),accelz:-0.5,sizestep:frandom(-1,1));
    }

    states {
        Spawn:
            FLAR A -1 Light("brightflare");
            Stop;
    }
}

class FlarePickup : Ammo {
    mixin PickUp;
    default {
        +FLATSPRITE;
        Inventory.Amount 1;
        Inventory.MaxAmount 9;
        Inventory.PickupMessage "flare";
    }

    states {
        Spawn:
            FLAR B 1 Sparkle();
            Loop;
    }
}

class Reassurance : Inventory {
    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
    }

    override void DoEffect() {

    }
}