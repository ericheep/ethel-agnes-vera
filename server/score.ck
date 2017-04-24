// Eric Heep
// April 24th, 2017

NodeConfigurations nodeConfig;

3 => int NUM_PIS;
2.0 * pi => float TAU;

OscOut out[NUM_PIS];
0.1::second => now;

// ethel agnes vera local
["ethel.local", "agnes.local", "vera.local", "local.host"] @=> string hosts[];

// init
for (0 => int i; i < NUM_PIS; i++) {
    out[i].dest(hosts[i], 12345);
    0.1::second => now;

    out[i].start("/pi");
    out[i].add(i);
    out[i].send();
}


// osc functions
fun void triggerVoice(int v, dur l, float a) {
    for (0 => int i; i < NUM_PIS; i++) {
        out[i].start("/t");
        out[i].add(v);
        out[i].add(l/second);
        out[i].add(a);
        out[i].send();
    }
}


fun void setNode(int spkr, int ID) {
    for (0 => int i; i < NUM_PIS; i++) {
        out[i].start("/setNode");
        out[i].add(spkr);
        out[i].add(ID);
        out[i].send();
    }
}


fun void switchNode(int spkr, int ID, dur l) {
    for (0 => int i; i < NUM_PIS; i++) {
        out[i].start("/switchNode");
        out[i].add(spkr);
        out[i].add(ID);
        out[i].add(l/second);
        out[i].send();
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
    0 => int count;
    0 => int spkr;
    while (true) {
        rest => now;
        setNode(spkr, ID, transition);
        transition => now;
        (spkr + 1) % 6 => spkr;
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

        // triggerVoice(mod, length, angle + mod * 1.0/3.0 * TAU);
        iterationLength => now;
    }
}


fun void polyphonicCircling(dur l, int n) {

    0::samp => dur iterationLength;
    0.0 => float angle;

    for (n - 1 => int i; i >= 0; i--) {
        exponentialInterpolation(i, n, l) => iterationLength;
        angleRotation(i, n, 3) => angle;

        // triggerVoice(0, length, angle);
        // triggerVoice(1, length, (angle + (1.0/3.0) * TAU) % TAU);
        // triggerVoice(2, length, (angle + (2.0/3.0) * TAU) % TAU);
        iterationLength => now;
    }
}

// ~ score
spork ~ nodeChanges(30::second, 30::second);

// first section
monophonicCircling(5::second, 50);

// second section
polyphonicCircling(8::minute, 20);
