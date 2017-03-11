0::samp => dur runningDuration;
30::second => dur totalIncrementTime;
5::second => dur codaIncrementTime;

0.1000 => float startingInc;
0.0085 => float runningInc;
0.0035 => float codaRunningInc;

3.0 => float exponentialModifier;

1.0/3.0 => float oneThird;
2.0/3.0 => float twoThirds;
0 => int oneThirdLatch;
0 => int twoThirdsLatch;
1 => int nodeChange;

// calculate the entire length of the piece
0::samp => dur totalDuration;
for (startingInc => float i; i < 1.0; runningInc +=> i) {
    Math.pow(i, exponentialModifier) => float scale;
    scale * totalIncrementTime +=> totalDuration;
}

totalDuration/5.0 => dur nodeChangeIncrementTime;

for (startingInc => float i; i < 1.0; runningInc +=> i) {
    Math.pow(i, exponentialModifier) => float scale;
    scale * totalIncrementTime +=> runningDuration;

    if (scale > oneThird && oneThirdLatch != 1) {
        1 => oneThirdLatch;
        <<< "Second Voice:\t", runningDuration/minute >>>;
    }

    if (scale > twoThirds && twoThirdsLatch != 1) {
        1 => twoThirdsLatch;
        <<< "Third Voice:\t", runningDuration/minute >>>;
    }

    // only want 4 node changes in the first section
    if (nodeChange < 5) {
        if (runningDuration > nodeChangeIncrementTime * nodeChange) {
            <<< "Node Change:\t", runningDuration/minute, "\t", nodeChange >>>;
            nodeChange++;
        }
    }
}

// pause
30::second +=> runningDuration;

<<< "Coda Begins:\t", runningDuration/minute >>>;
<<< "Node Change:\t", runningDuration/minute, "\t", nodeChange >>>;

for (1.0 => float i; i > 0.0; codaRunningInc -=> i) {
    Math.pow(i, exponentialModifier) => float scale;
    scale * codaIncrementTime +=> runningDuration;
}

<<< "--", "" >>>;
<<< "Total:", runningDuration/minute >>>;
