// Eric Heep
// 01/04/2017
// DBAP.ck

// Distance-Based Amplitude Panning
// http://jamoma.org/publications/attachments/icmc2009-dbap-rev1.pdf

public class DBAP {

    int NUM_CHANNELS;
    float gain[0];
    float speakerCoordinates[0][2];
    float speakerDistances[0];
    float _rolloff, _spatialBlur, _rolloffCoefficient;

    private void init() {
        3.0 => _rolloff;
        0.001 => _spatialBlur;
        4 => NUM_CHANNELS;
        numChannels(NUM_CHANNELS);
        computeRolloffCoefficient(_rolloff);
    }

    init();

    public void numChannels(int n) {
        n => NUM_CHANNELS;
        gain.size(NUM_CHANNELS);
        speakerCoordinates.size(NUM_CHANNELS);
        speakerDistances.size(NUM_CHANNELS);
    }

    public void spatialBlur(float b) {
        b => _spatialBlur;
    }

    // set rolloff in decibels
    public void rolloff(float R) {
        R => _rolloff;
    }

    // set coordinates, [0.0 - 1.0]
    public void coordinates(float l[][]) {
        if (l.size() != NUM_CHANNELS) {
            <<< "Warning: Number of coordinates does not match number of channels.", "" >>>;
        }
        for (int i; i < l.size(); i++) {
            l[i] @=> speakerCoordinates[i];
        }
    }

    // dbap panning, [0.0 - 1.0]
    public float[] pan(float p[]) {
        computeSpeakerDistances(p);
        computeAmplitudeCoefficient() => float k;

        for (0 => int i; i < NUM_CHANNELS; i++) {
            k/Math.pow(speakerDistances[i], _rolloffCoefficient) => gain[i];
        }

        return gain;
    }

    private void computeRolloffCoefficient(float R) {
        R/(20.0 * Math.log10(2)) => _rolloffCoefficient;
    }

    // distance formula with spatial blur offset
    private float[] computeSpeakerDistances(float p[]) {
        for (0 => int i; i < NUM_CHANNELS; i++) {
            Math.sqrt(Math.pow((speakerCoordinates[i][0] - p[0]), 2) +
                      Math.pow((speakerCoordinates[i][1] - p[1]), 2) +
                      Math.pow(_spatialBlur, 2)) => speakerDistances[i];
        }
    }

    private float computeAmplitudeCoefficient() {
        0.0 => float sum;
        for (0 => int i; i < NUM_CHANNELS; i++) {
            1.0/(Math.pow(speakerDistances[i], 2.0 * _rolloffCoefficient)) +=> sum;
        }
        return 1.0/Math.sqrt(sum);
    }
}

DBAP dbap;

// set channels
dbap.numChannels(4);
dbap.spatialBlur(0.0001);

// set speaker coordinates
dbap.coordinates([[0.0, 0.0], [0.0, 1.0], [1.0, 1.0], [1.0, 0.0]]);

float levels[];
float coordinate[2];

for (0 => int i; i < 10; i++) {
    Math.random2f(0.0, 1.0) => coordinate[0];
    Math.random2f(0.0, 1.0) => coordinate[1];
    dbap.pan(coordinate) @=> levels;
    <<< "Coordinate: ", coordinate[0], coordinate[1], " -  Levels: ", levels[0], levels[1], levels[2], levels[3], "" >>>;
}
