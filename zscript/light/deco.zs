class WorkLamp : Actor {
    // induistrial light
    default {
        +SOLID;
    }

    states {
        Spawn:
            LAMP A -1;
            Stop;
    }
}

class CeilingLamp : Actor {
    // high light

    default {
        +SPAWNCEILING;
        +NOGRAVITY;
    }

    states {
        Spawn:
            LAMP B -1;
            Stop;
    }
}

class FloorLamp : Actor {
    // small light

    states {
        Spawn:
            LAMP C -1;
            Stop;
    }
}

class Mote : Actor {
    // mystical, strange

    default {
        Speed 1;
        +FRIENDLY;
        +NOGRAVITY;
    }

    override void Tick() {
        super.Tick();
        // A_Chase(); // this thing can follow patrol points!
    }

    states {
        Spawn:
            LITE A random(15,35) Light("mote1");
            LITE B random(10,20) Light("mote2");
            LITE C random(5,15) Light("mote3");
            LITE B random(10,20) Light("mote2");
            Loop;
    }
}