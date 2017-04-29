// Eric Heep
// April 24th, 2017

NodeConfigurations nodeConfig;

3 => int NUM_PIS;
4 => int NUM_SENDERS;
2.0 * pi => float TAU;

OscOut out[NUM_SENDERS];
0.1::second => now;

1 => int VIS_ONLY;

// ethel agnes vera local
["ethel.local", "agnes.local", "vera.local", "localhost"] @=> string hosts[];

// init
if (VIS_ONLY) {
    out[3].dest("localhost", 12345);
} else {
    for (0 => int i; i < NUM_SENDERS; i++) {
        out[i].dest(hosts[i], 12345);
    }
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
        out[3].start("/traverse");
        out[3].add(v);
        out[3].add(l/second);
        out[3].add(a);
        out[3].send();
    } else {
        for (0 => int i; i < NUM_SENDERS; i++) {
            out[i].start("/traverse");
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


// score functions
fun void nodeChanges(dur transition, dur rest) {
    0 => int nodeID;
    0 => int spkr;
    0 => int change;

    while (true) {
        rest => now;

        nodeConfig.getSpeaker(change) => spkr;
        nodeConfig.getNodeID(change) => nodeID;
        switchNode(spkr, nodeID, transition);
        transition => now;

        (change + 1) % 6 => spkr;
    }
}


fun void monophonicCircling(dur l, int n) {
    now => time start;

    0::samp => dur iterationLength;
    0::samp => dur currentTime;
    0.0 => float angle;
    0 => int mod;

    l * 0.25 => dur quarter;
    l * 0.50 => dur half;

    for (0 => int i; i < n; i++) {
        exponentialInterpolation(i, n, l) => iterationLength;
        angleRotation(i, n, 3) => angle;

        now - start => currentTime;

        if (currentTime < quarter) {
            0 => mod;
        } else if (currentTime < half) {
            i % 2 => mod;
        } else {
            i % 3 => mod;
        }

        triggerVoice(mod, iterationLength, angle + mod * 1.0/3.0 * TAU);
        iterationLength => now;
    }
}


fun void polyphonicCircling(dur l, int n) {

    0::samp => dur iterationLength;
    0.0 => float angle;

    for (n - 1 => int i; i >= 0; i--) {
        exponentialInterpolation(i, n, l) => iterationLength;
        angleRotation(i, n, 3) => angle;

        triggerVoice(0, iterationLength, angle);
        triggerVoice(1, iterationLength, (angle + (1.0/3.0) * TAU) % TAU);
        triggerVoice(2, iterationLength, (angle + (2.0/3.0) * TAU) % TAU);
        iterationLength => now;
    }
}

// ~ score

8::minute => dur firstSection;
8::minute => dur secondSection;

(firstSection + secondSection)/nodeConfig.size() => dur transitionTime;

spork ~ nodeChanges(30::second, 30::second);

// first section
monophonicCircling(firstSection, 50);

// second section
polyphonicCircling(secondSection, 20);
