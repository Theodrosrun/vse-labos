#include "spikeDetectorManager.h"
#include "spikeDetectorUtils.h"

#include <iostream>
#include <mutex>
#include <queue>

#include "fpgaAvalon.h"

std::mutex irqMutex;
std::condition_variable irqCondVar;
std::queue<std::string> irqFifo;

std::queue<std::shared_ptr<SpikeWindow> > spikeRefFifo;

void handler(std::string &message) {
    std::cout << "Received new IRQ: " << message << std::endl;
    irqFifo.push(message);
    irqCondVar.notify_all();
}

int main(int /*_argc*/, char ** /*_argv*/) {
    std::string path = DEFAULT_FILE_PATH;
    SpikeDetectorUtils::getReferenceSpikes(spikeRefFifo, path);

    auto interface = std::make_unique<FpgaAvalon>(8888);
    interface->setFileName("../input_values.txt");

    SpikeDetectorManager::Init(std::move(interface));
    const SpikeDetectorManager &spikeDetector = SpikeDetectorManager::getInstance();
    std::unique_lock<std::mutex> lk(irqMutex);
    spikeDetector.setInterruptHandler(handler);

    int spikeCount = 0;

    // TODO -> CJS Test it with more case in gtest
    const int SPIKES_BEFORE_STOP = 2;
    bool acquisitionRestarted = false;


    std::cout << "Current status: " << spikeDetector.getStatus() << std::endl;
    std::cout << "Starting acquisition" << std::endl;
    spikeDetector.startAcquisition();
    std::cout << "Current status: " << spikeDetector.getStatus() << std::endl;

    while (irqCondVar.wait_for(lk, std::chrono::seconds(600),
                               [] { return !irqFifo.empty(); })) {
        SpikeWindow window;

        std::cout << "New window at address: "
                  << spikeDetector.getWindowsAddress() << std::endl;
        std::cout << "Reading window" << std::endl;

        spikeDetector.readWindow(window);
        irqFifo.pop();

        if (SpikeDetectorUtils::compareWindow(&window, spikeRefFifo)) {
            std::cout << "Window is valid" << std::endl;
            spikeCount++;

            if (spikeCount == SPIKES_BEFORE_STOP && !acquisitionRestarted) {
                std::cout << "Stopping acquisition after " << SPIKES_BEFORE_STOP << " spikes" << std::endl;
                spikeDetector.stopAcquisition();
                std::cout << "Current status: " << spikeDetector.getStatus() << std::endl;

                std::this_thread::sleep_for(std::chrono::seconds(2));

                std::cout << "Restarting acquisition" << std::endl;
                spikeDetector.startAcquisition();
                std::cout << "Current status: " << spikeDetector.getStatus() << std::endl;
                acquisitionRestarted = true;
            }
        } else {
            std::cout << "Window is not valid" << std::endl;
        }
    }

    std::cout << "Stopping acquisition" << std::endl;
    spikeDetector.stopAcquisition();
    std::cout << "Current status: " << spikeDetector.getStatus() << std::endl;

    return EXIT_SUCCESS;
}
