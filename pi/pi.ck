// the same script run on multiple pis

MIAP m;
MIAPOSCVis v;

false => int debugPrint;
true => int debugVis;

// if Processing debug
if(debugVis) {
    spork ~ v.oscSend(m);
}

// five rows, seven columns
m.generateGrid(5, 7);

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

CNoise nois => Gain left => dac.left;
nois => Gain right => dac.right;

left.gain(0.0);
right.gain(0.0);

m.nodes[17].coordinate[0] => float xCenter;
m.nodes[17].coordinate[1] => float yCenter;

0 => int whichPi;
2::second => dur duration;
1.0 => float pow;
0.0 => float angle;

fun float exponentialScale(float x, float pow) {
    return Math.pow(x, pow);
}

fun void moveSound(dur duration, float pow, float angle, float offset) {
    1::ms => dur incrementalDuration;
    (duration/incrementalDuration)$int => int numIncrements;
    (numIncrements * 0.5) $int => int halfNumIncrements;

    1.0/halfNumIncrements => float scalar;

    hexagon[whichPi][0] => int lNode;
    hexagon[whichPi][1] => int rNode;

    float x, y;

    for (halfNumIncrements => int i; i >= 0; i--) {
        xCenter + exponentialScale(-i * scalar, pow) * Math.sin(angle) => x;
        yCenter + exponentialScale(-i * scalar, pow) * Math.cos(angle) => y;

        m.setPosition([x, y]);
        if (debugVis) {
            v.updatePos(x, y);
        }

        left.gain(m.nodes[lNode].gain);
        right.gain(m.nodes[rNode].gain);

        incrementalDuration => now;
    }

    for (0 => int i; i < halfNumIncrements; i++) {
        xCenter + exponentialScale(i * scalar, pow) * Math.sin(angle) => x;
        yCenter + exponentialScale(i * scalar, pow) * Math.cos(angle) => y;

        m.setPosition([x, y]);

        if (debugVis) {
            v.updatePos(x, y);
        }

        left.gain(m.nodes[lNode].gain);
        right.gain(m.nodes[rNode].gain);

        incrementalDuration => now;
    }
}

float inc;

while (true) {
   inc + 0.04 => inc;
   moveSound(400::ms, 1.0, pi * angle + inc, 0);
}

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
            msg.getFloat(1) => float duration;
            msg.getFloat(2) => float angle;
            msg.getFloat(3) => float pow;

            spork ~ moveSound(voice, duration, angle, pow);

            if (debugPrint) {
                <<< "/m", "move", "" >>>;
            }
        }
        if (msg.address == "/a") {
            msg.getFloat(0) => angle;

            if (debugPrint) {
                <<< "/a", "angle", "" >>>;
            }
        }
        if (msg.address == "/d") {
            msg.getFloat(0)::second => duration;

            if (debugPrint) {
                <<< "/d", duration/second, "" >>>;
            }
        }
        if (msg.address == "/p") {
            msg.getFloat(0) => pow;

            if (debugPrint) {
                <<< "/p", pow, "" >>>;
            }
        }
    }
}
