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
                        areaOfTriangles(pos, nodes[trisetIdx[0]],
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

    private void areaOfTriangles(float pos[], Node n1, Node n2, Node n3) {
        distance(n1.coordinate, n2.coordinate) => float ab;
        distance(n2.coordinate, n3.coordinate) => float bc;
        distance(n1.coordinate, n3.coordinate) => float ac;

        heronArea(ab, bc, ac) => float totalArea;
        1.0/totalArea => float totalAreaScalar;

        distance(n1.coordinate, pos) => float ap;
        distance(n2.coordinate, pos) => float bp;
        distance(n3.coordinate, pos) => float cp;

        heronArea(ab, bp, ap) => float n3Area;
        heronArea(ac, ap, cp) => float n2Area;
        totalArea - n3Area - n2Area => float n1Area;

        Math.sqrt(n1Area * totalAreaScalar) => n1.gain;
        Math.sqrt(n2Area * totalAreaScalar) => n2.gain;
        Math.sqrt(n3Area * totalAreaScalar) => n3.gain;
    }

    private float heronArea(float A, float B, float C) {
        (A + B + C) * 0.5 => float S;
        return Math.sqrt(S * (S - A) * (S - B) * (S - C));
    }

    private float distance(float A[], float B[]) {
        return Math.sqrt(Math.pow((B[0] - A[0]), 2) + Math.pow((B[1] - A[1]), 2));
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

    // http://blackpawn.com/texts/pointinpoly/
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

/*
MIAP m;

Math.pow(0.75, 2) => float verticalHeight;
(4.5 - (verticalHeight * 3)) * .5 => float verticalOffset;

/*

    For six unit triangles with a perimeter of silent nodes.

                    *---*---*---*
                   / \ / \ / \ / \
                  *   *   *   *   *
                   \ / \ / \ / \ / \
                    *   *   *   *   *
                     \ / \ / \ / \ /
                      *---*---*---*
*/

/*
// top row, all silent
m.addNode([0.5, verticalOffset], [0, 1]);
m.addNode([1.5, verticalOffset], [1, 2, 3]);
m.addNode([2.5, verticalOffset], [3, 4, 5]);
m.addNode([3.5, verticalOffset], [5, 6]);

// first and last silent
m.addNode([0.0, verticalOffset + verticalHeight], [0, 7]);
m.addNode([1.0, verticalOffset + verticalHeight], [0, 1, 2, 7, 8, 9]);
m.addNode([2.0, verticalOffset + verticalHeight], [2, 3, 4, 9, 10, 11]);
m.addNode([3.0, verticalOffset + verticalHeight], [4, 5, 6, 11, 12, 13]);
m.addNode([4.0, verticalOffset + verticalHeight], [6, 13, 14]);

// first and last silent
m.addNode([0.5, verticalOffset + verticalHeight * 2], [7, 8, 15]);
m.addNode([1.5, verticalOffset + verticalHeight * 2], [8, 9, 10, 15, 16, 17]);
m.addNode([2.5, verticalOffset + verticalHeight * 2], [10, 11, 12, 17, 18, 19]);
m.addNode([3.5, verticalOffset + verticalHeight * 2], [12, 13, 14, 19, 20, 21]);
m.addNode([4.5, verticalOffset + verticalHeight * 2], [14, 21]);

// bottom row, silent
m.addNode([1.0, verticalOffset + verticalHeight * 3], [15, 16]);
m.addNode([2.0, verticalOffset + verticalHeight * 3], [16, 17, 18]);
m.addNode([3.0, verticalOffset + verticalHeight * 3], [18, 19, 20]);
m.addNode([4.0, verticalOffset + verticalHeight * 3], [20, 21]);

*/
