#include <gtest/gtest.h>
#include "spikeDetectorManager.h"
#include "spikeDetectorUtils.h"
#include "baseIntegrationTests.h"

class ThreeSpikesInputTest : public ::testing::Test, public SpikeDetectorTestBase<ThreeSpikesInputTest> {
protected:
    static void SetUpTestSuite() {
        startQuesta();
        setupCommonInfrastructure("../3_spikes.txt", "../../fpga_sim/3_spikes.txt");
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

TEST_F(ThreeSpikesInputTest, ExactlyThreeSpikesTest) {
    const int EXPECTED_SPIKES = 3;
    int spikeCount = 0;

    spikeDetector->startAcquisition();

    while (spikeCount < EXPECTED_SPIKES && waitForInterrupt()) {
        SpikeWindow window;
        spikeDetector->readWindow(window);
        irqFifo.pop();

        EXPECT_TRUE(SpikeDetectorUtils::compareWindow(&window, spikeRefFifo))
                            << "Spike window " << spikeCount + 1 << " data mismatch";

        spikeCount++;
    }

    EXPECT_EQ(spikeCount, EXPECTED_SPIKES) << "Did not receive expected number of spikes";

    // Verify no more spikes are detected
    EXPECT_FALSE(waitForInterrupt(10)) << "Unexpected additional spikes detected";

    spikeDetector->stopAcquisition();
}