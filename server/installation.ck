// installation.ck
// Eric Heep
// May 4th, 2017

NodeConfigurations nodeConfig;

3 => int NUM_PIS;
4 => int NUM_SENDERS;
2.0 * pi => float TAU;

OscOut out[NUM_SENDERS];

0 => int VIS_ONLY;

// ethel agnes vera local
["ethel.local", "agnes.local", "vera.local", "localhost"] @=> string hosts[];

// init
if (VIS_ONLY) {
    out[3].dest("localhost", 12500);
} else {
    for (0 => int i; i < NUM_SENDERS; i++) {
        out[i].dest(hosts[i], 12345);
    }
    out[3].dest("localhost", 12500);
}

if (!VIS_ONLY) {
    for (0 => int i; i < NUM_PIS; i++) {
        out[i].start("/pi");
        out[i].add(i);
        out[i].send();
    }
}


// osc functions
fun void triggerVoice(int v, dur l, float a) {
    if (VIS_ONLY) {
        out[3].start("/t");
        out[3].add(v);
        out[3].add(l/second);
        out[3].add(a);
        out[3].send();
    } else {
        for (0 => int i; i < NUM_SENDERS; i++) {
            out[i].start("/t");
            out[i].add(v);
            out[i].add(l/second);
            out[i].add(a);
            out[i].send();
        }
    }
}


fun void setNode(int spkr, int ID) {
    if (VIS_ONLY) {
        out[3].start("/setNode");
        out[3].add(spkr);
        out[3].add(ID);
        out[3].send();
    } else {
        for (0 => int i; i < NUM_SENDERS; i++) {
            out[i].start("/setNode");
            out[i].add(spkr);
            out[i].add(ID);
            out[i].send();
        }
    }
}


fun void switchNode(int spkr, int ID, dur l) {
    if (VIS_ONLY) {
        out[3].start("/switchNode");
        out[3].add(spkr);
        out[3].add(ID);
        out[3].add(l/second);
        out[3].send();
    } else {
        for (0 => int i; i < NUM_SENDERS; i++) {
            out[i].start("/switchNode");
            out[i].add(spkr);
            out[i].add(ID);
            out[i].add(l/second);
            out[i].send();
        }
    }
}


// math functions
fun dur exponentialInterpolation(int i, int n, dur l) {
    1.0/n => float inverseN;
    l * inverseN => dur division;

    Math.pow(Math.pow(1 + n, inverseN), i) - 1 => float x;
    Math.pow(Math.pow(1 + n, inverseN), i + 1) - 1 => float y;

    return y * division - x * division;
}


fun float angleRotation(int i, int n, int r) {
    return (i/(n$float) * r * TAU) % TAU;
}


[16, 23, 25, 18, 31, 32] @=> int initialConfig[];

// score functions
fun void nodeChanges(dur transition, int changes[][]) {
    0 => int nodeID;
    0 => int spkr;
    0 => int change;

    for (0 => int i; i < changes.size(); i++) {
        transition => now;
        switchNode(changes[i][0], changes[i][1], transition);
        transition => now;
    }
    for (0 => int i; i < 6; i++) {
        transition => now;
        switchNode(i, initialConfig[i], transition);
        transition => now;
    }
}


fun void circling(int v, dur l, int n, int dir, dur offset) {
    now => time start;

    0::samp => dur iterationLength;
    0.0 => float angle;
    0 => int mod;

    if (dir == 0) {
        for (n - 1 => int i; i >= 0; i--) {
            exponentialInterpolation(i, n, l) => iterationLength;
            angleRotation(i, n, 3) => angle;

            triggerVoice(v, iterationLength + offset, angle + v/3.0 * TAU % TAU);
            iterationLength + offset => now;
        }
    } else if (dir == 1) {
        for (0 => int i; i < n; i++) {
            exponentialInterpolation(i, n, l) => iterationLength;
            angleRotation(i, n, 3) => angle;

            triggerVoice(v, iterationLength + offset, angle + v/3.0 * TAU % TAU);
            iterationLength + offset => now;
        }
    }
}

// ~ score
5::minute => dur section;
1::second => dur offset;
30::second => dur nodeSwitch;

200 => int loops;

5::second => now;

for (0 => int i; i < 6; i++) {
    setNode(i, initialConfig[i]);
}

<<< " - Start - ", "" >>>;

[[0, 17], [0, 16], [3, 17], [5, 33], [4, 32],
 [1, 22], [2, 26], [3, 25], [0, 17], [4, 23], [5, 32],
 [3, 11], [4, 37],
 [0,  9], [5, 39]] @=> int changes[][];

fun void nodesChanging() {
    while (true) {
        nodeChanges(nodeSwitch, changes);
    }
}

spork ~ nodesChanging();

fun void moveVoice(int v) {
    while (true) {
        circling(v, Math.random2f(0.8, 1.2) * section, loops, 0, offset);
        circling(v, Math.random2f(0.8, 1.2) * section, loops, 1, offset);
    }
}

spork ~ moveVoice(0);
second => now;
spork ~ moveVoice(1);
second => now;
spork ~ moveVoice(2);

while (true) {
    second => now;
}
