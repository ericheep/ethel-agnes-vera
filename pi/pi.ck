// Eric Heep
// March 10th, 2017

// OSC reciever that generates our audio
// and calculates the MIAP algorithm
// this script is 'stateless', and relies
// entirely on the OSC sender

MIAP m[3];
MIAPOSCVis v[3];

for (int i; i < 3; i++) {
    spork ~ v[i].oscSend(m[i], i);
}

int voiceId[3];
int voiceRunning[3];

// very important variable
0 => int whichPi;

// stores the current node configuration which
// relates to the pi's placement in the grid
int piNodes[2];

// turn off for speed
true => int debugPrint;

// five rows, seven columns
for (0 => int i; i < m.size(); i++) {
    m[i].generateGrid(7, 7);
}

// setting our center coordinates (only need to
// pull from one, they're all the same
m[0].nodes[24].coordinate[0] => float xCenter;
m[0].nodes[24].coordinate[1] => float yCenter;

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

// the array below defines the speaker nodes for
// the three Raspberry Pis

// for example:
// ethel [17, 23]
// agnes [25, 18]
// vera  [31, 32]

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

//               9-----*----11
//              /             \
//             /               \
//            *                 *
//           /                   \
//          /                     \
//        22           *          26
//          \                     /
//           \                   /
//            *                 *
//             \               /
//              \             /
//              37-----*----39

OscIn in;
OscMsg msg;

12345 => in.port;
in.listenAll();

// sound stuff
Gain left => dac.left;
Gain right => dac.right;

left.gain(1.0);
right.gain(1.0);

// ethel
Gain ethelLeft;
Gain ethelRight;

SndBuf ethel => WinFuncEnv ethelEnv => ethelLeft => left;
ethelEnv => ethelRight => right;
ethel.read(me.dir() + "../wavs/ethel.wav");
ethel.pos(ethel.samples());

// agnes
Gain agnesLeft;
Gain agnesRight;

SndBuf agnes => WinFuncEnv agnesEnv => agnesLeft => left;
agnesEnv => agnesRight => right;
agnes.read(me.dir() + "../wavs/agnes.wav");
agnes.pos(agnes.samples());

// vera
Gain veraLeft;
Gain veraRight;

SndBuf vera => WinFuncEnv veraEnv => veraLeft => left;
veraEnv => veraRight => right;
vera.read(me.dir() + "../wavs/vera.wav");
vera.pos(vera.samples());

// oh yea! turn it up! (default values)
ethel.gain(0.5);
agnes.gain(0.5);
vera.gain(0.5);

dac.gain(0.9);

// all the sound stuff we're doing
fun void startVoice(SndBuf buf, WinFuncEnv env, dur duration, int windows) {
    duration/windows => dur grain;
    grain * 0.5 => dur halfGrain;

    // for some reason if you try to put a sample
    // at a fraction of samp, it will silence ChucK
    if (halfGrain < 1.0::samp) {
        return;
    }

    // envelope parameters
    env.attack(halfGrain);
    env.release(halfGrain);

    halfGrain/samp => float halfGrainSamples;
    buf.samples()/windows => int sampleIncrement;

    // bulk of the time stretching
    for (0 => int i; i < windows; i++) {
        buf.pos(i * sampleIncrement);

        (i * sampleIncrement)::samp + grain => dur end;

        // only fade if there will be no discontinuity errors
        if (end < buf.samples()::samp) {
            env.keyOn();
            halfGrain => now;
            env.keyOff();
            halfGrain => now;
        }
    }
}


fun float exponentialScale(float x, float pow) {
    return Math.pow(x, pow);
}

fun float[] vectorCoordinate(float xOrigin, float yOrigin, float angle, float length) {
    return [xOrigin + Math.cos(angle) * length, yOrigin + Math.sin(angle) * length];
}

// moves a sound from one end to another
fun void moveVoice(int voice, Gain leftGain, Gain rightGain, dur duration, float pow, float angle, int nodes[]) {

    // returns the id to the exit array so
    // there is no overlapping, very experimental
    1 => voiceRunning[voice];
    me.id() => voiceId[voice];

    // increase this maybe for less spatial
    // resolution but more processing
    1.0::ms => dur incrementalDuration;

    // the number of times we can increment and
    // stay within the duration specified
    (duration/incrementalDuration)$int => int numIncrements;
    (numIncrements * 0.5) $int => int halfNumIncrements;

    // one divide instead of like three thousand right?
    1.0/halfNumIncrements => float scalar;

    float coordinate[2];
    0.0 => float expScalar;
    0.5 => float radius;

    // from 0.0 to center
    for (halfNumIncrements => int i; i >= 0; i--) {
        i * scalar => expScalar;
        vectorCoordinate(xCenter, yCenter, angle, expScalar * radius) @=> coordinate;

        m[voice].setPosition(coordinate);
        // v[voice].updatePos(coordinate[0], coordinate[1]);

        // adjust the proper gain UGens
        leftGain.gain(m[voice].nodes[nodes[0]].gain);
        rightGain.gain(m[voice].nodes[nodes[1]].gain);

        incrementalDuration => now;
    }

    // from center to 1.0
    for (0 => int i; i < halfNumIncrements; i++) {
        i * scalar => expScalar;
        vectorCoordinate(xCenter, yCenter, angle, -expScalar * radius) @=> coordinate;

        m[voice].setPosition(coordinate);
        // v[voice].updatePos(coordinate[0], coordinate[1]);

        // adjust the proper gain UGens
        leftGain.gain(m[voice].nodes[nodes[0]].gain);
        rightGain.gain(m[voice].nodes[nodes[1]].gain);

        incrementalDuration => now;
    }

    0 => voiceRunning[voice];
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
        if (msg.address == "/n") {
            msg.getInt(0) => int nodeConfiguration;
            msg.getInt(1) => int whichPi;

            if (nodeConfiguration == 0) {
                smallHexagon[whichPi] @=> piNodes;
            }
            if (nodeConfiguration == 1) {
                triangles[whichPi] @=> piNodes;
            }
            if (nodeConfiguration == 2) {
                heartbeat[whichPi] @=> piNodes;
            }
            if (nodeConfiguration == 3) {
                bowtie[whichPi] @=> piNodes;
            }
            if (nodeConfiguration == 4) {
                largeHexagon[whichPi] @=> piNodes;
            }
        }
        if (msg.address == "/m") {
            msg.getInt(0) => int voice;
            msg.getFloat(1) => float seconds;
            msg.getFloat(2) => float angle;
            msg.getFloat(3) => float pow;

            // just in case
            if (voiceRunning[voice]) {
                Machine.remove(voiceId[voice]);
            }

            // ethel
            if (voice == 0) {
                spork ~ moveVoice(voice, ethelLeft, ethelRight,
                                  seconds::second, angle, pow, piNodes);
                spork ~ startVoice(ethel, ethelEnv, seconds::second, 32);
            }
            // agnes
            else if (voice == 1) {
                spork ~ moveVoice(voice, agnesLeft, agnesRight,
                                  seconds::second, angle, pow, piNodes);
                spork ~ startVoice(agnes, agnesEnv, seconds::second, 32);
            }
            // vera
            else if (voice == 2) {
                spork ~ moveVoice(voice, veraLeft, veraRight,
                                  seconds::second, angle, pow, piNodes);
                spork ~ startVoice(vera, veraEnv, seconds::second, 32);
            }

            if (debugPrint) {
                <<< "/m", "voice:", voice, "nodes: [", piNodes[0], piNodes[1], "]", "" >>>;
            }
        }
    }
}
