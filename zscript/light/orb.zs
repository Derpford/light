class LightOrb : Inventory {
    // it glows
    mixin reassure;

    default {
        Inventory.PickupMessage "you stole the l  i  g  h  t";
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
    }

    override void Tick() {
        super.Tick();
        if (!owner) {
            Reassure(160);
        }
    }

    states {
        Spawn:
            ORBL A 5 Light("orb1") Bright;
            ORBL B 5 Light("orb2") Bright;
            ORBL C 5 Light("orb3") Bright;
            ORBL D 5 Light("orb4") Bright;
            ORBL C 5 Light("orb3") Bright;
            ORBL B 5 Light("orb2") Bright;
            Loop;
    }
}

class Pedestal : Actor {
    // place the light upon its throne

    mixin reassure;
    bool filled;

    override void Tick() {
        Super.Tick();
        if (filled) {
            Reassure(160);
        }
    }

    override bool Used(Actor user) {
        // do you have it?
        if (!filled && user.CountInv("LightOrb") > 0) {
            // give it to me
            user.A_TakeInventory("LightOrb",1);
            filled = true;
            A_CallSpecial(special,args[0],args[1],args[2],args[3],args[4]); // makes things happen
            return true;
        } else {
            return false; // do not
        }
    }

    states {
        Spawn:
            PEDL A 1 A_JumpIf(filled, "Filled");
            Loop;
        Filled:
            PEDL B 5 Light("orb1");
            PEDL C 5 Light("orb2");
            PEDL D 5 Light("orb3");
            PEDL E 5 Light("orb4");
            PEDL D 5 Light("orb3");
            PEDL C 5 Light("orb2");
            Loop;
    }
}