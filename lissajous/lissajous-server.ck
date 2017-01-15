// lissajous-sender.ck
// Eric Heep

// Lissajous spatializer, sends OSC to control the four
// speakers via the two receivers
OscOut out[2];

true => int debug;

// ["192.168.1.10", "192.168.1.20"] @=> string IP[];
["127.0.0.1", "127.0.0.2"] @=> string IP[];
12001 => int OUT_PORT;

// 0 => [0L, 1R]
// 1 => [2L, 3R]

for (0 => int i; i < 2; i++) {
    out[i].dest(IP[i], OUT_PORT);
}

fun void sendFreq(int idx, float freq) {
    for (0 => int i; i < 2; i++) {
        out[i].start("/f");
        out[i].add(idx);
        out[i].add(freq);
        out[i].send();
    }
}

fun void sendGain(int idx, float levels[]) {
    for (0 => int i; i < 2; i++) {
        out[i].start("/g");
        out[i].add(idx);
        out[i].add(Std.clampf(levels[i * 2 + 0], 0.0, 1.0));
        out[i].add(Std.clampf(levels[i * 2 + 1], 0.0, 1.0));
        out[i].send();
    }
}


float inc;

fun void sendTest(){
    out[0].start("/l");
    out[0].add((x.last() + 1.0)/2.0);
    out[0].add((y.last() + 1.0)/2.0);
    out[0].send();
}

while (true) {
    //(inc + 0.01) % pi => inc;
    //(Math.sin(inc) + 1.0) * 0.5 => float nSin;
    //sendGain(0, dbap.pan([0.5, nSin]));
    //<<< nSin >>>;
    sendTest();
    1::ms => now;
}
