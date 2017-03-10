SndBuf ethel => WinFuncEnv env => dac;
env.setBlackmanHarris();

ethel.read(me.dir() + "ethel.wav");
ethel.pos(ethel.samples());

for (0.01 => float i; i < 1.0; 0.01+=>i) {
    stretch(ethel, env, Math.pow(i, 3) * 30::second, 128);
}

fun void stretch(SndBuf buf, WinFuncEnv env, dur duration, int windows) {
    duration/windows => dur grain;
    grain * 0.5 => dur halfGrain;

    if (halfGrain < 1.0::samp) {
        return;
    }

    env.attack(halfGrain);
    env.release(halfGrain);
    buf.samples()/windows => int sampleIncrement;

    for (0 => int i; i < windows; i++) {
        buf.pos(i * sampleIncrement);
        env.keyOn();
        halfGrain => now;
        env.keyOff();
        halfGrain => now;
    }
}
