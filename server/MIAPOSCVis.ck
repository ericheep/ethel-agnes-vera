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
        for (0 => int i; i < m.numNodes(); i++) {
            out.start("/coord");
            out.add(i);
            out.add(m.nodeX(i));
            out.add(m.nodeY(i));
            out.send();
        }
    }

    public void updateNonZeroNodes(MIAP m) {
        for (0 => int i; i < m.numNodes(); i++) {
            if (m.nodeValue(i) > 0) {
                out.start("/gain");
                out.add(i);
                out.add(m.nodeValue(i));
                out.send();
            }
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

    public void oscSend(MIAP m1, MIAP m2, MIAP m3) {
        addAllNodes(m1);

        spork ~ updatePos(0, m1);
        spork ~ updatePos(1, m2);
        spork ~ updatePos(2, m3);

        while (true) {
            updateMIAP(m1, 0);
            samp => now;
            updateNonZeroNodes(m1);
            samp => now;
            updateMIAP(m2, 1);
            samp => now;
            updateNonZeroNodes(m2);
            samp => now;
            updateMIAP(m3, 2);
            samp => now;
            updateNonZeroNodes(m3);
            second/60.0 => now;
        }
    }
}
