#include <gtest/gtest.h>
#include <array>
#include <stdexcept>
#include <sstream>

using namespace std;

template <typename T, int SIZE>
class MyArray
{
public:
    MyArray() = default;

    void set(size_t index, T value) {
        if (index >= SIZE) {
            throw std::runtime_error("Index out of bounds");
        }
        internalArray[index] = value;
    }

    T get(size_t index) const {
        if (index >= SIZE) {
            throw std::runtime_error("Index out of bounds");
        }
        return internalArray[index];
    }

private:
    std::array<T, SIZE> internalArray = {};
};

template<typename T>
class MyArrayTest : public ::testing::Test
{
protected:

    // Test de base pour set() et get()
    void testSimpleDirected() {
        MyArray<T, 5> array;
        array.set(2, static_cast<T>(42));
        EXPECT_EQ(array.get(2), static_cast<T>(42)); // Vérifie que la valeur est correcte
    }

    // Écriture et lecture consécutives
    void testConsecutiveSetGet() {
        MyArray<T, 5> array;
        for (size_t i = 0; i < 5; ++i) {
            array.set(i, static_cast<T>(i * 10));
            EXPECT_EQ(array.get(i), static_cast<T>(i * 10)); // Lecture immédiate après écriture
        }
    }

    // Écriture et lecture de toute la plage d'indices
    void testFullSetGet() {
        MyArray<T, 5> array;
        for (size_t i = 0; i < 5; ++i) {
            array.set(i, static_cast<T>(i * 5));
        }
        for (size_t i = 0; i < 5; ++i) {
            EXPECT_EQ(array.get(i), static_cast<T>(i * 5)); // Lecture de toutes les valeurs
        }
    }

    // Vérifie que l'écriture à un indice ne touche pas les autres indices
    void testDoNotTouchOthers() {
        MyArray<T, 5> array;
        for (size_t i = 0; i < 5; ++i) {
            array.set(i, static_cast<T>(0)); // Initialisation à 0
        }
        array.set(2, static_cast<T>(99)); // Modification à l'indice 2
        for (size_t i = 0; i < 5; ++i) {
            if (i == 2) {
                EXPECT_EQ(array.get(i), static_cast<T>(99)); // Vérifie la modification
            } else {
                EXPECT_EQ(array.get(i), static_cast<T>(0)); // Les autres valeurs restent inchangées
            }
        }
    }

    // Vérifie que les accès incorrects déclenchent des exceptions
    void testBadAccess() {
        MyArray<T, 5> array;
        EXPECT_THROW(array.get(5), std::runtime_error); // Indice hors limite (lecture)
        EXPECT_THROW(array.set(5, static_cast<T>(42)), std::runtime_error); // Indice hors limite (écriture)
        EXPECT_THROW(array.get(-1), std::runtime_error); // Indice négatif simulé (lecture)
    }
};

using MyTypes = ::testing::Types<int, float, double>;
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
