#include <gtest/gtest.h>
#include "spikeDetectorManager.h"
#include "spikeDetectorUtils.h"
#include "fpgaAvalon.h"
#include <chrono>
#include <thread>
#include <sys/wait.h>
#include <unistd.h>

#define QUESTA_CMD "cd ../../fpga_sim/ && export PROJ_HOME=$(pwd) && ./arun.sh -tool questa -c"

template<typename T>
class SpikeDetectorTestBase {
protected:
    static pid_t questaProcess;
    static std::shared_ptr<FpgaAvalon> interface;
    static const SpikeDetectorManager *spikeDetector;
    static std::queue<std::shared_ptr<SpikeWindow> > spikeRefFifo;
    static std::condition_variable irqCondVar;
    static std::queue<std::string> irqFifo;

    std::mutex irqMutex;

    static void startQuesta() {
        system("pkill -f vsimk || true");
        std::string cmd = QUESTA_CMD;
        questaProcess = fork();
        if (questaProcess == 0) {
            system(cmd.c_str());
            exit(0);
        }
        std::this_thread::sleep_for(std::chrono::seconds(2));
    }

    static void stopQuesta() {
        if (questaProcess > 0) {
            system("pkill -f vsimk || true");
            waitpid(questaProcess, nullptr, 0);
            questaProcess = 0;
        }
    }

    static void interruptHandler(std::string &message) {
        irqFifo.push(message);
        irqCondVar.notify_all();
    }

    static void setupCommonInfrastructure(const std::string &filePathFpga, const std::string &filePathHost) {
        interface = std::make_shared<FpgaAvalon>(8888);
        interface->setFileName(filePathFpga);
        SpikeDetectorManager::Init(interface);
        spikeDetector = &SpikeDetectorManager::getInstance();
        SpikeDetectorUtils::getReferenceSpikes(spikeRefFifo, filePathHost);
    }

    bool waitForInterrupt(int timeoutSeconds = 240) {
        std::unique_lock<std::mutex> lk(irqMutex);
        return irqCondVar.wait_for(lk, std::chrono::seconds(timeoutSeconds),
                                   [this] { return !irqFifo.empty(); });
    }

    static void cleanup() {
        if (spikeDetector) {
            SpikeDetectorManager::Destroy();
            spikeDetector = nullptr;
        }
        if (interface) {
            interface->endTest();
            interface.reset();
            interface = nullptr;
        }
    }
};

// Initialize static members for each test class
// This is necessary to use template classes to avoid sharing same
// process, interface etc, between tests suites.
template<typename T>
pid_t SpikeDetectorTestBase<T>::questaProcess = 0;
template<typename T>
std::shared_ptr<FpgaAvalon> SpikeDetectorTestBase<T>::interface = nullptr;
template<typename T>
const SpikeDetectorManager *SpikeDetectorTestBase<T>::spikeDetector = nullptr;
template<typename T>
std::queue<std::shared_ptr<SpikeWindow> > SpikeDetectorTestBase<T>::spikeRefFifo = {};
template<typename T>
std::condition_variable SpikeDetectorTestBase<T>::irqCondVar = {};
template<typename T>
std::queue<std::string> SpikeDetectorTestBase<T>::irqFifo = {};
