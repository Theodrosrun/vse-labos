#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "spikeDetectorManager.h"
#include "fpgaInterfaceMock.h"

class SpikeDetectorManagerTest : public ::testing::Test {
protected:
    void SetUp() override {
        mockFpga = std::make_shared<MockFpgaInterface>();
        SpikeDetectorManager::Init(mockFpga);
    }

    void TearDown() override {
        SpikeDetectorManager::Destroy();
    }

    std::shared_ptr<MockFpgaInterface> mockFpga;

public:
    static bool handlerCalled;

    static void handler(std::string &message) {
        handlerCalled = true;
    }
};

bool SpikeDetectorManagerTest::handlerCalled{false};

TEST_F(SpikeDetectorManagerTest, StartAcquisition) {
    EXPECT_CALL(*mockFpga, sendToFpga(1, 1));
    SpikeDetectorManager::getInstance().startAcquisition();
}

TEST_F(SpikeDetectorManagerTest, StopAcquisition) {
    EXPECT_CALL(*mockFpga, sendToFpga(1, 0));
    SpikeDetectorManager::getInstance().stopAcquisition();
}

TEST_F(SpikeDetectorManagerTest, GetStatus) {
    EXPECT_CALL(*mockFpga, readFromFpga(0))
            .WillOnce(testing::Return(0x42));
    ASSERT_EQ(SpikeDetectorManager::getInstance().getStatus(), 0x42);
}

TEST_F(SpikeDetectorManagerTest, GetWindowsAddress) {
    EXPECT_CALL(*mockFpga, readFromFpga(2))
            .WillOnce(testing::Return(1));
    uint16_t expected = WINDOW_START_ADDRESS + (1 * WINDOW_FULL_SIZE);
    ASSERT_EQ(SpikeDetectorManager::getInstance().getWindowsAddress(), expected);
}

TEST_F(SpikeDetectorManagerTest, ReadWindow) {
    // Mock window address read
    EXPECT_CALL(*mockFpga, readFromFpga(2))
            .WillOnce(testing::Return(1));

    // Mock data reads
    uint16_t baseAddr = WINDOW_START_ADDRESS + WINDOW_FULL_SIZE;
    for (int i = 0; i < WINDOW_SIZE; i++) {
        EXPECT_CALL(*mockFpga, readFromFpga(baseAddr + i))
                .WillOnce(testing::Return(i));
    }

    // Mock ack
    EXPECT_CALL(*mockFpga, sendToFpga(1, 2));

    SpikeWindow data;
    SpikeDetectorManager::getInstance().readWindow(data);

    // Verify data
    for (int i = 0; i < WINDOW_SIZE; i++) {
        ASSERT_EQ(data[i], i);
    }
}

TEST_F(SpikeDetectorManagerTest, InterruptHandler) {
    EXPECT_CALL(*mockFpga, setInterruptHandler(testing::_));
    SpikeDetectorManager::getInstance().setInterruptHandler(handler);

    std::string msg = "test";
    mockFpga->actualSetInterruptHandler(handler);
    mockFpga->simulateInterrupt(msg);
    ASSERT_TRUE(handlerCalled);
    mockFpga.reset();
    mockFpga = nullptr;
}

TEST_F(SpikeDetectorManagerTest, Destroy) {
    SpikeDetectorManager::Destroy();
    ASSERT_THROW(SpikeDetectorManager::getInstance(), std::runtime_error);
    SpikeDetectorManager::Init(mockFpga);
    ASSERT_NO_THROW(SpikeDetectorManager::getInstance());
}
