// Eric Heep
// March 8th, 2017

// quick class for visualizing while composing
// pairs with the miap_visualization.pde Processsing file

public class MIAPOSCVis {
    OscOut out;
    out.dest("127.0.0.1", 12000);

    0.0 => float xPos;
    0.0 => float yPos;

    public void updatePos(float x, float y) {
        x => xPos;
        y => yPos;
    }

    public void oscSend(MIAP m) {
        while (true) {
            out.start("/pos");
            out.add(xPos);
            out.add(yPos);
            out.send();

            for (0 => int i; i < m.nodes.size(); i++) {
                out.start("/coord");
                out.add(i);
                out.add(m.nodes[i].coordinate[0]);
                out.add(m.nodes[i].coordinate[1]);
                out.send();

                // <<< m.nodes[i].coordinate[1], m.nodes[i].coordinate[1] >>>;
                out.start("/gain");
                out.add(i);
                out.add(m.nodes[i].gain);
                out.send();
            }

            if (m.getActiveTriset() >= 0) {
                out.start("/active");
                out.add(1);
                out.send();

                m.getActiveCoordinates() @=> float c[][];

                for (0 => int i; i < c.size(); i++) {
                    out.start("/activeCoord");
                    out.add(i);
                    out.add(c[i][0]);
                    out.add(c[i][1]);
                    out.send();
                }
            }
            else {
                out.start("/active");
                out.add(0);
                out.send();
            }
            second/60.0 => now;
        }
    }
}
