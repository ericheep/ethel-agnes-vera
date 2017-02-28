// Eric Heep

// Manifold-Something Amplitude Panning
// white paper locked behind a paywall

public class MIAP {

    class Node {

        float coordinate[2];
        float gain;

        int trisets[0];

        fun void setGain(float g) {
            g => gain;
        }

        fun void setCoordinate(float c[]) {
            c @=> coordinate;
        }

        fun void setTrisets(int t[]) {
            t @=> trisets;
        }
    }

    Node nodes[0];
    int trisets[0];

    public void addNode(float coordinate[], int trisets[]) {
        Node node;
        node.setCoordinate(coordinate);
        node.setTrisets(trisets);
        nodes << node;
        updateTrisets();
    }

    public void updateTrisets() {
        int allTrisets[0];
        int uniqueTrisets[0];

        for (0 => int i; i < nodes.size(); i++) {
            for (0 => int j; j < nodes[i].trisets.size(); j++) {
                allTrisets << nodes[i].trisets[j];
            }
        }

        for (0 => int i; i < allTrisets.size(); i++) {
            0 => int j;
            for (0 => j; j < i; j++) {
                if (allTrisets[i] == allTrisets[j]) break;
            }
            if (i == j) uniqueTrisets << allTrisets[i];
        }

        uniqueTrisets @=> trisets;
    }

    public void setPosition(float position[]) {
        0 => int whichTriset;
        float trisetCoordinates[3][2];
        0 => int trisetIdx;

        for (0 => int i; i < nodes.size(); i++) {
            if (nodeInTriset(nodes[i], whichTriset)) {
                nodes[i].coordinate @=> trisetCoordinates[i];
                trisetIdx++;
            }
        }
        <<< trisetCoordinates[0][1], trisetCoordinates[0][0] >>>;
    }

    public int nodeInTriset(Node node, int triset) {
        for (0 => int i; i < node.trisets.size(); i++) {
            if (node.trisets[i] == triset) {
                return 1;
            }
        }
        return 0;
    }

    private int pointInTriset(float P[], float A[], float B[], float C[]) {
        // compute vectors
        computeVector(C, A) @=> float v0[];
        computeVector(B, A) @=> float v1[];
        computeVector(P, A) @=> float v2[];

        // compute dot products
        dotProduct(v0, v0, 2) => float dot00;
        dotProduct(v0, v1, 2) => float dot01;
        dotProduct(v0, v2, 2) => float dot02;
        dotProduct(v1, v1, 2) => float dot11;
        dotProduct(v1, v2, 2) => float dot12;

        // compute barycentric coordinates
        1.0/(dot00 * dot11 - dot01 * dot01) => float invDenom;
        (dot11 * dot02 - dot01 * dot12) * invDenom => float u;
        (dot00 * dot12 - dot01 * dot02) * invDenom => float v;

        // check if point is in triangle
        return (u >= 0) && (v >= 0) && ((u + v) < 1);
    }

    private float[] computeVector(float R[], float S[]) {
        return [R[0] - S[0], R[1] - S[1]];
    }

    private float dotProduct(float v[], float u[], int n) {
        0.0 => float result;

        for (0 => int i; i < n; i++) {
            v[i]*u[i] +=> result;
        }

        return result;
    }
}

MIAP m;

m.addNode([0.0, 0.0], [0]);
m.addNode([0.0, 1.0], [0, 1]);
m.addNode([1.0, 0.0], [0, 1]);
m.addNode([1.0, 1.0], [1]);

m.setPosition([0.1, 0.1]);

// <<< m.pointInPoly([0.1, 1.1], [0.0, 0.0], [0.0, 1.0], [1.0, 0.0]) >>>;

