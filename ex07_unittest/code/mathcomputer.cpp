

#include <gtest/gtest.h>

typedef unsigned int datatype_t;

class MathComputer
{
public:
    MathComputer(int N) : N(N) {}

    ///
    /// \brief Computes a mathematical function
    /// \param a First parameter
    /// \param b Second paramter
    /// \param c Third parameter
    /// \return a**N + b * c
    ///
    /// This function returns a power of N plus b times c
    ///
    datatype_t compute(datatype_t a, datatype_t b, datatype_t c)
    {
        datatype_t result = 1;
        for (int i = 0; i < N ; i++) {
            result *= a;
        }
        result += b * c;
        return result;
    }

private:
    int N{0};
};


// Tests
TEST(Computer, simpleComputation) {
    MathComputer computer(2); // N = 2
    EXPECT_EQ(computer.compute(2, 3, 4), 16); // 2^2 + 3*4 = 4 + 12 = 16
}

TEST(Computer, zeroExponent) {
    MathComputer computer(0); // N = 0
    EXPECT_EQ(computer.compute(2, 3, 4), 1 + 3*4); // 2^0 + 3*4 = 1 + 12 = 13
}

TEST(Computer, zeroMultipliers) {
    MathComputer computer(3); // N = 3
    EXPECT_EQ(computer.compute(2, 0, 0), 8); // 2^3 + 0*0 = 8 + 0 = 8
}

TEST(Computer, edgeCaseWithOne) {
    MathComputer computer(1); // N = 1
    EXPECT_EQ(computer.compute(5, 7, 1), 12); // 5^1 + 7*1 = 5 + 7 = 12
}

TEST(Computer, largeNumbers) {
    MathComputer computer(3); // N = 3
    EXPECT_EQ(computer.compute(10, 20, 30), 1000 + 600); // 10^3 + 20*30 = 1000 + 600 = 1600
}

TEST(Computer, verifyOverflow) {
    MathComputer computer(10); // N = 10
    datatype_t largeNumber = 10;
    // This may test an overflow case (depending on datatype_t size)
    EXPECT_NO_THROW(computer.compute(largeNumber, 2, 3)); 
}