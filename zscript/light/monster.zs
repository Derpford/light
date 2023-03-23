class LightMonster : Actor {
    // AI functions go here.
    double ClampTurn(double targetang, double currentang, double maxang) {
        double res = 0;
        if (AbsAngle(targetang,currentang) < maxang || maxang < 0) {
            res = targetang;
        } else {
            if (DeltaAngle(targetang,currentang) < 0) {
                res = currentang+maxang;
            } else {
                res = currentang-maxang;
            }
        }

        return res;
    }

    void LookAt(Actor other, Vector2 maxturn) {
        Vector2 tgtv = (AngleTo(other), PitchTo(other,height/2,other.height/2));
        angle = ClampTurn(tgtv.x,angle,maxturn.x);
        pitch = ClampTurn(tgtv.y,pitch,maxturn.x);
    }

    void FollowPath(Vector2 maxturn = (-1,-1)) {
        // maxturn.x is angle, maxturn.y is pitch
        // If we have a patrol path to follow, go to it. Otherwise, go to our target.
        if (goal) {
            LookAt(goal,maxturn);
        } else if (target) {
            LookAt(target,maxturn);
        } else {
            // Don't change our angle or pitch yet, but find a target...
            LookForPlayers(true);
        }

        if (bFLOAT) {
            Vel3DFromAngle(speed,angle,pitch);
        } else {
            VelFromAngle(speed,angle);
        }
    }
}