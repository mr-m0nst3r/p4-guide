#include <core.p4>

// Architecture
parser P1();
parser P2();
parser P3();
package S(P3 p3);

// User Program
parser MyP1() {
    state start {
        transition accept;
    }
}
parser MyP2(P1 p1) {
    state start {
        p1.apply();
        transition accept;
    }
}
parser MyP3() {
    MyP1() p1;
    state start {
        MyP2.apply(p1);
        transition accept;
    }
}

S(MyP3()) main;
