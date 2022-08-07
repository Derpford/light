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