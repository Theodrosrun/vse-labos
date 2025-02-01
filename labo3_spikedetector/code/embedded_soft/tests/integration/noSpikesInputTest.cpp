#include <gtest/gtest.h>
#include "spikeDetectorManager.h"
#include "baseIntegrationTests.h"

class NoSpikesInputTest : public ::testing::Test, public SpikeDetectorTestBase<NoSpikesInputTest> {
protected:
    static void SetUpTestSuite() {
        startQuesta();
        setupCommonInfrastructure("../no_spikes.txt", "../../fpga_sim/no_spikes.txt");
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

TEST_F(NoSpikesInputTest, NoInterruptTest) {
    spikeDetector->startAcquisition();
    EXPECT_EQ(spikeDetector->getStatus() & 0x2, 2) << "Acquisition should be running";

    // No spikes expected, so we should timeout
    EXPECT_FALSE(waitForInterrupt(10)) << "Unexpected interrupt received";

    spikeDetector->stopAcquisition();
    EXPECT_EQ(spikeDetector->getStatus() & 0x2, 0) << "Acquisition should be stopped";
}