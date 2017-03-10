// the same script run on multiple pis

MIAP m[3];
MIAPOSCVis v[3];

true => int debugPrint;
false => int debugVis;

// if Processing debug
if(debugVis) {
    for (0 => int i; i < m.size(); i++) {
        spork ~ v[i].oscSend(m[i]);
    }
}

// five rows, seven columns
for (0 => int i; i < m.size(); i++) {
    m[i].generateGrid(5, 7);
}

//        *-----*-----*-----*-----*-----*-----*
//         \   / \   / \   / \   / \   / \   / \
//          \ /   \ /   \ /   \ /   \ /   \ /   \
//           *-----8-----9----10----11----12-----*
//          / \   / \   / \   / \   / \   / \   /
//         /   \ /   \ /   \ /   \ /   \ /   \ /
//        *----15----16----17----18----19-----*
//         \   / \   / \   / \   / \   / \   / \
//          \ /   \ /   \ /   \ /   \ /   \ /   \
//           *----22----23----24----25----26-----*
//          / \   / \   / \   / \   / \   / \   /
//         /   \ /   \ /   \ /   \ /   \ /   \ /
//        *-----*-----*-----*-----*-----*-----*

// L, R
[[ 9, 16],
 [18, 10],
 [23, 24]] @=> int hexagon[][];

//                  9----10
//                 / \   / \
//                /   \ /   \
//              16-----*----18
//                \   / \   /
//                 \ /   \ /
//                 23----24

// L, R
[[ 8, 15],
 [19, 10],
 [23, 25]] @=> int zigzag[][];

//            8          10
//           / \         / \
//          /   \       /   \
//        15-----*-----*-----*----19
//                \   /       \   /
//                 \ /         \ /
//                 23          25

// L, R
[[ 8, 10],
 [26, 12],
 [22, 24]] @=> int rectangle[][];

//         8-----*----10-----*----12
//          \   / \   / \   / \   /
//           \ /   \ /   \ /   \ /
//            *-----*-----*-----*
//           / \   / \   / \   / \
//          /   \ /   \ /   \ /   \
//        22-----*----24-----*----26

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

m[0].nodes[17].coordinate[0] => float xCenter;
m[0].nodes[17].coordinate[1] => float yCenter;

0 => int whichPi;

fun float exponentialScale(float x, float pow) {
    return Math.pow(x, pow);
}

// moves a sound from one end to another
fun void moveSound(int voice, dur duration, float pow, float angle) {
    stretchSound(voice, duration);

    0.5::ms => dur incrementalDuration;
    (duration/incrementalDuration)$int => int numIncrements;
    (numIncrements * 0.5) $int => int halfNumIncrements;

    1.0/halfNumIncrements => float scalar;

    hexagon[whichPi][0] => int lNode;
    hexagon[whichPi][1] => int rNode;

    float x, y;

    for (halfNumIncrements => int i; i >= 0; i--) {
        xCenter + exponentialScale(-i * scalar, pow) * Math.sin(angle) => x;
        yCenter + exponentialScale(-i * scalar, pow) * Math.cos(angle) => y;

        m[voice].setPosition([x, y]);
        if (debugVis) {
            v[voice].updatePos(x, y);
        }

        left.gain(m[voice].nodes[lNode].gain);
        right.gain(m[voice].nodes[rNode].gain);

        incrementalDuration => now;
    }

    for (0 => int i; i < halfNumIncrements; i++) {
        xCenter + exponentialScale(i * scalar, pow) * Math.sin(angle) => x;
        yCenter + exponentialScale(i * scalar, pow) * Math.cos(angle) => y;

        m[voice].setPosition([x, y]);

        if (debugVis) {
            v[voice].updatePos(x, y);
        }

        left.gain(m[voice].nodes[lNode].gain);
        right.gain(m[voice].nodes[rNode].gain);

        incrementalDuration => now;
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
