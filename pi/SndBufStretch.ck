// Eric Heep
// April 17th, 2017
// SndBufStretch.ck

// Basic grain strech that elongates a buffer of
// audio while retaining its pitch, the more grains,
// the more coherent the message.

// This version constantly listens and overwrites two audio buffers.
// Switching between the two to ensure a constant signal.

public class SndBufStretch extends Chubgraph {

    SndBuf snd => ADSR env => outlet;

    32              => int m_grains;
    1.0/m_grains    => float m_inverseGrains;

    0   => int m_samples;
    0.0 => float m_sampleIncrement;
    0   => int m_pos;

    0::samp => dur m_grainLength;
    0::samp => dur m_halfGrainLength;
    0::samp => dur m_endGrainLength;


    0::samp => dur m_endPosition;
    fun void pos(int s) {
        snd.pos(s);
    }

    fun void read(string path) {
        snd.read(path);
        snd.samples() => m_samples;
    }

    fun int samples() {
        return snd.samples();
    }

    fun void grains(int g) {
        g => m_grains;
        1.0/m_grains => m_inverseGrains;
        m_samples/(m_grains$float) => m_sampleIncrement;

    }

    fun void stretch(dur duration) {
        duration * m_inverseGrains => m_grainLength;
        m_grainLength * 0.5 => m_halfGrainLength;

        // for some reason if you try to put a sample at a fraction
        // of a sample, it will silence ChucK
        if (m_halfGrainLength < samp) {
            <<< "Your grains are too small to produce audio.", "" >>>;
            return;
        }

        env.attackTime(m_halfGrainLength);
        env.releaseTime(m_halfGrainLength);

        // bulk of the time stretching
        for (0 => int i; i < m_grains; i++) {
            (i * m_sampleIncrement)$int => m_pos;
            snd.pos(m_pos);
            m_pos::samp + m_grainLength => m_endPosition;

            // only fade if there will be no discontinuity errors
            if (m_endPosition < duration) {
                env.keyOn();
                m_halfGrainLength => now;
                env.keyOff();
                m_halfGrainLength => now;
            }
            else {
                m_grainLength - (m_endPosition - duration) => m_endGrainLength;

                if (m_endGrainLength < 0::samp) {
                    return;
                }

                env.keyOn();
                m_endGrainLength * 0.5 => now;
                env.keyOff();
                m_endGrainLength * 0.5 - m_grainLength => now;
            }
        }
    }
}

/*
SndBufStretch s => dac;

s.read("../wavs/vera.wav");
s.grains(64);
while (true) {
    s.stretch(30.825::second);
}
*/
