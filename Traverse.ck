// Traverse.ck
// Eric Heep
// April 29th, 2017

public class Traverse {

    0.0 => float m_xCenter;
    0.0 => float m_yCenter;

    fun void setCenter(float x, float y) {
        x => m_xCenter;
        y => m_yCenter;
    }

    fun float vectorCoordinateX(float xOrigin, float angle, float dist) {
        return xOrigin + Math.cos(angle) * dist;
    }

    fun float vectorCoordinateY(float yOrigin, float angle, float dist) {
        return yOrigin + Math.sin(angle) * dist;
    }

    fun void traverseVoice(MIAP m, int idx, dur duration, float angle) {
        1.0::ms => dur incrementalDuration;
        (duration/incrementalDuration)$int => int numIncrements;
        (numIncrements * 0.5) $int => int halfNumIncrements;

        // one divide instead of like three thousand right?
        1.0/halfNumIncrements => float scalar;

        0.0 => float x;
        0.0 => float y;
        0.0 => float distance;
        0.5 => float radius;

        // from 0.0 to center
        for (halfNumIncrements => int i; i >= 0; i--) {
            i * scalar * radius => distance;

            vectorCoordinateX(m_xCenter, angle, distance) => x;
            vectorCoordinateY(m_yCenter, angle, distance) => y;
            m.position(x, y);

            incrementalDuration => now;
        }

        // from center to 1.0
        for (0 => int i; i < halfNumIncrements; i++) {
            i * -scalar * radius => distance;

            vectorCoordinateX(m_xCenter, angle, distance) => x;
            vectorCoordinateY(m_yCenter, angle, distance) => y;
            m.position(x, y);

            incrementalDuration => now;
        }
    }
}
