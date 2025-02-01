#ifndef EMBEDDED_FPGAAVALON_H
#define EMBEDDED_FPGAAVALON_H

#include "IfpgaInterface.h"
#include <string>
#include <mutex>
#include <thread>
#include <atomic>
#include <condition_variable>
#include <queue>

/**
 * @class FpgaAvalon
 * @brief Implementation of the IfpgaInterface for accessing FPGA via a socket connection.
 */
class FpgaAvalon : public IfpgaInterface {
public:
    explicit FpgaAvalon(uint16_t port, bool waitForConnection = true);

    ~FpgaAvalon() override;

    void sendToFpga(unsigned reg, unsigned val) override;

    int16_t readFromFpga(unsigned reg) override;

    void setInterruptHandler(irq_handler_t newHandler) override { handler = newHandler; }

    bool isConnected() override;

    void endTest() override;

    void setFileName(const std::string &filePath) const;

    std::condition_variable receivedCondVar;

private:
    void waitConnection();

    void server(unsigned port);

    void receiver();

    int client_sock = 0;
    int server_sock = 0;

    std::thread fpgaServerThread;
    std::thread receiverThread;
    std::queue<std::string> receivedFifo;
    std::mutex receiveMutex;
    irq_handler_t handler = nullptr;
};

#endif // EMBEDDED_FPGAAVALON_H
