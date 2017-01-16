// lissajou-client.ck
// Eric Heep

OscIn in;
OscMsg msg;

true => int debug;

12345 => in.port;
in.listenAll();

2 => int numSines;
0 => int whichPi;

1::ms => dur update;
0.005 => float freqInc;
0.00025 => float gainInc;
0.001 => float multiplier;
multiplier => float targetMultiplier;
0.01 => float multiplierInc;

SinOsc sin[numSines];
SinOsc pan[numSines];
Gain gain[numSines];
DBAP dbap;
float targetFreq[numSines];
float targetGain[numSines];
float panLevels[4];

dbap.numChannels(4);
dbap.spatialBlur(0.0001);
dbap.rolloff(4.0);

// the spaces is a rectangle, 23x37
// house coordinates in feet [0, 37], [5, 24], [23, 23], [23, 0]
dbap.coordinates([[ 0.0/23.0, 37.0/37.0],
                  [ 5.0/23.0, 24.0/37.0],
                  [23.0/23.0, 23.0/37.0],
                  [23.0/23.0,  0.0/37.0]]);

// 0 => [0L, 1R]
// 1 => [2L, 3R]

for (0 => int i; i < numSines; i++) {
    // setting up the sines
    sin[i] => gain[i] => dac.chan(0);
    sin[i] => gain[i] => dac.chan(1);

    // master gain
    dac.gain(0.2);

    // used only for panning
    pan[i] => blackhole;

    0.0 => sin[i].gain;
    0.0 => sin[i].freq;

    0.3 => gain[i].gain;

    1.0 => pan[i].gain;
    sin[i].freq() * multiplier => pan[i].freq;

    0.0 => targetGain[i];
    0.0 => targetFreq[i];
}

fun void panning() {
    while (true) {
        (pan[0].last() + 1.0) * 0.5 => float x;
        (pan[1].last() + 1.0) * 0.5 => float y;

        dbap.pan([x, y]) @=> panLevels;
        if (whichPi == 0) {
            sin[0].gain(panLevels[0]);
            sin[1].gain(panLevels[1]);
        }
        else if (whichPi == 1) {
            sin[0].gain(panLevels[2]);
            sin[1].gain(panLevels[3]);
        }
        40::samp => now;
    }
}

fun void pollPanningLevels() {
    while (true) {
        (pan[0].last() + 1.0) * 0.5 => float x;
        (pan[1].last() + 1.0) * 0.5 => float y;
        <<< panLevels[0], panLevels[1], panLevels[2], panLevels[3], "freqs", x, y >>>;
        99::ms => now;
    }
}

// spork ~ pollPanningLevels();
spork ~ panning();

fun void easing() {
    float currentFreq;
    float currentGain;
    while (true) {
        for (0 => int i; i < numSines; i++) {
            // sin frequencies
            sin[i].freq() => currentFreq;
            if (currentFreq < targetFreq[i] - freqInc) {
                currentFreq + freqInc => sin[i].freq;
                (currentFreq - freqInc) * multiplier => pan[i].freq;
            }
            else if (currentFreq > targetFreq[i] + freqInc) {
                currentFreq - freqInc => sin[i].freq;
                (currentFreq - freqInc) * multiplier => pan[i].freq;
            }

            // level gains
            gain[i].gain() => currentGain;
            if (currentGain < targetGain[i] - gainInc) {
                currentGain + gainInc => gain[i].gain;
            }
            else if (currentGain > targetGain[i] + gainInc) {
                currentGain - gainInc => gain[i].gain;
            }
        }

        if (multiplier < targetMultiplier - multiplierInc) {
            multiplier + multiplierInc => multiplier;
        }
        else if (multiplier > targetMultiplier + multiplierInc) {
            multiplier - multiplierInc => multiplier;
        }
        update => now;
    }
}

spork ~ easing();

// osc receive
while (true) {
    in => now;
    while (in.recv(msg)) {
        // lets the pi know which one it is
        if (msg.address == "/pi") {
            msg.getInt(0) => whichPi ;

            if (debug) {
                <<< "/pi", whichPi, "" >>>;
            }
        }
        // controls the frequency of a sine wave
        if (msg.address == "/f") {
            msg.getInt(0) => int idx;
            msg.getFloat(1) => float freq;

            freq => targetFreq[idx];

            if (debug) {
                <<< "/f", idx, freq >>>;
            }
        }
        // controls which sine wave to turn down
        if (msg.address == "/g") {
            msg.getInt(0) => int idx;
            msg.getFloat(1) => float lev;

            lev => targetGain[idx];

            if (debug) {
                <<< "/g", idx, lev, "" >>>;
            }
        }
        // controls the rate of sine panning
        if (msg.address == "/m") {
            msg.getFloat(0) => multiplier;

            if (debug) {
                <<< "/m", targetMultiplier, "" >>>;
            }
        }
        if (msg.address == "/p") {
            sin[0].phase(0);
            sin[1].phase(0);
            if (debug) {
                <<< "/p", "phase reset", "" >>>;
            }
        }
    }
}
