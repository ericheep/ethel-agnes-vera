public class DBAP {

    // defaults to four channels
    4 => int NUM_CHANNELS;
    float gain[NUM_CHANNELS];
    float locations[NUM_CHANNELS][2];

    // rolloff in decibels
    6.0 => float rolloff;
    0.0 => float a;
    0.02 => float spatialBlur;
    rolloffCoefficient(rolloff);

    // location of the virtual sound source
    fun void pan(float p[]) {
        for (int i; i < NUM_CHANNELS; i++) {
            Math.sqrt(Math.pow((locations[i][0] - p[0]), 2) +
                      Math.pow((locations[i][1] - p[1]), 2) +
                      Math.pow(spatialBlur, 2)) => float distance;
        }
    }

    fun void rolloffCoefficient(float R) {
        R/(20 * Math.log10(2)) => a;
        <<< a >>>;
    }

    // number of sound sources
    fun void numChannels(int n) {
        n => NUM_CHANNELS;
        gain.size(NUM_CHANNELS);
        locations.size(NUM_CHANNELS);
    }

    fun void coordinates(float c[][]) {
        if (c.size() != NUM_CHANNELS) {
            <<< "Warning: Number of coordinates does not match number of channels.", "" >>>;
        }
        for (int i; i < c.size(); i++) {
            c[i] @=> locations[i];
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

dbap.pan([0.2, 0.3]);

