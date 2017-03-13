4::second => dur totalIncrementTime;
5::second => dur codaIncrementTime;

0.0015 => float runningInc;

4.0 => float exponentialModifier;

1.0/3.0 => float oneThird;
2.0/3.0 => float twoThirds;

0 => int oneThirdLatch;
0 => int twoThirdsLatch;
0 => int nodeChange;

// calculate the entire length of the piece
0::samp => dur totalDuration;

for (1.0 => float i; i > 0.0; runningInc -=> i) {
    Math.pow(i, exponentialModifier) => float scale;
    scale * totalIncrementTime => dur duration;
    duration +=> totalDuration;
}

totalDuration * 2 => totalDuration;

0 => oneThirdLatch;
0 => twoThirdsLatch;

totalDuration/6.0 => dur nodeChangeIncrementTime;
totalDuration/4.0 => dur voiceAddIncrementTime;

0::samp => dur runningDuration;
for (1.0 => float i; i > 0.0; runningInc -=> i) {
    Math.pow(i, exponentialModifier) => float scale;
    scale * totalIncrementTime => dur duration;

    // first voice
    duration +=> runningDuration;

    if (runningDuration > voiceAddIncrementTime * 1) {
        // second voice
        duration +=> runningDuration;
        if (oneThirdLatch == 0) {
            <<< "Second Voice:\t", runningDuration/minute >>>;
            1 => oneThirdLatch;
        }
    }

    if (runningDuration > voiceAddIncrementTime * 2) {
        // third voice
        duration +=> runningDuration;
        if (twoThirdsLatch == 0) {
            <<< "Third Voice:\t", runningDuration/minute >>>;
            1 => twoThirdsLatch;
        }
    }

    // only want 4 node changes in the first section
    if (nodeChange < 4) {
        if (runningDuration > nodeChangeIncrementTime * nodeChange) {
            <<< "Node Change:\t", runningDuration/minute, "\t", nodeChange >>>;
            nodeChange++;
        }
    }
}

<<< "--", "" >>>;
<<< "Total:", runningDuration/minute >>>;
