#ifndef MOCK_FPGA_INTERFACE_H
#define MOCK_FPGA_INTERFACE_H

#include "../src/IfpgaInterface.h"
#include <gmock/gmock.h>
#include <queue>
#include <map>

class MockFpgaInterface : public IfpgaInterface {
public:
    MockFpgaInterface() = default;

    // Mock methods
    MOCK_METHOD(void, sendToFpga, (unsigned reg, unsigned val), (override));
    MOCK_METHOD(int16_t, readFromFpga, (unsigned reg), (override));
    MOCK_METHOD(void, setInterruptHandler, (irq_handler_t handler),
                (override));
    MOCK_METHOD(bool, isConnected, (), (override));
    MOCK_METHOD(void, endTest, (), (override));

    // Real implementation for helper methods
    void actualSetInterruptHandler(irq_handler_t handler) {
        currentHandler = handler;
    }

    void simulateInterrupt(const std::string &message) {
        if (currentHandler) {
            std::string msg = message;
            currentHandler(msg);
        }
    }

private:
    irq_handler_t currentHandler = nullptr;
    std::map<unsigned, int16_t> returnValues;
};

#endif // MOCK_FPGA_INTERFACE_H
