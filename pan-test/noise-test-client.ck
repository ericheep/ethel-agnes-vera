// lissajou-client.ck
// Eric Heep

OscIn in;
OscMsg msg;

true => int debug;

12345 => in.port;
in.listenAll();

0 => int whichPi;

CNoise pink;
Gain gain[2];

DBAP dbap;
dbap.numChannels(4);
dbap.spatialBlur(0.0001);
dbap.rolloff(4.0);

// the spaces is a rectangle, 8x11
// house coordinates in feet [0, 37], [5, 24], [23, 23], [23, 0]
dbap.coordinates([[ 0.0/11.0, 0.0/11.0],
                  [ 0.0/11.0, 8.0/11.0],
                  [11.0/11.0, 0.0/11.0 ],
                  [11.0/11.0, 8.0/11.0]]);

// 0 => [0L, 1R]
// 1 => [2L, 3R]

// two speakers
for (0 => int i; i < 2; i++) {
    // setting up the sines
    pink => gain[i] => dac.chan(i);

    // master gain
    dac.gain(0.05);
}

fun void pan(float x, float y) {
    dbap.pan([x, y]) @=> float panLevels[];

    if (whichPi == 0) {
        gain[0].gain(panLevels[0]);
        gain[1].gain(panLevels[1]);
    }
    else if (whichPi ==1) {
        gain[0].gain(panLevels[2]);
        gain[1].gain(panLevels[3]);
    }
}

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
        if (msg.address == "/c") {
            msg.getFloat(0) => float x;
            msg.getFloat(1) => float y;

            pan(x, y);

            if (debug) {
                <<< "/c", x, y, "" >>>;
            }
        }
        // controls which sine wave to turn down
        if (msg.address == "/g") {
            msg.getFloat(0) => float g;

            pink.gain(g);

            if (debug) {
                <<< "/g", g, "" >>>;
            }
        }
    }
}
