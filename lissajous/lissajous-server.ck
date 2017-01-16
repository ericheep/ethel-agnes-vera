// lissajous-sender.ck
// Eric Heep

// Lissajous spatializer, sends OSC to control the four
// speakers via the two receivers
OscOut out[2];

true => int debug;

// ["192.168.1.10", "192.168.1.20"] @=> string IP[];
["127.0.0.1", "127.0.0.2"] @=> string IP[];
12345 => int OUT_PORT;

// 0 => [0L, 1R]
// 1 => [2L, 3R]

220.0 => float freqOne;
220.0 => float freqTwo;
0.1 => float gainOne;
0.1 => float gainTwo;
0.0001 => float multiplier;

for (0 => int i; i < 2; i++) {
    out[i].dest(IP[i], OUT_PORT);
}

fun void sendWhichPi() {
    for (0 => int i; i < 2; i++) {
        out[i].start("/pi");
        out[i].add(i);
        out[i].send();
    }
}

fun void sendFreq(int idx, float freq) {
    for (0 => int i; i < 2; i++) {
        out[i].start("/f");
        out[i].add(idx);
        out[i].add(freq);
        out[i].send();
    }
}

fun void sendGain(int idx, float gain) {
    for (0 => int i; i < 2; i++) {
        out[i].start("/g");
        out[i].add(idx);
        out[i].add(gain);
        out[i].send();
    }
}

fun void sendMultiplier(float m) {
    for (0 => int i; i < 2; i++) {
        out[i].start("/m");
        out[i].add(m);
        out[i].send();
    }
}

sendWhichPi();
sendFreq(0, freqOne);
sendGain(0, freqTwo);
sendFreq(1, gainOne);
sendGain(1, gainTwo);
sendMultiplier(multiplier);
