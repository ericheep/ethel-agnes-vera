// Eric Heep
// March 8th, 2017

OscOut local;

// agnes.dest("192.168.1.10", 12345);
local.dest("127.0.0.1", 12345);

0.1::second => now;

local.start("/pi");
local.add(0);
local.send();

0.1::second => now;

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
    out.add(shift);
    out.send();
}

fun void move(int voice, dur duration, float angle, float pow, dur offset) {
    offset => now;
    oscParams(local, "/p", voice, duration/second, angle, pow);
    10::ms => now;
    oscMoveVoice(local, "/m", voice);
}


0.1::second => dur duration;

for (int i; i < 100; i++) {
    spork ~ move(0, duration, 0.0, 1.0, 0::second);
    spork ~ move(1, duration, 0.0, 1.0, 0::second);
    spork ~ move(2, duration, 0.0, 1.0, 0::second);
    duration => now;
}

