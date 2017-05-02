// Eric Heep
// March 8th, 2017

// quick class for visualizing while composing
// pairs with the miap_visualization.pde Processsing file

public class MIAPOSCVis {
    OscOut out;
    out.dest("127.0.0.1", 12000);

    float m_xPos[3];
    float m_yPos[3];

    public void updatePos(int idx, MIAP m) {
        while (true) {
            m.positionX() => m_xPos[idx];
            m.positionY() => m_yPos[idx];
            1::ms => now;
        }
    }

    public void addAllNodes(MIAP m) {
        while (true) {
            3::second => now;

            for (0 => int i; i < m.numNodes(); i++) {
                out.start("/coord");
                out.add(i);
                out.add(m.nodeX(i));
                out.add(m.nodeY(i));
                out.send();
            }
        }
    }

    public void nodeActive(int idx, float v) {
        out.start("/nodeActive");
        out.add(idx);
        out.add(v);
        out.send();
    }

    public void updateNodeValues(MIAP m1, MIAP m2, MIAP m3) {
        float value;
        for (0 => int i; i < m1.numNodes(); i++) {
            m1.nodeValue(i) + m2.nodeValue(i) + m3.nodeValue(i) => value;

            out.start("/gain");
            out.add(i);
            out.add(value);
            out.send();
        }
    }

    public void updateMIAP(MIAP m, int idx) {
        out.start("/pos");
        out.add(idx);
        out.add(m_xPos[idx]);
        out.add(m_yPos[idx]);
        out.send();

        if (m.activeTriset() >= 0) {
            out.start("/active");
            out.add(idx);
            out.add(1);
            out.send();

            [m.activeNode(0), m.activeNode(1), m.activeNode(2)] @=> int nodeID[];

            for (0 => int i; i < 3; i++) {
                out.start("/activeCoord");
                out.add(idx);
                out.add(i);
                out.add(m.nodeX(nodeID[i]));
                out.add(m.nodeY(nodeID[i]));
                out.send();
            }
        }
        else {
            out.start("/active");
            out.add(idx);
            out.add(0);
            out.send();
        }
    }

    public void switchNode(int prevNodeID, int nodeID, dur len) {
        1::second/30.0 => dur iterationTime;
        (len/iterationTime)$int => int iterations;

        1.0/iterations => float inverseIterations;

        0.0 => float prevValue;
        0.0 => float currValue;
        0.0 => float scalar;

        for (0 => int i; i < iterations; i++) {
            i * inverseIterations => scalar;

            (1.0 - scalar) => prevValue;
            scalar => currValue;

            nodeActive(prevNodeID, prevValue);
            nodeActive(nodeID, currValue);

            iterationTime => now;
        }
    }

    public void oscSend(MIAP m1, MIAP m2, MIAP m3) {
        for (0 => int i; i < m1.numNodes(); i++) {
            nodeActive(i, 0.0);
        }

        spork ~ addAllNodes(m1);

        spork ~ updatePos(0, m1);
        spork ~ updatePos(1, m2);
        spork ~ updatePos(2, m3);

        while (true) {
            updateMIAP(m1, 0);
            samp => now;
            updateMIAP(m2, 1);
            samp => now;
            updateMIAP(m3, 2);
            samp => now;
            updateNodeValues(m1, m2, m3);
            second/60.0 => now;
        }
    }
}
