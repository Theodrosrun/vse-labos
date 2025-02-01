#include <gtest/gtest.h>
#include "fpgaAvalon.h"

#include <future>
#include <thread>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>

class MockFPGA {
public:
    explicit MockFPGA(uint16_t port) {
        sock = socket(AF_INET, SOCK_STREAM, 0);
        EXPECT_GT(sock, 0) << "Socket creation failed";

        sockaddr_in server{.sin_family = AF_INET, .sin_port = htons(port)};
        server.sin_addr.s_addr = inet_addr("127.0.0.1");

        int retries = 0;
        while (connect(sock, reinterpret_cast<sockaddr *>(&server), sizeof(server)) < 0) {
            if (++retries > 10) {
                throw std::runtime_error("Failed to connect to mock FPGA");
            }
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
        }
    }

    ~MockFPGA() {
        if (sock > 0) {
            close(sock);
        }
    }

    void expectWrite(unsigned reg, unsigned val) const {
        char buffer[256];
        ssize_t bytes = recv(sock, buffer, sizeof(buffer) - 1, 0);
        ASSERT_GT(bytes, 0);
        buffer[bytes] = '\0';

        std::stringstream expected;
        expected << "wr " << reg << " " << val << std::endl;
        ASSERT_STREQ(buffer, expected.str().c_str());
    }

    void respondToRead(unsigned val) const {
        std::stringstream response;
        response << "rd " << val << std::endl;
        std::string resp = response.str();
        send(sock, resp.c_str(), resp.length(), 0);
    }

    void sendInterrupt(const std::string &message) const {
        std::string irq = "irq " + message + "\n";
        send(sock, irq.c_str(), irq.length(), 0);
    }

    int sock;
};

class FpgaAvalonTest : public ::testing::Test {
protected:
    void SetUp() override {
        interface = std::make_unique<FpgaAvalon>(1234, false);
        mockFpga = std::make_unique<MockFPGA>(1234);
        usleep(10000);
    }

    void TearDown() override {
        mockFpga.reset();
        interface.reset();
        usleep(10000);
    }

    static void irqHandler(std::string &msg) {
        handlerCalled = true;
        receivedMessage = msg;
    }

    static std::atomic<bool> handlerCalled;
    static std::string receivedMessage;

    std::unique_ptr<FpgaAvalon> interface;
    std::unique_ptr<MockFPGA> mockFpga;
};

std::atomic<bool> FpgaAvalonTest::handlerCalled{false};
std::string FpgaAvalonTest::receivedMessage;

TEST_F(FpgaAvalonTest, TestConnection) {
    ASSERT_TRUE(interface->isConnected());
}

TEST_F(FpgaAvalonTest, TestWriteToFPGA) {
    constexpr unsigned REG = 0x42;
    constexpr unsigned VAL = 0x1234;

    interface->sendToFpga(REG, VAL);
    mockFpga->expectWrite(REG, VAL);
}

TEST_F(FpgaAvalonTest, TestReadFromFPGA) {
    constexpr unsigned REG = 0x42;
    constexpr unsigned EXPECTED_VAL = 0x1234;

    auto future = std::async(std::launch::async, [this, REG]() {
        return interface->readFromFpga(REG);
    });

    mockFpga->respondToRead(EXPECTED_VAL);
    ASSERT_EQ(future.get(), EXPECTED_VAL);
}

TEST_F(FpgaAvalonTest, TestInterruptHandler) {
    interface->setInterruptHandler(irqHandler);

    const std::string TEST_MESSAGE = "test_interrupt";
    mockFpga->sendInterrupt(TEST_MESSAGE);

    // Allow time for handler to be called
    std::this_thread::sleep_for(std::chrono::milliseconds(1000));

    EXPECT_TRUE(handlerCalled);

    ASSERT_STREQ("irq test_interrupt\n", receivedMessage.c_str());
}

TEST_F(FpgaAvalonTest, TestEndTest) {
    char buffer[256];

    interface->endTest();

    ssize_t bytes = recv(mockFpga->sock, buffer, sizeof(buffer) - 1, 0);
    ASSERT_GT(bytes, 0);
    buffer[bytes] = '\0';

    ASSERT_STREQ(buffer, "end_test\n");
}

TEST_F(FpgaAvalonTest, TestSetFileName) {
    const std::string TEST_FILE = "test.bin";
    char buffer[256];

    interface->setFileName(TEST_FILE);

    ssize_t bytes = recv(mockFpga->sock, buffer, sizeof(buffer) - 1, 0);
    ASSERT_GT(bytes, 0);
    buffer[bytes] = '\0';

    std::string expected = "file_set " + TEST_FILE + "\n";
    ASSERT_EQ(buffer, expected);
}

TEST_F(FpgaAvalonTest, TestMultipleReads) {
    for (int i = 0; i < 5; i++) {
        auto future = std::async(std::launch::async, [this, i]() {
            return interface->readFromFpga(i);
        });
        mockFpga->respondToRead(i * 2);
        EXPECT_EQ(future.get(), i * 2);
    }
}
