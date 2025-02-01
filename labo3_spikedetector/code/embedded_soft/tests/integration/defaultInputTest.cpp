#include <gtest/gtest.h>
#include "spikeDetectorManager.h"
#include "spikeDetectorUtils.h"
#include "baseIntegrationTests.h"

#define NO_IRQ_DURATION 5

// Test suite for default input file
class DefaultInputTest : public ::testing::Test, public SpikeDetectorTestBase<DefaultInputTest> {
protected:
    static void SetUpTestSuite() {
        startQuesta();
        setupCommonInfrastructure("../input_values.txt", "../../fpga_sim/input_values.txt");
    }

    static void TearDownTestSuite() {
        cleanup();
        stopQuesta();
    }

    void SetUp() override {
        spikeDetector->setInterruptHandler(interruptHandler);
    }

    void TearDown() override {
        spikeDetector->stopAcquisition();
        while (!irqFifo.empty()) irqFifo.pop();
    }
};

TEST_F(DefaultInputTest, BasicAcquisitionTest) {
    ASSERT_EQ(spikeDetector->getStatus() & 0x2, 0);

    spikeDetector->startAcquisition();
    ASSERT_EQ(spikeDetector->getStatus() & 0x2, 2);

    ASSERT_TRUE(waitForInterrupt());

    SpikeWindow window;
    spikeDetector->readWindow(window);
    irqFifo.pop();

    ASSERT_TRUE(SpikeDetectorUtils::compareWindow(&window, spikeRefFifo));

    spikeDetector->stopAcquisition();
    ASSERT_EQ(spikeDetector->getStatus() & 0x2, 0);
}

TEST_F(DefaultInputTest, StopAndRestartTest) {
    const int SPIKES_BEFORE_STOP = 2;
    int spikeCount = 0;

    spikeDetector->startAcquisition();

    while (spikeCount < SPIKES_BEFORE_STOP) {
        ASSERT_TRUE(waitForInterrupt());

        SpikeWindow window;
        spikeDetector->readWindow(window);
        irqFifo.pop();

        ASSERT_TRUE(SpikeDetectorUtils::compareWindow(&window, spikeRefFifo));
        spikeCount++;
    }

    spikeDetector->stopAcquisition();

    // Check that no interrupt is received after stopping
    ASSERT_FALSE(waitForInterrupt(NO_IRQ_DURATION));

    spikeDetector->startAcquisition();
    ASSERT_TRUE(waitForInterrupt());

    SpikeWindow window;
    spikeDetector->readWindow(window);
    irqFifo.pop();

    ASSERT_TRUE(SpikeDetectorUtils::compareWindow(&window, spikeRefFifo));
}