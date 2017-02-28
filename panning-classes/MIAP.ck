// Eric Heep

// Manifold-Something Amplitude Panning
// white paper locked behind a paywall

public class MIAP {

    float gain[0];
    float m_coordinates[0][2];

    int m_numNodes;

    private void init() {
        4 => m_numNodes;
        numNodes(m_numNodes);
    }

    init();

    public void numNodes(int n) {
        n => m_numNodes;
        gain.size(m_numNodes);
    }

    public void setCoordinates(float c[][]) {
        for (0 => int i; i < c.size(); i++) {
            c[i] @=> m_coordinates;
        }
    }

    private void computerTrisets

}

MIAP m;

m.numNodes(3);
m.setCoordinates([[0.0, 0.0],
                  [1.0, 0.0],
                  [1.0, 1.0],
                  [0.0, 1.0]]);


