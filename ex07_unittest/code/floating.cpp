
#include <cmath>

#include <gtest/gtest.h>

/// Shows the potential rounding of floating point values.
/// For doing so, try to compare almost similar values with EXPECT_FLOAT_EQ()
///
TEST(Floating, testRounding) {
    // Add your code here
    float value1 = 0.1f + 0.2f; // Due to floating-point precision, this may not be exactly 0.3
    float value2 = 0.3f; // Directly defined as 0.3

    // Check if they are almost equal
    EXPECT_FLOAT_EQ(value1, value2);

    // Additional comparisons to test floating-point rounding
    float value3 = 1.0f / 3.0f; // Approximation of 1/3
    float value4 = 0.33333334f; // Close approximation of 1/3

    EXPECT_FLOAT_EQ(value3, value4);

    // Check an intentional failure case
    float value5 = 0.1234567f;
    float value6 = 0.1234568f; // Very close but not exactly equal

    EXPECT_FLOAT_EQ(value5, value6); // This may still pass depending on precision
}

///
/// Compute the average of square root numbers in [1, 10] in two different ways:
/// - Do the sum, then divide by 10.
/// - Do the sum of the square roots divided by 10.
///
/// Compare with ASSERT_EQ et ASSERT_FLOAT_EQ. What happens?
///
TEST(Floating, Loop) {
    // Add your code here
}

