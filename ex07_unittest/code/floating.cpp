
#include <cmath>

#include <gtest/gtest.h>

/// Shows the potential rounding of floating point values.
/// For doing so, try to compare almost similar values with EXPECT_FLOAT_EQ()
///
TEST(Floating, testRounding) {
    float value1 = 0.1f + 0.2f; // Due to floating-point precision, this may not be exactly 0.3
    float value2 = 0.3f; // Directly defined as 0.3

    // Check if they are almost equal
    EXPECT_FLOAT_EQ(value1, value2);

    // Check with EXPECT_EQ
    EXPECT_EQ(value1, value2); // This will likely fail due to exact comparison

    // Additional comparisons to test floating-point rounding
    float value3 = 1.0f / 3.0f; // Approximation of 1/3
    float value4 = 0.33333334f; // Close approximation of 1/3

    EXPECT_FLOAT_EQ(value3, value4);

    // Check with EXPECT_EQ
    EXPECT_EQ(value3, value4); // This will likely fail as well

    // Check an intentional failure case
    float value5 = 0.1234567f;
    float value6 = 0.1234568f; // Very close but not exactly equal

    EXPECT_FLOAT_EQ(value5, value6); // This may still pass depending on precision
    EXPECT_EQ(value5, value6); // This will fail
}

///
/// Compute the average of square root numbers in [1, 10] in two different ways:
/// - Do the sum, then divide by 10.
/// - Do the sum of the square roots divided by 10.
///
/// Compare with ASSERT_EQ and ASSERT_FLOAT_EQ. What happens?
///
TEST(Floating, Loop) {
    double sum1 = 0.0;
    double sum2 = 0.0;

    for (int i = 1; i <= 10; ++i) {
        double sqrtValue = std::sqrt(i);
        sum1 += sqrtValue;
        sum2 += sqrtValue / 10.0;
    }

    double avg1 = sum1 / 10.0;
    double avg2 = sum2;

    // Compare the two averages
    ASSERT_FLOAT_EQ(avg1, avg2); // This should pass due to floating-point tolerance
    ASSERT_EQ(avg1, avg2); // This will likely fail due to exact comparison
}
