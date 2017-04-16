int id;

fun void aShred() {
    me.id() => id;;
    <<< "alive!" >>>;
    while (true) {
        1::ms => now;
    <<< "alive!" >>>;
    }
}

<<< id >>>;
spork ~ aShred();
<<< id, test >>>;
.1::ms => now;
<<< id, test >>>;
Machine.remove(id);

day => now;
