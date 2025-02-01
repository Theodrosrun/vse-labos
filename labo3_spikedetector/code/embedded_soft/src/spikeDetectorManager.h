#ifndef SpikeDetectorManager_H
#define SpikeDetectorManager_H

#include <cstdint>
#include <condition_variable>
#include <array>

#include "IfpgaInterface.h"

#define WINDOW_START_ADDRESS 0x1000
#define WINDOW_SIZE 150
#define WINDOW_FULL_SIZE 256

typedef std::array<int16_t, WINDOW_SIZE> SpikeWindow;

/**
 * Type for the IRQ handler function.
 * That handler should NOT block as it will by directly called
 * by the receiving thread. And so, if blocked, no new message
 * will be received, which can lead to deadlocks.
 */
typedef void (*irq_handler_t)(std::string &);

class SpikeDetectorManager {
public:
    static SpikeDetectorManager &getInstance();

    ~SpikeDetectorManager();

    static void Init(const std::shared_ptr<IfpgaInterface> &fpgaInterface);

    void startAcquisition() const;

    void stopAcquisition() const;

    void setInterruptHandler(irq_handler_t handler) const;

    uint16_t getStatus() const;

    uint16_t getWindowsAddress() const;

    void readWindow(SpikeWindow &data) const;

    std::shared_ptr<IfpgaInterface> fpgaInterface;

    static void Destroy() {
        delete instance;
        instance = nullptr;
    }

private:
    explicit SpikeDetectorManager(const std::shared_ptr<IfpgaInterface> &interface)
            : fpgaInterface(interface) {
    }

    static SpikeDetectorManager *instance;

    void checkInterface() const;
};

#endif // SpikeDetectorManager_H
