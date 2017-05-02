// Eric Heep
// April 21st, 2017

// OSC reciever that generates our audio
// or produces our visualizations
3 => int NUM_VOICES;
NUM_VOICES * 2 => int NUM_NODES;
NUM_VOICES * 2 => int NUM_SPKRS;

MIAP m[NUM_VOICES];

int voiceId[NUM_VOICES];
int voiceRunning[NUM_VOICES];
int switching[NUM_NODES];

// very important variable
0 => int whichPi;

// stores the current node configuration which
// relates to the pi's placement in the grid
int node[NUM_NODES];

// turn off for speed
true => int debugPrint;

// five rows, seven columns
for (0 => int i; i < m.size(); i++) {
    m[i].generateGrid(7, 7);
}

// setting our center coordinates (only need to
// pull from one, they're all the same
m[0].nodeX(24) => float X_CENTER;
m[0].nodeY(24) => float Y_CENTER;

//        *-----*-----*-----*-----*-----*-----*
//         \   / \   / \   / \   / \   / \   / \
//          \ /   \ /   \ /   \ /   \ /   \ /   \
//           *-----*-----9----10----11-----*-----*
//          / \   / \   / \   / \   / \   / \   /
//         /   \ /   \ /   \ /   \ /   \ /   \ /
//        *-----*----16----17----18----19-----*
//         \   / \   / \   / \   / \   / \   / \
//          \ /   \ /   \ /   \ /   \ /   \ /   \
//           *----22----23----24----25----26-----*
//          / \   / \   / \   / \   / \   / \   /
//         /   \ /   \ /   \ /   \ /   \ /   \ /
//        *-----*----30----31----32----33-----*
//         \   / \   / \   / \   / \   / \   / \
//          \ /   \ /   \ /   \ /   \ /   \ /   \
//           *-----*----37----38----39-----*-----*
//          / \   / \   / \   / \   / \   / \   /
//         /   \ /   \ /   \ /   \ /   \ /   \ /
//        *-----*-----*-----*-----*-----*-----*

Traverse t;
t.setCenter(X_CENTER, Y_CENTER);

OscIn in;
OscMsg msg;

12345 => in.port;
in.listenAll();
SndBufStretch voice[NUM_VOICES];

Gain spkr[NUM_NODES];

["../wavs/ethel.wav","../wavs/agnes.wav","../wavs/vera.wav"] @=> string voicePath[];

for (0 => int i; i < NUM_VOICES; i++) {
    voice[i].read(voicePath[i]);
    voice[i].pos(voice[i].samples());
    voice[i].gain(1.0);
}

voice[0] => spkr[0] => dac.left;
voice[0] => spkr[1] => dac.right;

voice[1] => spkr[2] => dac.left;
voice[1] => spkr[3] => dac.right;

voice[2] => spkr[4] => dac.left;
voice[2] => spkr[5] => dac.right;

// to ensure we don't overload the speakers
dac.gain(0.8);

fun void switchNode(int idx, int nodeID, dur len) {
    1::ms => dur iterationTime;
    (len/iterationTime)$int => int iterations;

    1.0/iterations => float inverseIterations;

    node[idx] => int prevID;

    <<< "P:", prevID, " C:", nodeID, "" >>>;

    0.0 => float prevValue;
    0.0 => float currValue;
    0.0 => float scalar;

    1 => switching[idx];

    for (0 => int i; i < iterations; i++) {
        i * inverseIterations => scalar;

        for (0 => int j; j < 3; j++) {
            m[j].nodeValue(prevID) * (1.0 - scalar) => prevValue;
            m[j].nodeValue(nodeID) * scalar => currValue;
        }

        prevValue + currValue => spkr[idx].gain;
        iterationTime => now;
    }

    nodeID => node[idx];
    0 => switching[idx];
}


fun void updateNodeValues() {
    // we only want to update the gain if that node is NOT switching
    while(true) {
        for(0 => int i; i < NUM_VOICES; i++) {
            for(0 => int j; j < 2; j++) {
                if(!switching[i * 2 + j]) {
                    m[i].nodeValue(node[i * 2 + j]) => spkr[i * 2 + j].gain;
                }
            }
        }
        1::ms => now;
    }
}

spork ~ updateNodeValues();

// osc event loop
while (true) {
    in => now;
    while (in.recv(msg)) {
        if (msg.address == "/pi") {
            msg.getInt(0) => whichPi;

            if (debugPrint) {
                <<< "/pi", whichPi, "" >>>;
            }
        }
        if (msg.address == "/setNode") {
            msg.getInt(0) => int spkr;
            msg.getInt(1) => int nodeID;

            nodeID => node[spkr];
        }
        if (msg.address == "/switchNode") {
            msg.getInt(0) => int spkr;
            msg.getInt(1) => int nodeID;
            msg.getFloat(2) => float transitionSeconds;

            spork ~ switchNode(spkr, nodeID, transitionSeconds::second);
        }
        if (msg.address == "/traverse") {
            msg.getInt(0) => int idx;
            msg.getFloat(1) => float traverseSeconds;
            msg.getFloat(2) => float angle;

            // just in case
            if (voiceRunning[idx]) {
                Machine.remove(voiceId[idx]);
            }

            spork ~ t.traverseVoice(m[idx], idx, traverseSeconds::second, angle);
            spork ~ voice[idx].stretch(traverseSeconds::second);

            if (debugPrint) {
                <<< "/traverse", "voice:", idx, "nodes: [", node[0], node[1], node[2], node[3], node[4], node[5], "]", "" >>>;
            }
        }
    }
}
