#include <cmath>

#include <gtest/gtest.h>

using namespace std;


double compute(double a, uint8_t b) {
    return sqrt(a) / static_cast<double>(b);
}

TEST(TestCompute, test4_2) {
    EXPECT_EQ(compute(4.0, 2), 1);
}

TEST(TestCompute, test16_2) {
    EXPECT_EQ(compute(16.0, 2), 2);
}

TEST(TestCompute, test16_0) {
    // Not that good
    compute(16.0, 0);
}


