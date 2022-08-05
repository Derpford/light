class LightHud : BaseStatusBar {
    HudFont mHudFont;
    LightPlayer pmo;

    int age;
    int barframe;

    override void Init() {
        Super.Init();
        SetSize(0,320,200);
        Font fnt = SmallFont;
        mHudFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft,1,1);
        barframe = 0;
    }

    override void tick() {
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
        if (CPlayer && CPlayer.mo) {
            pmo = LightPlayer(CPlayer.mo);
            age = pmo.GetAge();
        }

        if (state == HUD_StatusBar || state == HUD_Fullscreen) {
            BeginHud(forcescaled: true);

            DrawHealth();
            // DrawFlares();
            // DrawPills();
        }
    }

    void DrawHealth() {
        // Pick an animation frame for the fullbar.
        static const String frs[] = {
            "A", "B", "C"
        };
        String frame = frs[barframe].."0";
        DrawBar("BARF"..frame, "BARBA0",100,100,(0,-20),0,0,DI_SCREEN_CENTER_BOTTOM|DI_ITEM_CENTER_BOTTOM);
    }
}