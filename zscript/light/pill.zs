class Pills : Inventory {
    // calm
    mixin PickUp;
    default {
        Inventory.Amount 2;
        Inventory.MaxAmount 10;
        Scale 0.5;
        -INVENTORY.AUTOACTIVATE;
    }

    states {
        Spawn:
            PILL A 1 Sparkle();
            Loop;
    }
}