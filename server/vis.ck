// Eric Heep
// April 25th, 2017
// vis.ck

MIAPOSCVis v[NUM_VOICES];

for (int i; i < NUM_VOICES; i++) {
    spork ~ v[i].oscSend(m[i], i);
}

fun void traverseVoice(int idx, dur duration, float angle) {
    // returns the id to the exit array so
    // there is no overlapping, very experimental
    1 => voiceRunning[idx];
    me.id() => voiceId[idx];

    1.0::ms => dur incrementalDuration;
    (duration/incrementalDuration)$int => int numIncrements;
    (numIncrements * 0.5) $int => int halfNumIncrements;

    // one divide instead of like three thousand right?
    1.0/halfNumIncrements => float scalar;

    0.0 => float x;
    0.0 => float y;
    0.0 => float distance;
    0.5 => float radius;

    // from 0.0 to center
    for (halfNumIncrements => int i; i >= 0; i--) {
        i * scalar * radius => distance;

        vectorCoordinateX(Y_CENTER, angle, distance) => x;
        vectorCoordinateY(X_CENTER, angle, distance) => y;
        v[idx].updatePos(x, y);

        incrementalDuration => now;
    }

    // from center to 1.0
    for (0 => int i; i < halfNumIncrements; i++) {
        i * -scalar * radius => distance;

        vectorCoordinateX(X_CENTER, angle, distance) => x;
        vectorCoordinateY(Y_CENTER, angle, distance) => y;
        v[idx].updatePos(x, y);

        incrementalDuration => now;
    }

    0 => voiceRunning[idx];
}


fun void switchNode(int idx, int nodeId, float len) {
    1::ms => dur iterationTime;
    (len::second/iterationTime)$int => int iterations;

    1.0/iterations => float inverseIterations;

    node[idx] => int prevId;
    nodeId => node[idx];

    0.0 => float prevValue;
    0.0 => float currValue;
    0.0 => float scalar;

    1 => switching[idx];

    for (0 => int i; i < iterations; i++) {
        i * inverseIterations => scalar;

        m[idx].nodeValue(prevId) * (1.0 - scalar) => prevValue;
        m[idx].nodeValue(nodeId) * scalar => currValue;

        prevValue + currValue => spkr[idx].gain;
        iterationTime => now;
    }

    0 => switching[idx];
}

fun void updateNodeValues() {
    while(true) {
        for(0 => int i; i < NUM_VOICES; i++) {
            for(0 => int j; j < 2; j++) {
                // we only want to update the gain if that node is NOT switching
                if(!switching[i * 2 + j]) {
                    m[i].nodeValue(node[i * 2 + j]) => spkr[i * 2 + j].gain;
                }
            }
        }
        1::ms => now;
    }
}

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

            spork ~ switchNode(spkr, nodeID, transitionSeconds);
        }
        if (msg.address == "/t") {
            msg.getInt(0) => int idx;
            msg.getFloat(1) => float traverseSeconds;
            msg.getFloat(2) => float angle;

            // just in case
            if (voiceRunning[idx]) {
                Machine.remove(voiceId[idx]);
            }

            spork ~ traverseVoice(idx, traverseSeconds::second, angle);
            spork ~ voice[idx].stretch(traverseSeconds::second);

            if (debugPrint) {
                <<< "/traverse", "voice:", idx, "nodes: [", node[0], node[1], "]", "" >>>;
            }
        }
    }
}
