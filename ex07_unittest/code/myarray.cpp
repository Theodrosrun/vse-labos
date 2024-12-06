#include <gtest/gtest.h>

using namespace std;

template <typename T, int SIZE>
class MyArray
{
public:
    MyArray() = default;

    void set(size_t index, T value) {
        internalArray[index] = value;
    }

    T get(size_t index) {
        if (index >= SIZE) {
            throw std::runtime_error("Index too high");
        }
        return internalArray[index];
    }

private:
    std::array<T, SIZE> internalArray;

};


template<typename T>
class MyArrayTest : public ::testing::Test
{
protected:

    ///
    /// \brief testSimpleDirected
    ///
    /// This test shall display some set() and get() at specific indices.
    ///
    void testSimpleDirected() {
        ASSERT_EQ(true, false);
    }

    ///
    /// \brief testConsecutiveSetGet
    ///
    /// This test shall show some write and consecutive read accesses.
    /// They can be hardcoded or can use a for loop, with each time a
    /// write followed by a read at the same index.
    void testConsecutiveSetGet() {
        ASSERT_EQ(true, false);
    }

    ///
    /// \brief testFullSetGet
    ///
    /// This test shall show writes in the entire array, and then reads of
    /// the entire array.
    void testFullSetGet() {
        ASSERT_EQ(true, false);
    }

    ///
    /// \brief testDoNotTouchOthers
    ///
    /// This test is meant to show that if we fill the array with values,
    /// then if we write at one address, it shouldn't change all other
    /// indices values.
    ///
    void testDoNotTouchOthers() {
        ASSERT_EQ(true, false);
    }

    ///
    /// \brief testBadAccess
    ///
    /// This test is meant to detect exception throwned if bad accesses happen.
    ///
    void testBadAccess() {
        ASSERT_EQ(true, false);
    }


};

using MyTypes = ::testing::Types<int,
                                 float,
                                 double
                                 >;

TYPED_TEST_SUITE(MyArrayTest, MyTypes);

TYPED_TEST(MyArrayTest, SimpleDirected) {
    this->testSimpleDirected();
}

TYPED_TEST(MyArrayTest, ConsecutiveSetGet) {
    this->testConsecutiveSetGet();
}

TYPED_TEST(MyArrayTest, FullSetFullGet) {
    this->testFullSetGet();
}

TYPED_TEST(MyArrayTest, DoNotTouchOthers) {
    this->testDoNotTouchOthers();
}


TYPED_TEST(MyArrayTest, BadAccess) {
    this->testBadAccess();
}

