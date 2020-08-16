
#include "Stk.h"
extern "C" void test_func() {
    printf("Setting STK sample rate\n");
    stk::Stk::setSampleRate(44100);
}
