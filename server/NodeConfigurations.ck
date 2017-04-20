public class NodeConfigurations {

    // L, R
    [17, 23,
     25, 18,
     31, 32] @=> int smallHexagon[];

    //               17----18
    //               /       \
    //              /         \
    //            23     *    25
    //              \         /
    //               \       /
    //               31----32

    // L, R
    [16, 23,
     25, 17,
     32, 33] @=> int triangles[];

    //         16----17
    //          \    /
    //           \  /
    //            23     *    25
    //                        / \
    //                       /   \
    //                     32----33

    // L, R
    [17, 22,
     26, 25,
     23, 32] @=> int heartbeat[];

    //               17
    //               / \
    //              /   \
    //      22----23     *    25----26
    //                    \   /
    //                     \ /
    //                     32

    // L, R
    [17, 22,
     26, 11,
     37, 32] @=> int bowtie[];

    //                         11
    //                         / \
    //                        /   \
    //                17-----*     *
    //                /             \
    //               /               \
    //       22-----*     *     *----26
    //         \               /
    //          \             /
    //           *     *----32
    //            \   /
    //             \ /
    //             37

    // L, R
    [ 9, 22,
     26, 11,
     37, 39] @=> int largeHexagon[];

    //               9-----*----11
    //              /             \
    //             /               \
    //            *                 *
    //           /                   \
    //          /                     \
    //        22           *          26
    //          \                     /
    //           \                   /
    //            *                 *
    //             \               /
    //              \             /
    //              37-----*----39


    int configuration[0][0];

    configuration << smallHexagon;
    configuration << triangles;
    configuration << heartbeat;
    configuration << bowtie;
    configuration << largeHexagon;

    fun int configurationSize() {
        return configuration.size() * configuration[0].size();
    }
}
