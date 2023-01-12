class DarkEye : Actor {
    // drawn inexorably into its grasp
    // only to be thrown away

    double vacrad; // maximum radius for vacuuming
    double vacminrad; // radius within which force is massively increased
    double vacforce; // how hard things get sucked at distance = 1

    Property Vacuum: vacrad, vacminrad, vacforce;

    default {
        Monster; // TODO: Make sure this thing only goes to patrol points
        +FLOAT;
        +NOGRAVITY;
        +BRIGHT;
        -SOLID;
        +NOBLOCKMAP;
        +THRUACTORS;
        Speed 2;
        Health 100;
        DarkEye.Vacuum 480,128,40;
    }

    override void Tick() {
        Super.Tick();
        // A_SpawnParticleEX("FFFFFF",TexMan.CheckForTexture("ORBLA0"),STYLE_Subtract,size:70);
        if (GetAge() % 2 == 0) {
            SpawnVoidPart();
        }

        Vac();
    }

    void Vac() {
        ThinkerIterator it = ThinkerIterator.Create();
        Actor mo;
        while (mo = Actor(it.next())) {
            if (mo == self) {continue;}
            if (mo.CountInv("ThrownOut") > 0) {continue;}
            vector3 dir = mo.Vec3To(self);
            double dist = dir.length();
            if (dist <= vacrad) {
                double mult = sqrt(1 - (dist / vacrad));
                double vf = 1./35. * vacforce * mult;
                if (dist < vacminrad) {
                    // Throw stuff that gets too close.
                    vf += vacforce * (1 - sqrt(dist / vacminrad));
                    if (vf > 0.5 * vacforce) {
                        mo.GiveInventory("ThrownOut",1);
                        mo.bBLASTED = true;
                        console.printf("Tossed!");
                    }
                }
                mo.vel += dir.unit() * vf;
            }

        }
    }

    void SpawnVoidPart() {
        FSpawnParticleParams vpart;
        vpart.texture = TexMan.CheckForTexture("FADEA0");
        vpart.color1 = "FFFFFF";
        vpart.style = STYLE_Subtract;
        vpart.size = 40;
        vpart.lifetime = 35;
        vpart.sizestep = 2.5;
        vpart.startalpha = 0.3;
        vpart.fadestep = vpart.startalpha * 0.9 / 35.;
        double atp = AngleTo(players[consoleplayer].mo); // Slightly gross hack.
        vpart.pos = Vec3Angle(8,atp-180);
        vpart.vel = (Vec3To(players[consoleplayer].mo).unit() + (frandom(-0.5,0.5),frandom(-0.5,0.5),frandom(-0.5,0.5))) * -1;
        Level.SpawnParticle(vpart);
    }

    states {
        Spawn:
            MEYE A 1 A_JumpIf(!bDORMANT,"Wake");
            Loop;

        Wake:
            MEYE A 5;
            MEYE B 5;
            MEYE C 4;
            MEYE D 3;
            MEYE E 10;
            MEYE D 4;
        
        See:
            MEYE D 1 A_Chase();
            Loop;
    }
}

class ThrownOut : Inventory {
    override void DoEffect() {
        if (GetAge() > 10) {
            // owner.bBLASTED = false;
            owner.A_TakeInventory("ThrownOut");
            return;
        }
    }
}