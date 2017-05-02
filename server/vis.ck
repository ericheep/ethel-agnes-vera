// Eric Heep
// April 25th, 2017
// vis.ck

3 => int NUM_VOICES;
NUM_VOICES * 2 => int NUM_NODES;
NUM_VOICES * 2 => int NUM_SPKRS;

MIAP m[NUM_VOICES];
MIAPOSCVis v;

int voiceId[NUM_VOICES];
int voiceRunning[NUM_VOICES];
int switching[NUM_VOICES];

// five rows, seven columns
for (0 => int i; i < NUM_VOICES; i++) {
    m[i].generateGrid(7, 7);
}

spork ~ v.oscSend(m[0], m[1], m[2]);

// stores the current node configuration which
// relates to the pi's placement in the grid
int node[NUM_NODES];

// setting our center coordinates (only need to
// pull from one, they're all the same
m[0].nodeX(24) => float X_CENTER;
m[0].nodeY(24) => float Y_CENTER;

Traverse t;
t.setCenter(X_CENTER, Y_CENTER);

OscIn in;
OscMsg msg;

12500 => in.port;
in.listenAll();

// osc event loop
while (true) {
    in => now;
    while (in.recv(msg)) {
        if (msg.address == "/setNode") {
            msg.getInt(0) => int spkr;
            msg.getInt(1) => int nodeID;

            nodeID => node[spkr];
            v.nodeActive(nodeID, 1.0);
        }
        if (msg.address == "/switchNode") {
            msg.getInt(0) => int spkr;
            msg.getInt(1) => int nodeID;
            msg.getFloat(2) => float transitionSeconds;

            spork ~ v.switchNode(node[spkr], nodeID, transitionSeconds::second);
            nodeID => node[spkr];
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
        }
    }
}
