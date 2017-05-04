// Eric Heep
// April 21st, 2017

// OSC reciever that generates our audio
// or produces our visualizations
3 => int NUM_VOICES;
NUM_VOICES * 2 => int NUM_NODES;
NUM_VOICES * 2 => int NUM_SPKRS;

MIAP m[NUM_VOICES];

int switching[NUM_NODES];

// stores the current node configuration which
// relates to the pi's placement in the grid
int nodeConfig[NUM_NODES];

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

Gain node[NUM_NODES];
Gain gate[NUM_NODES];

["../wavs/ethel.wav","../wavs/agnes.wav","../wavs/vera.wav"] @=> string voicePath[];

for (0 => int i; i < NUM_VOICES; i++) {
    voice[i].read(voicePath[i]);
    voice[i].pos(voice[i].samples());
    voice[i].gain(1.0);
    for (0 => int j; j > NUM_NODES; j++) {
        voice[i] => node[j];
    }
}

for (0 => int i; i < NUM_NODES; i++) {
    node[i] => gate[i];
    gate[i].gain(0.0);
}

gate[0] => dac.left;
gate[1] => dac.right;
gate[2] => dac.left;
gate[3] => dac.right;
gate[4] => dac.left;
gate[5] => dac.right;

// to ensure we don't overload the speakers
dac.gain(0.7);


fun void switchNode(int idx, int nodeID, dur len) {
    1::ms => dur iterationTime;
    (len/iterationTime)$int => int iterations;

    1.0/iterations => float inverseIterations;

    nodeConfig[idx] => int prevID;

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

        prevValue + currValue => node[idx].gain;
        iterationTime => now;
    }

    nodeID => nodeConfig[idx];
    0 => switching[idx];
}


fun void updateNodeValues() {
    // we only want to update the gain if that node is NOT switching
    while(true) {
        for(0 => int i; i < NUM_VOICES; i++) {
            for(0 => int j; j < NUM_NODES; j++) {
                if(!switching[i]) {
                    m[i].nodeValue(nodeConfig[j]) => node[j].gain;
                    <<< m[i].nodeValue(nodeConfig[j]) => node[j].gain >>>;
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
            msg.getInt(0) => int whichPi;

            if (debugPrint) {
                <<< "/pi", whichPi, "" >>>;
            }
            gate[whichPi * 2].gain(1.0);
            gate[whichPi * 2 + 1].gain(1.0);
        }
        if (msg.address == "/setNode") {
            msg.getInt(0) => int spkrID;
            msg.getInt(1) => int nodeID;

            nodeID => nodeConfig[spkrID];
        }
        if (msg.address == "/switchNode") {
            msg.getInt(0) => int spkrID;
            msg.getInt(1) => int nodeID;
            msg.getFloat(2) => float transitionSeconds;

            spork ~ switchNode(spkrID, nodeID, transitionSeconds::second);
        }
        if (msg.address == "/t") {
            msg.getInt(0) => int voiceID;
            msg.getFloat(1) => float traverseSeconds;
            msg.getFloat(2) => float angle;

            spork ~ t.traverseVoice(m[voiceID], voiceID, traverseSeconds::second, angle);
            spork ~ voice[voiceID].stretch(traverseSeconds::second);

            if (debugPrint) {
                <<< "/t", "v:", voiceID, "n: [", nodeConfig[0], nodeConfig[1], nodeConfig[2], nodeConfig[3], nodeConfig[4], nodeConfig[5], "]", "" >>>;
            }
        }
    }
}
