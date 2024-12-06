
#include <gmock/gmock.h>  // Brings in gMock.

class Car {
public:
    virtual void forward() = 0;
    virtual void accelerate(int acceleration) = 0;
    virtual void turnRight() = 0;
    virtual int currentSpeed() const = 0;
    virtual void brake() = 0;
};


class MockCar : public Car {
public:
    MOCK_METHOD(void, forward, (), (override));
    MOCK_METHOD(void, accelerate, (int acceleration), (override));
    MOCK_METHOD(void, turnRight, (), (override));
    MOCK_METHOD(int, currentSpeed, (), (const, override));
    MOCK_METHOD(void, brake, (), (override));
};


class Driver {
public:
    void setCar(Car* car) { this->car = car;}
    [[nodiscard]] Car *getCar() const {return car;}
    void getSick() { std:: cout << "Ouch" << '\n';}
    void drive() {
        car->accelerate(1);
        car->forward();
        car->accelerate(2);
        car->forward();
        car->turnRight();
        car->accelerate(2);
        int speed = car->currentSpeed();
        if (speed > 4) {
            car->brake();
        }
    }

    Car *car;
};


using ::testing::AtLeast;
using ::testing::Return;

TEST(DriverTest, CanDrive) {
    auto *car = new MockCar();
    EXPECT_CALL(*car, accelerate(1))
        .Times(AtLeast(1));
    EXPECT_CALL(*car, accelerate(2))
        .Times(AtLeast(2));
    EXPECT_CALL(*car, forward())
        .Times(AtLeast(2));
    EXPECT_CALL(*car, turnRight())
        .Times(AtLeast(1));
    EXPECT_CALL(*car, currentSpeed)
        .WillOnce(Return(5));
    EXPECT_CALL(*car, brake)
        .Times(AtLeast(1));

    Driver driver;
    driver.setCar(car);
    driver.drive();

    delete car;
}





