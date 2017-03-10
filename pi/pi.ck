// the same script run on multiple pis

MIAP m[3];
MIAPOSCVis v[3];

false => int debugPrint;
false => int debugVis;

// if Processing debug
if(debugVis) {
    for (0 => int i; i < m.size(); i++) {
        spork ~ v[i].oscSend(m[i], i);
    }
}

// five rows, seven columns
for (0 => int i; i < m.size(); i++) {
    m[i].generateGrid(7, 7);
}

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


// L, R
[[17, 23],
 [25, 18],
 [31, 32]] @=> int smallHexagon[][];

//               17----18
//               /       \
//              /         \
//            23     *    25
//              \         /
//               \       /
//               31----32

// L, R
[[16, 23],
 [25, 17],
 [32, 33]] @=> int triangles[][];

//         16----17
//          \    /
//           \  /
//            23     *    25
//                        / \
//                       /   \
//                     32----33

// L, R
[[17, 22],
 [26, 25],
 [23, 32]] @=> int heartbeat[][];

//               17
//               / \
//              /   \
//      22----23     *    25----26
//                    \   /
//                     \ /
//                     32

// L, R
[[17, 22],
 [26, 11],
 [37, 32]] @=> int bowtie[][];

//                         11
//                         / \
//                        /   \
//                17-----*     *
//                /             \
//               /               \
//       22-----*     *     *----26
//         \               /
//          \             /
//           *     *----32
//            \   /
//             \ /
//             37

// L, R
[[ 9, 22],
 [26, 11],
 [37, 39]] @=> int largeHexagon[][];

//               9----10----11
//              /             \
//             /               \
//           16                19
//           /                   \
//          /                     \
//        22           *          26
//          \                     /
//           \                   /
//            0                33
//             \               /
//              \             /
//              37----38----39

// sets small hexagon to be the first config
smallHexagon @=> int currentNodeConfiguration[][];

OscIn in;
OscMsg msg;

12345 => in.port;
in.listenAll();

// sound stuff
Gain left => dac.left;
Gain right => dac.right;

left.gain(0.0);
right.gain(0.0);

// ethel
SndBuf ethel => WinFuncEnv ethelEnv => left;
ethelEnv => right;
ethel.read(me.dir() + "../wavs/ethel.wav");
ethel.pos(ethel.samples());

// agnes
SndBuf agnes => WinFuncEnv agnesEnv => left;
agnesEnv => right;
agnes.read(me.dir() + "../wavs/agnes.wav");
agnes.pos(agnes.samples());

// vera
SndBuf vera => WinFuncEnv veraEnv => left;
veraEnv => right;
vera.read(me.dir() + "../wavs/vera.wav");
vera.pos(vera.samples());

// all the sound stuff we're doing
fun void stretch(SndBuf buf, WinFuncEnv env, dur duration, int windows) {
    duration/windows => dur grain;
    grain * 0.5 => dur halfGrain;

    if (halfGrain < 1.0::samp) {
        return;
    }

    env.attack(halfGrain);
    env.release(halfGrain);

    buf.samples()/windows => int sampleIncrement;

    for (0 => int i; i < windows; i++) {
        buf.pos(i * sampleIncrement);
        env.keyOn();
        halfGrain => now;
        env.keyOff();
        halfGrain => now;
    }
}

fun void stretchSound(int voice, dur duration) {
    if (voice == 0) {
        spork ~ stretch(ethel, ethelEnv, duration, 32);
    } else if (voice == 1) {
        spork ~ stretch(agnes, agnesEnv, duration, 32);
    } else if (voice == 2) {
        spork ~ stretch(vera, veraEnv, duration, 32);
    }
}

m[0].nodes[24].coordinate[0] => float xCenter;
m[0].nodes[24].coordinate[1] => float yCenter;

0 => int whichPi;

fun float exponentialScale(float x, float pow) {
    return Math.pow(x, pow);
}

/*0.0 => float inc;
while (true) {
    moveSound(0, 5.0::second, 0.5, inc);
    1.0 +=> inc;
}*/

fun float[] vectorCoordinate(float xOrigin, float yOrigin, float angle, float length) {
    return [xOrigin + Math.cos(angle) * length, yOrigin + Math.sin(angle) * length];
}

// moves a sound from one end to another
fun void moveSound(int voice, dur duration, float pow, float angle) {
    stretchSound(voice, duration);

    1.0::ms => dur incrementalDuration;
    (duration/incrementalDuration)$int => int numIncrements;
    (numIncrements * 0.5) $int => int halfNumIncrements;

    1.0/halfNumIncrements => float scalar;

    currentNodeConfiguration[whichPi][0] => int lNode;
    currentNodeConfiguration[whichPi][1] => int rNode;

    float x, y;
    float coordinate[2];
    float expScalar;

    0.5 => float radius;

    for (halfNumIncrements => int i; i >= 0; i--) {
        exponentialScale(i * scalar, pow) => expScalar;
        vectorCoordinate(xCenter, yCenter, angle, expScalar * radius) @=> coordinate;

        coordinate[0] => x;
        coordinate[1] => y;

        m[voice].setPosition([x, y]);
        if (debugVis) {
            v[voice].updatePos(x, y);
        }

        left.gain(m[voice].nodes[lNode].gain);
        right.gain(m[voice].nodes[rNode].gain);

        // <<< x, y >>>;
        incrementalDuration => now;
    }

    for (0 => int i; i < halfNumIncrements; i++) {
        exponentialScale(i * scalar, pow) => expScalar;
        vectorCoordinate(xCenter, yCenter, angle, -expScalar * radius) @=> coordinate;

        coordinate[0] => x;
        coordinate[1] => y;

        m[voice].setPosition([x, y]);

        if (debugVis) {
            v[voice].updatePos(x, y);
        }

        left.gain(m[voice].nodes[lNode].gain);
        right.gain(m[voice].nodes[rNode].gain);

        // <<< x, y >>>;
        incrementalDuration => now;
    }
}

fun void shiftNode(int nodeConfig) {
    if (nodeConfig == 0) {
        smallHexagon @=> currentNodeConfiguration;
    }
    if (nodeConfig == 1) {
        triangles @=> currentNodeConfiguration;
    }
    if (nodeConfig == 2) {
        heartbeat @=> currentNodeConfiguration;
    }
    if (nodeConfig == 3) {
        bowtie @=> currentNodeConfiguration;
    }
    if (nodeConfig == 4) {
        largeHexagon @=> currentNodeConfiguration;
    }

}

float seconds[3];
float angle[3];
float pow[3];

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
        if (msg.address == "/n") {
            msg.getInt(0) => int nodeConfiguration;

            if (debugPrint) {
                <<< "/n", nodeConfiguration, "" >>>;
            }
        }
        if (msg.address == "/p") {
            msg.getInt(0) => int voice;
            msg.getFloat(1) => seconds[voice];
            msg.getFloat(2) => angle[voice];
            msg.getFloat(3) => pow[voice];


            if (debugPrint) {
                <<< "/p", "seconds: ", seconds[voice], "angle: ", angle[voice], "pow: ", pow[voice]>>>;
            }
        }
        if (msg.address == "/m") {
            msg.getInt(0) => int voice;

            spork ~ moveSound(voice, seconds[voice]::second, pow[voice], angle[voice]);

            if (debugPrint) {
                <<< "/m", voice, "" >>>;
            }
        }
    }
}
