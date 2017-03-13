// Eric Heep
// March 10th, 2017

// OSC sender that controls the piece,
// essenctially the score of the piece

OscOut agnes;
OscOut ethel;
OscOut vera;
OscOut local;

local.dest("127.0.0.1", 12345);

// start it up
ethel.dest("192.168.1.20", 12345);
agnes.dest("192.168.1.10", 12345);
vera.dest( "192.168.1.30", 12345);

0.1::second => now;

// let em know who's who
ethel.start("/pi");
ethel.add(0);
ethel.send();

agnes.start("/pi");
agnes.add(1);
agnes.send();

vera.start("/pi");
vera.add(2);
vera.send();

0.1::second => now;

// set first node
setNode(0);

0.1::second => now;

// osc functions
fun void oscTrigger(OscOut out, int voice, float seconds, float angle, float pow) {
    out.start("/m");
    out.add(voice);
    out.add(seconds);
    out.add(angle);
    out.add(pow);
    out.send();
}

fun void oscNodeConfiguration(OscOut out, int nodeConfig, int whichPi) {
    out.start("/n");
    out.add(nodeConfig);
    out.add(whichPi);
    out.send();
}

fun void setNode(int nodeConfig) {
    oscNodeConfiguration(local, nodeConfig, 0);
    oscNodeConfiguration(ethel, nodeConfig, 0);
    oscNodeConfiguration(agnes, nodeConfig, 1);
    oscNodeConfiguration(vera, nodeConfig, 2);
}

fun void triggerVoice(int voice, dur duration, float angle, float pow, dur offset, int nodeConfig) {
    offset => now;
    oscTrigger(local, voice, duration/second, angle, pow);
    oscTrigger(ethel, voice, duration/second, angle, pow);
    oscTrigger(agnes, voice, duration/second, angle, pow);
    oscTrigger(vera,  voice, duration/second, angle, pow);
    setNode(nodeConfig);
}

// compositional parameters ~*~*~*~*~*~*~*~

2 * pi => float TAU;

4::second => dur totalIncrementTime;

0.0015 => float runningInc;

4.0 => float exponentialModifier;

1.0/3.0 => float oneThird;
2.0/3.0 => float twoThirds;

0.5 => float powRange;
0.5 => float powOffset;

0.5 => float rotationsPerSection;
pi => float angleOffset;

// calculate the entire length of the piece
0::samp => dur totalDuration;

for (1.0 => float i; i > 0.0; runningInc -=> i) {
    Math.pow(i, exponentialModifier) => float scale;
    scale * totalIncrementTime => dur duration;
    duration +=> totalDuration;
}

totalDuration * 2 => totalDuration;

totalDuration/6.0 => dur nodeConfigIncrementTime;
totalDuration/4.0 => dur voiceAddIncrementTime;

1 => int nodeConfig;
0::samp => dur runningDuration;

0 => int firstVoiceLatch;
0 => int secondVoiceLatch;

// and here we go ~*~*~*~*~*~*~*~*~*
for (1.0 => float i; i > 0.0; runningInc -=> i) {
    Math.pow(i, exponentialModifier) => float scale;
    scale * totalIncrementTime => dur duration;

    // to track node changes
    duration +=> runningDuration;

    // a range of 0 -> 2pi
    (1.0 - scale) * TAU => float linearScalarTau;

    // a range of 0.5 -> 3.0
    i * powRange + powOffset => float scalarPow;
    (angleOffset + linearScalarTau) * rotationsPerSection => float angle;

    // first voice begins, first formation (hexagon), gradual slowdown, rotation, and curve
    triggerVoice(0, duration, linearScalarTau, angle, 0::samp, nodeConfig);
    duration => now;

    // second voice begins/ second formation (zigzag), still gradual slowdown, rotation, and curve
    if (runningDuration > (voiceAddIncrementTime * 1)) {
        if (firstVoiceLatch == 0) {
            1 => firstVoiceLatch;
            <<< "Voice Two Added", "" >>>;
        }
        triggerVoice(1, duration, scalarPow, angle * oneThird, 0::samp, nodeConfig);
        duration => now;
        duration +=> runningDuration;
    }

    // third voice begins/ third formation (rectangle), still gradual slowdown, rotation, and curve
    if (runningDuration > (voiceAddIncrementTime * 2)) {
        if (secondVoiceLatch == 0) {
            1 => secondVoiceLatch;
            <<< "Voice Three Added", "" >>>;
        }
        triggerVoice(2, duration, scalarPow, angle * twoThirds, 0::samp, nodeConfig);
        duration => now;
        duration +=> runningDuration;
    }

    if (nodeConfig < 5) {
        if (runningDuration > nodeConfigIncrementTime * nodeConfig) {
            <<< "Time:\t", runningDuration/minute, "\tChange to configuration:", nodeConfig >>>;
            setNode(nodeConfig);
            nodeConfig++;
        }
    }
}

<<< "Total:\t", runningDuration/minute, "" >>>;
