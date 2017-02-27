// noise-test-server.ck
// Eric Heep

OscOut agnes;
OscOut ethel;

12345 => int OUT_PORT;
agnes.dest("192.168.1.10", OUT_PORT);
ethel.dest("192.168.1.20", OUT_PORT);

10::ms => now;

true => int debug;

// 0 => [0L, 1R]
// 1 => [2L, 3R]

sendWhichPi();

fun void sendWhichPi() {
    agnes.start("/pi");
    agnes.add(0);
    agnes.send();

    ethel.start("/pi");
    ethel.add(1);
    ethel.send();
}

fun void sendCoords(float x, float y) {
    agnes.start("/c");
    agnes.add(x);
    agnes.add(y);
    agnes.send();

    ethel.start("/c");
    ethel.add(x);
    ethel.add(y);
    ethel.send();
}

fun void sendGain(float gain) {
    agnes.start("/g");
    agnes.add(gain);
    agnes.send();

    ethel.start("/g");
    ethel.add(gain);
    ethel.send();
}
sendGain(0.0);

SinOsc sinX => blackhole;
SinOsc sinY => blackhole;
sinX.freq(1);
sinY.freq(0.10);

while (true) {
    sendCoords(0.5, (sinX.last() + 1.0)/2.0);
    10::ms => now;
}

