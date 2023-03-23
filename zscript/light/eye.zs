class DarkEye : LightMonster {
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
        +DONTFALL;
        Speed 2;
        Health 100;
        DarkEye.Vacuum 480,128,40;
    }

    override void Tick() {
        Super.Tick();
        if (health > 0 && !bCORPSE) {
            if (GetAge() % 2 == 0) {
                SpawnVoidPart();
            }

            Vac();
        }
    }

    Actor FindEyeSpot() {
        // Find an EyeTeleSpot that matches our TID. I'd fall back to a PlayerStart, but there's apparently no such class...
        Actor res = null;
        Array<Actor> hits;
        Actor mo;
        ThinkerIterator eyes = ThinkerIterator.Create("EyeTeleSpot");
        while (mo = Actor(eyes.next())) {
            if (mo is "EyeTeleSpot" && (mo.TID == self.TID || self.TID == 0)) {
                hits.push(mo);
            }
        }

        if (hits.size() > 0)  {
            if (hits.size() == 1) {
                res = hits[0];
            } else {
                res = hits[random(0,hits.size()-1)];
            }
        }

        return res;
    }

    void Vac() {
        ThinkerIterator it = ThinkerIterator.Create();
        Actor mo;
        while (mo = Actor(it.next())) {
            if (mo == self) {continue;}
            if (mo.CountInv("ThrownOut") > 0) {continue;}
            if (mo.bNOTARGET) {continue;}
            vector3 dir = mo.Vec3To(self);
            double dist = dir.length();
            if (dist <= vacrad) {
                double mult = sqrt(1 - (dist / vacrad));
                double vf = 1./35. * vacforce * mult;
                if (dist < vacminrad) {
                    // Throw stuff that gets too close.
                    vf += vacforce * (1 - sqrt(dist / vacminrad));
                    if (vf > 0.5 * vacforce) {
                        if (mo is "RoadFlare") {
                            // This thing dies when hit by a flare or similar.
                            A_Die();
                            vf = 0;
                            mo.vel = (0,0,0);
                        }

                        if (mo is "LightPlayer") {
                            Actor tspot = FindEyeSpot();
                            if (tspot) {
                                mo.Vel3DFromAngle(frandom(4,12),frandom(0,360),frandom(-15,-90));
                                mo.warp(tspot);
                            }
                        }

                        mo.GiveInventory("ThrownOut",1);
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

    void SpawnDeathPart() {
        FSpawnParticleParams vpart;
        vpart.texture = TexMan.CheckForTexture("FADEA0");
        vpart.color1 = "FFFFFF";
        vpart.style = STYLE_Subtract;
        vpart.size = 20;
        vpart.lifetime = 35;
        vpart.sizestep = -2.5;
        vpart.startalpha = 0.7;
        vpart.fadestep = vpart.startalpha * 0.9 / 35.;
        double atp = AngleTo(players[consoleplayer].mo); // Slightly gross hack.
        vpart.pos = Vec3Angle(8,atp-180);
        vpart.vel = (Vec3To(players[consoleplayer].mo).unit() + (frandom(-5,5),frandom(-5,5),frandom(-5,5))) * -1;
        Level.SpawnParticle(vpart);

    }

    State DeathFade() {
        A_SetScale(scale.x - (scale.x / 20));
        SpawnDeathPart();
        if (scale.x < 0.2) {
            return ResolveState("DeathReal");
        } else {
            return ResolveState(null);
        }
    }

    void Rattle(double rad) {
        WorldOffset = (frandom(-rad,rad),frandom(-rad,rad),frandom(-rad,rad));
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
            MEYE D 1 FollowPath((1,1));
            Loop;

        Death:
            MEYE E 1 Rattle(16);
            MEYE E 1 Rattle(8);
            MEYE E 1 Rattle(4);
            MEYE E 2 Rattle(2);
            MEYE E 2 Rattle(1);
            MEYE E 1 Rattle(16);
            MEYE E 1 Rattle(8);
            MEYE E 1 Rattle(4);
            MEYE E 2 Rattle(2);
            MEYE E 2 Rattle(1);
            MEYE E 15 A_ScreamAndUnblock();
        DeathLoop:
            MEYE E 3 DeathFade();
            Loop;
        DeathReal:
            TNT1 A 0;
            Stop;
    }
}

class ThrownOut : Inventory {
    override void DoEffect() {
        if (GetAge() > 15) {
            owner.A_TakeInventory("ThrownOut");
            return;
        }
    }
}

class EyeTeleSpot : Actor {
    // Marks a location where an Eye can teleport a player to.
    default {
        +NOINTERACTION;
        +FLATSPRITE;
        +BRIGHT;
        +NOTARGET;
        // RenderStyle "Subtract";
        RenderStyle "None";
    }

    states {
        Spawn:
            MEYE E -1;
    }
}