#include "spikeDetectorManager.h"

#include <sstream>
#include <arpa/inet.h> //inet_addr
#include <unistd.h> //write

SpikeDetectorManager *SpikeDetectorManager::instance;

SpikeDetectorManager::~SpikeDetectorManager() {
    if (fpgaInterface && fpgaInterface->isConnected()) {
        fpgaInterface->endTest();
        // Sleep to be sure that data are correctly send
        sleep(5);

        fpgaInterface.reset();
    }
}

SpikeDetectorManager &SpikeDetectorManager::getInstance() {
    if (!instance) {
        throw std::runtime_error("SpikeDetectorManager not initialized");
    }
    return *instance;
}

void SpikeDetectorManager::Init(const std::shared_ptr<IfpgaInterface> &fpgaInterface) {
    delete instance;
    instance = new SpikeDetectorManager(fpgaInterface);
}

void SpikeDetectorManager::startAcquisition() const {
    checkInterface();
    fpgaInterface->sendToFpga(1, 1);
}

void SpikeDetectorManager::stopAcquisition() const {
    checkInterface();
    fpgaInterface->sendToFpga(1, 0);
}

void SpikeDetectorManager::setInterruptHandler(irq_handler_t handler) const {
    checkInterface();
    this->fpgaInterface->setInterruptHandler(handler);
}

uint16_t SpikeDetectorManager::getStatus() const {
    checkInterface();
    return fpgaInterface->readFromFpga(0);
}

uint16_t SpikeDetectorManager::getWindowsAddress() const {
    checkInterface();
    int16_t value;

    value = fpgaInterface->readFromFpga(2);

    return WINDOW_START_ADDRESS + (value * WINDOW_FULL_SIZE);
}

void SpikeDetectorManager::readWindow(SpikeWindow &data) const {
    checkInterface();
    uint16_t addr = getWindowsAddress();

    // Retrieve the full window
    for (int i = 0; i < WINDOW_SIZE; i++) {
        int16_t data_read = fpgaInterface->readFromFpga(addr + i);
        data[i] = data_read;
    }

    fpgaInterface->sendToFpga(1, 2);
}

void SpikeDetectorManager::checkInterface() const {
    if (!fpgaInterface) {
        throw std::runtime_error("FPGA interface not initialized");
    }
}
