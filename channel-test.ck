Noise nois;

nois.gain(0.1);

int m;

while (true) {
    <<< "Channel:", m, "" >>>;
    nois => dac.chan(m);
    5::second => now;
    nois =< dac.chan(m);
    (1 + m) % 2 => m;
}

