#ifndef SPIKEDETECTORUTILS_H
#define SPIKEDETECTORUTILS_H

#include <array>
#include <cstdint>
#include <memory>
#include <queue>
#include <string>

#define WINDOW_START_ADDRESS 0x1000
#define WINDOW_SIZE 150
#define WINDOW_FULL_SIZE 256
#define MOVING_AVG_SIZE 128
#define MOVING_AVG_LOG2 7
#define DETECTION_FACTOR 15
#define WINDOW_AFTER_SPIKE_SIZE 100

#define DEFAULT_FILE_PATH "../../fpga_sim/input_values.txt"

typedef std::array<int16_t, WINDOW_SIZE> SpikeWindow;

/**
 * Type for the IRQ handler function.
 * That handler should NOT block as it will by directly called
 * by the receiving thread. And so, if blocked, no new message
 * will be received, which can lead to deadlocks.
 */
typedef void (*irq_handler_t)(std::string &);

class SpikeDetectorUtils {
public:

    static void getReferenceSpikes(std::queue<std::shared_ptr<SpikeWindow> > &spikeRefFifo, const std::string &path);

    static bool compareWindow(SpikeWindow *window, std::queue<std::shared_ptr<SpikeWindow> > &spikeRefFifo);
};

#endif //SPIKEDETECTORUTILS_H
