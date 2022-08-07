class LightPlayer : PlayerPawn {
    // i need the light
    // why won't you give it to me

    int lightlevel;
    int lightstage;
    double darkdamage; // the dark builds up in my bones
    double shake; // pain


    default {
        Speed 1;
        Health 100;
        Radius 16;
        Height 56;
        Mass 100;
        Player.DisplayName "Lightless";
        Player.StartItem "FlareTosser";
    }

    override void Tick() {
        Super.Tick();

        if (CountInv("reassurance") > 0) {
            lightlevel = 255;
            A_TakeInventory("reassurance",1);
        } else {
            lightlevel = Sector.PointInSector(pos.xy).lightlevel;
        }
        double tickamt;
        if (lightlevel < 128) {
            // the dark hurts slowly
            tickamt = 1.0 - (double(lightlevel)/128.);
            darkdamage += tickamt;
        } else {
            // not bright enough i need more
            tickamt = clamp((double(lightlevel)/128.) - 1.0, 0,1);
            darkdamage -= darkdamage * 0.5 * tickamt;
        }

        if (darkdamage > 35) {
            shake += max(5.0,2*shake);
            DamageMobj(null,null,1,"dark",DMG_FORCED);
            darkdamage -= 12;
        }

        if (lightlevel >= 128) {
            lightstage = 0;
        } else {
            lightstage = clamp(8 - (lightlevel / 16),1,4);
        }

        double sd = min(-shake * 0.1,-double.EPSILON);
        if (lightstage == 4) { sd += 1; }
        shake = max(shake+sd,0);
    }
}