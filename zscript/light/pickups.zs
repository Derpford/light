mixin class PickUp {
    // A thing that can be picked up.

    void Sparkle() {
        A_SpawnParticle("000000",SPF_RELATIVE,12,frandom(2,4),frandom(0,360),radius,velz:2);
    }
}