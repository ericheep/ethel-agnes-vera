float sum;

for (0.005 => float i; i < 1.0; 0.005 +=> i) {
    Math.pow(i, 6) +=> sum;
    if (Math.pow(i, 6) > 0.66) {
        <<< "!" >>>;
    }
    <<< (Math.pow(i, 6) * 30::second)/second >>>;
}

<<< (sum  * 30::second)/second >>>;

0.0 => sum;
for (0 => float i; i < 1.0; 0.01 +=> i) {
    Math.pow(i, 6) +=> sum;
}

<<< (sum  * 30::second)/second >>>;
