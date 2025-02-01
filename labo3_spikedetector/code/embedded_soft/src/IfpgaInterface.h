#ifndef EMBEDDED_IFPGAINTERFACE_H
#define EMBEDDED_IFPGAINTERFACE_H

#include <cstdlib>
#include <string>

/**
 * Type for the IRQ handler function.
 * That handler should NOT block as it will by directly called
 * by the receiving thread. And so, if blocked, no new message
 * will be received, which can lead to deadlocks.
 */
typedef void (*irq_handler_t)(std::string &);

class IfpgaInterface {
public:
    virtual ~IfpgaInterface() = default;

    /**
        * @brief Function to send data to the FPGA
        * @param reg the register to write to
        * @param val the value to write
        */
    virtual void sendToFpga(unsigned reg, unsigned val) = 0;

    /**
        * @brief Function to read data from the FPGA can be blocking
        * @return A message from the FPGA.
        */
    virtual int16_t readFromFpga(unsigned reg) = 0;

    /**
        * @brief Function called on interrupt
        */
    virtual void setInterruptHandler(irq_handler_t handler) = 0;

    /**
        * @brief Gets a value indicating whether the interface is connected to the FPGA
        */
    virtual bool isConnected() = 0;

    virtual void endTest() = 0;
};

#endif //EMBEDDED_IFPGAINTERFACE_H
