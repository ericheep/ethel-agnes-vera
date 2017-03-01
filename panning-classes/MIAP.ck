// Eric Heep

// Manifold-Something Amplitude Panning
// white paper locked behind AES paywall

public class MIAP {

    // our node objects
    class Node {
        float coordinate[2];
        float gain;
        int trisets[0];
    }

    Node nodes[0];
    int trisets[0];
    int numNodes;
    int numTrisets;

    private void init() {
        0 => numNodes;
        0 => numTrisets;
    }

    init();

    public void addNode(float coordinate[], int trisets[]) {
        Node node;
        coordinate @=> node.coordinate;
        trisets @=> node.trisets;
        nodes << node;
        updateTrisets();
        numNodes++;
    }

    public void setPosition(float pos[]) {
        0 => int trisetFound;

        for (0 => int i; i < numTrisets; i++) {
            if (trisetFound) {
                break;
            }

            int trisetIdx[0];

            for (0 => int j; j < nodes.size(); j++) {

                if (nodeInTriset(nodes[j], trisets[i])) {
                    trisetIdx << j;
                }
                if (trisetIdx.size() == 3) {
                    if (pointInTriset(pos, nodes[trisetIdx[0]].coordinate,
                                           nodes[trisetIdx[1]].coordinate,
                                           nodes[trisetIdx[2]].coordinate)) {

                        // if the point is inside triset, we do some math
                        areaOfTriset(pos, nodes[trisetIdx[0]],
                                          nodes[trisetIdx[1]],
                                          nodes[trisetIdx[2]]);

                        // breaks the loop, only one triset should be found
                        1 => trisetFound;
                    }
                    break;
                }
            }
        }
    }

    private void areaOfTriset(float pos[], Node n1, Node n2, Node n3) {
        <<< n1.coordinate[0], n1.coordinate[1] >>>;
        <<< n2.coordinate[0], n2.coordinate[1] >>>;
        <<< n3.coordinate[0], n3.coordinate[1] >>>;
    }

    private void updateTrisets() {
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
        uniqueTrisets.size() => numTrisets;
    }


    private int nodeInTriset(Node node, int triset) {
        for (0 => int i; i < node.trisets.size(); i++) {
            if (node.trisets[i] == triset)  return 1;
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
m.addNode([1.0, 0.0], [0, 1, 2]);
m.addNode([1.0, 1.0], [1, 2]);
m.addNode([2.0, 1.0], [1, 2]);

m.setPosition([1.75, 0.9]);

