// lissajous-sender.ck
// Eric Heep

// Lissajous spatializer, sends OSC to control the four
// speakers via the two receivers
OscOut agnes;
OscOut ethel;

12345 => int OUT_PORT;
agnes.dest("192.168.1.15", OUT_PORT);
ethel.dest("192.168.1.20", OUT_PORT);

10::ms => now;

true => int debug;

// 0 => [0L, 1R]
// 1 => [2L, 3R]

220.0 => float freqOne;
220.0 => float freqTwo;
1.0 => float gainOne;
1.0 => float gainTwo;
0.0001 => float multiplier;

fun void sendWhichPi() {
    agnes.start("/pi");
    agnes.add(0);
    agnes.send();

    ethel.start("/pi");
    ethel.add(1);
    ethel.send();
}

fun void sendFreq(int idx, float freq) {
    agnes.start("/f");
    agnes.add(0);
    agnes.add(freq);
    agnes.send();

    ethel.start("/f");
    ethel.add(1);
    ethel.add(freq);
    ethel.send();
}

fun void sendPhaseReset() {
    agnes.start("/p");
    agnes.add(0);
    agnes.send();

    ethel.start("/p");
    ethel.add(1);
    ethel.send();
}

fun void sendGain(int idx, float gain) {
    agnes.start("/g");
    agnes.add(0);
    agnes.add(gain);
    agnes.send();

    ethel.start("/g");
    ethel.add(1);
    ethel.add(gain);
    ethel.send();
}

fun void sendMultiplier(float m) {
    agnes.start("/m");
    agnes.add(m);
    agnes.send();

    ethel.start("/m");
    ethel.add(m);
    ethel.send();
}

//sendWhichPi();
//sendPhaseReset();
// sendFreq(0, 800);
// sendGain(0, 0.1);
// sendMultiplier(0.001);
// sendFreq(1, 660);
// sendGain(1, 0.1);
100::ms => now;
