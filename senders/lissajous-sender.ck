OscOut out[2];

["127.0.0.1", "198.167.1.11"] @=> string IP[];
12345 => int OUT_PORT;

fun void sendFloat(string addr, int idx, float val) {
    int whichPi;
    if (idx < 2) {
        0 => whichPi;
    }
    else {
        1 => whichPi;
    }

    out[whichPi].start(addr);
    out[whichPi].add(idx % 2);
    out[whichPi].add(val);
    out[whichPi].send();

}

fun void send(string addr, int idx, int val) {
    int whichPi;
    if (idx < 2) {
        0 => whichPi;
    }
    else {
        1 => whichPi;
    }

    out[whichPi].start(addr);
    out[whichPi].add(idx % 2);
    out[whichPi].add(val);
    out[whichPi].send();
}

while (true) {
    control();
    1::ms => now;
}
