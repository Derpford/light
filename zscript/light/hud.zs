class LightHud : BaseStatusBar {
    HudFont mHudFont;
    LightPlayer pmo;

    int age;
    int barframe;
    double shake;
    int lightlevel;
    int lightstage;

    int cflags;
    int lflags;
    int rflags;

    override void Init() {
        Super.Init();
        SetSize(0,320,200);
        Font fnt = BigFont;
        mHudFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft,1,1);
        barframe = 0;
        cflags = DI_SCREEN_CENTER_BOTTOM|DI_ITEM_CENTER_BOTTOM;
        lflags = DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT;
        rflags = DI_SCREEN_RIGHT_BOTTOM|DI_ITEM_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT;
        shake = 0;
    }

    override void tick() {
        // Grab player variables.
        if (CPlayer && CPlayer.mo) {
            pmo = LightPlayer(CPlayer.mo);
            age = pmo.GetAge();
            shake = pmo.shake;
            lightlevel = pmo.lightlevel;
            lightstage = pmo.lightstage;
        }
        // Tick bar frames.
        if (age % 12 == 0) {
            int i = 1;
            if(random(0,1)) { i = -i; }
            barframe = (barframe + i);
            while (barframe < 0) { barframe = 3 + barframe; }
            // Wraps barframe when it goes below 0.
            barframe = barframe % 3;
        }
    }

    override void Draw(int state, double tic) {

        if (state == HUD_StatusBar || state == HUD_Fullscreen) {
            BeginHud(forcescaled: true);

            DrawHealth();
            DrawEye();
            DrawFlares();
            DrawPills();
        }
    }

    Vector2 ShakePos(Vector2 pos, double intensity = 1.0) {
        // Shaky position.
        double scalar = 25;
        double mag = (atan((shake * intensity / scalar)) / 180.) * scalar;
        return pos + pmo.AngleToVector(frandom(0,360),frandom(mag/2.,mag));
    }

    void DrawHealth() {
        // Pick an animation frame for the fullbar.
        
        static const String frs[] = {
            "A", "B", "C"
        };
        String frame = frs[barframe].."0";
        DrawBar("BARF"..frame, "BARBA0",pmo.health,100,ShakePos((0,-20),0.5),0,0,cflags);
    }

    void DrawEye() {
        // Choose an eye-con based on light level.
        string frame;
        Vector2 dpos = ShakePos((0,-24));
        switch (lightstage) {
            case 0:
                frame = "A0";
                break;
            case 1:
                frame = "B0";
                break;
            case 2:
                frame = "C0";
                break;
            case 3:
                frame = "D0";
                break;
            case 4:
                frame = "E0";
                break;
        }
        DrawImage("LEYE"..frame,dpos,cflags);
    }

    void DrawFlares() {
        Vector2 dpos = ShakePos((-64,-24));
        DrawImage("FLARA0",dpos,rflags);
        DrawString(mHudFont,String.Format("%d",pmo.CountInv("FlarePickup")),dpos+(-32,-24),rflags);
    }

    void DrawPills() {
        Vector2 dpos = ShakePos((64,-24));
        DrawImage("PILLA0",dpos,lflags);
        DrawString(mHudFont,String.Format("%d",pmo.CountInv("Pills")),dpos+(32,-24),lflags);
    }
}