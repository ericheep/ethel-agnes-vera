// Eric Heep

// Manifold-Something Amplitude Panning
// white paper locked behind a paywall

class Node {

    float x, y;
    float triset;
    float gain;

    fun void setGain(float g) {
        g => gain;
    }

    fun void setCoordinates(float c[]) {
        c[0] => x;
        c[1] => y;
    }

    fun void setTriset(int t) {
        t => triset;
    }
}

public class MIAP {

    Node nodes[0];

    int numTrisets;

    private void init() {
        nodes.clear();
    }

    init();

    public void addNode(float coordinates[], int triset) {
        Node node;
        node.setCoordinates(coordinates);
        node.setTriset(triset);
        nodes << node;
    }

    // checks if point is in a triangle
    fun int pointInPoly(float P[], float A[], float B[], float C[]) {
        // compute vectors
        computeVector(C, A) @=> float v0[];
        computeVector(B, A) @=> float v1[];
        computeVector(P, A) @=> float v2[];

        // compute dot products
        dot(v0, v0, 2) => float dot00;
        dot(v0, v1, 2) => float dot01;
        dot(v0, v2, 2) => float dot02;
        dot(v1, v1, 2) => float dot11;
        dot(v1, v2, 2) => float dot12;

        // compute barycentric coordinates
        1.0/(dot00 * dot11 - dot01 * dot01) => float invDenom;
        (dot11 * dot02 - dot01 * dot12) * invDenom => float u;
        (dot00 * dot12 - dot01 * dot02) * invDenom => float v;

        // check if point is in triangle
        return (u >= 0) && (v >= 0) && ((u + v) < 1);
    }

    fun float[] computeVector(float R[], float S[]) {
        return [R[0] - S[0], R[1] - S[1]];
    }

    // utility
    fun float dot(float v[], float u[], int n) {
        0.0 => float result;

        for (0 => int i; i < n; i++) {
            v[i]*u[i] +=> result;
        }

        return result;
    }
}

MIAP m;

m.addNode([0.0, 0.0], 0);
m.addNode([0.0, 1.0], 0);
m.addNode([1.0, 0.0], 0);
m.addNode([0.0, 1.0], 1);
m.addNode([1.0, 0.0], 1);
m.addNode([1.0, 1.0], 1);

<<< m.pointInPoly([0.1, 1.1], [0.0, 0.0], [0.0, 1.0], [1.0, 0.0]) >>>;

