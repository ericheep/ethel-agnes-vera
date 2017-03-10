// Eric Heep
// March 8th, 2017

OscOut agnes;
OscOut ethel;
OscOut vera;

agnes.dest("192.168.1.10", 12345);
ethel.dest("192.168.1.20", 12345);
vera.dest( "192.168.1.30", 12345);

fun void oscParams(OscOut out, string addr, int voice, float seconds, float angle, float pow) {
    out.start(addr);
    out.add(voice);
    out.add(seconds);
    out.add(angle);
    out.add(pow);
    out.send();
}

fun void oscMoveVoice(OscOut out, string addr, int voice) {
    out.start(addr);
    out.add(voice);
    out.send();
}

fun void oscNodeShift(OscOut out, string addr, int shift) {
    out.start(addr);
    out.add(voice);
    out.send();
}

fun void move(int voice, dur duration, float angle, float pow, dur offset) {
    offset => now;
    oscParams(agnes, "/p", voice, duration/second, angle, pow);
    oscParams(ethel, "/p", voice, duration/second, angle, pow);
    oscParams(vera,  "/p", voice, duration/second, angle, pow);

    // breathing room
    10::ms => now;
    oscMoveVoice(agnes, "/m", voice);
    oscMoveVoice(ethel, "/m", voice);
    oscMoveVoice(vera,  "/m", voice);
}

0::samp => dur totalDuration;
// few contants
2 * pi => float TAU;
2.5 => float POW_RANGE;

for (0.005 => float i; i < 1.0; 0.005 +=> i) {
    Math.pow(i, 6) => float scale;
    scale * 30::second => dur duration;

    duration +=> totalDuration;

    // a range of 0 -> 2pi
    scale * TAU => float scalarTau;

    // a range of 0.5 -> 3.0
    scale * POW_RANGE + 0.5 => float scalarPow;

    // first voice begins, first formation (hexagon), gradual slowdown, rotation, and curve
    spork ~ move(0, duration, scalarTau * 0.0/3.0, scalarPow, duration * 0.0/3.0);

    // second voice begins/ second formation (zigzag), still gradual slowdown, rotation, and curve
    if (scale > 0.33) {
        spork ~ move(1, duration, scalarTau * 1.0/3.0, scalarPow, duration * 1.0/3.0);
    }

    // third voice begins/ third formation (rectangle), still gradual slowdown, rotation, and curve
    if (scale > 0.66) {
        spork ~ move(2, duration, scalarTau * 2.0/3.0, scalarPow, duration * 2.0/3.0);
    }

    duration => now;

    // breathing room
    1::samp => now;
}

// to make up for the offset time,
// should be 10 seconds of silence as well
30::second => now;

// fourth formation (hexagon), speed up to nothing
for (1.0 => float i; i > 0.0; 0.01 -=> i) {
    Math.pow(i, 6) => float scale;
    scale * 30::second => dur duration;

    // a range of 0 -> 2pi
    scale * TAU => float scalarTau;

    // a range of 0.5 -> 3.0
    scale * POW_RANGE + 0.5 => float scalarPow;

    spork ~ move(0, duration, scalarTau * 0.0/3.0, scalarPow, duration * 0.0/3.0);
    spork ~ move(1, duration, scalarTau * 1.0/3.0, scalarPow, duration * 1.0/3.0);
    spork ~ move(2, duration, scalarTau * 2.0/3.0, scalarPow, duration * 2.0/3.0);

    duration => now;

    // breathing room
    1::samp => now;
}
