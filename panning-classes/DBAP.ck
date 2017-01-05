public class DBAP {

    // defaults to four channels
    4 => int NUM_CHANNELS;
    float gain[NUM_CHANNELS];
    float location[NUM_CHANNELS][2];
    float distance[NUM_CHANNELS];

    // rolloff in decibels
    6.0 => float rolloff;
    0.0 => float rolloffCoefficient;
    0.02 => float spatialBlur;
    computeRolloffCoefficient(rolloff);

    // location of the virtual sound source
    fun void pan(float p[]) {
        float k;

        for (int i; i < NUM_CHANNELS; i++) {
            Math.sqrt(Math.pow((location[i][0] - p[0]), 2) +
                      Math.pow((location[i][1] - p[1]), 2) +
                      Math.pow(spatialBlur, 2)) => distance[i];
        }

        amplitudeCoefficient(distance) => k;

        for (int i; i < NUM_CHANNELS; i++) {
            <<< k/Math.pow(distance[i], rolloffCoefficient) >>>;
        }

    }

    fun float amplitudeCoefficient(float d[]) {
        0.0 => float sum;
        for (int i; i < NUM_CHANNELS; i++) {
            1.0/(Math.pow(d[i], 2.0 * rolloffCoefficient)) +=> sum;
        }
        return 1.0/Math.sqrt(sum);
    }

    fun void computeRolloffCoefficient(float R) {
        R/(20 * Math.log10(2)) => rolloffCoefficient;
    }

    // number of sound sources
    fun void numChannels(int n) {
        n => NUM_CHANNELS;
        gain.size(NUM_CHANNELS);
        location.size(NUM_CHANNELS);
        distance.size(NUM_CHANNELS);
    }

    fun void coordinates(float c[][]) {
        if (c.size() != NUM_CHANNELS) {
            <<< "Warning: Number of coordinates does not match number of channels.", "" >>>;
        }
        for (int i; i < c.size(); i++) {
            c[i] @=> location[i];
        }
    }

}

DBAP dbap;

// set channels
dbap.numChannels(4);

// set speaker coordinates
dbap.coordinates([[0.0, 0.0],
                  [0.0, 1.0],
                  [1.0, 1.0],
                  [1.0, 0.0]]);

for (float i; i < 1.0; 0.1 +=> i) {
    dbap.pan([i, 0.75]);
    <<< "----------------------" >>>;
}

