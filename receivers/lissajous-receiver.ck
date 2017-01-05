// lissajou-receiver.ck
// Eric Heep

// Simple sine wave oscillator script. Gain routing is setup
// for distance-based amplitude panning (DBAP) spatialization.

OscIn in;
OscMsg msg;

true => int debug;

12345 => in.port;
in.listenAll();

2 => int numSines;

SinOsc sin[numSines];
Gain gain[numSines * 2];

// 0 => [0L, 1R],
// 1 => [2L, 3R], etc.
for (0 => int i; i < numSines; i++) {
    sin[i] => gain[numSines * i + i] => dac.left;
    sin[i] => gain[numSines * i + i] => dac.right;
}

for (0 => int i; i < numSines * 2; i++) {
    gain[i].gain(0.0);
}

// osc receive
while (true) {
    in => now;
    while (in.recv(msg)) {
        if (msg.address == "/f") {
            msg.getInt(0) => int idx;
            msg.getFloat(1) => float freq;

            sin[idx].freq(freq);

            if (debug) {
                <<< "/f", idx, freq >>>;
            }
        }
        if (msg.address == "/g") {
            msg.getInt(0) => int idx;
            msg.getFloat(1) => float left;
            msg.getFloat(2) => float right;

            gain[numSines * idx + idx].gain(left);
            gain[numSines * idx + idx].gain(right);

            if (debug) {
                <<< "/g", idx, left, right >>>;
            }
        }
    }
}
