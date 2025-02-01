#include "fpgaAvalon.h"

#include <cstring>
#include <iostream>
#include <sstream>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h> //inet_addr

FpgaAvalon::FpgaAvalon(uint16_t port, bool waitForConnection) {
    fpgaServerThread =
            std::thread([this, port] { server(port); });
    receiverThread = std::thread(&FpgaAvalon::receiver, this);

    if (waitForConnection)
        waitConnection();
}

FpgaAvalon::~FpgaAvalon() {
    if (FpgaAvalon::isConnected()) {
        std::cout << "Closing connection on client socket" << std::endl;
        shutdown(client_sock, SHUT_RDWR);
        close(client_sock);
        client_sock = 0;
    }

    if (server_sock > 0) {
        std::cout << "Closing connection on server socket" << std::endl;
        close(server_sock);
        shutdown(server_sock, SHUT_RDWR);
        server_sock = 0;
    }

    if (fpgaServerThread.joinable())
        fpgaServerThread.join();

    if (receiverThread.joinable())
        receiverThread.join();
}

void FpgaAvalon::sendToFpga(const unsigned reg, const unsigned val) {
    std::stringstream stream;
    stream << "wr " << reg << ' ' << val << std::endl;

    write(client_sock, stream.str().c_str(), stream.str().size());
}

int16_t FpgaAvalon::readFromFpga(const unsigned reg) {
    std::stringstream stream;
    stream << "rd " << reg << std::endl;
    write(client_sock, stream.str().c_str(), stream.str().size());

    std::unique_lock<std::mutex> lk(receiveMutex);

    receivedCondVar.wait(lk, [this] { return !receivedFifo.empty(); });

    std::string message = receivedFifo.front();
    receivedFifo.pop();

    std::stringstream messageStream(message);

    std::string command;
    u_int16_t value;
    messageStream >> command >> value;
    return (int16_t)value;
}

void FpgaAvalon::server(unsigned port) {
    int c;
    sockaddr_in server = {}, client = {};

    //Create socket
    server_sock = socket(AF_INET, SOCK_STREAM, 0);
    if (server_sock == -1) {
        throw std::runtime_error("Could not create socket");
    }
    puts("Socket created");

    //Prepare the sockaddr_in structure
    server.sin_family = AF_INET;
    server.sin_addr.s_addr = INADDR_ANY;
    server.sin_port = htons(port);

    //Bind
    if (bind(server_sock, (struct sockaddr *) &server, sizeof(server)) < 0) {
        perror("bind failed. Error");
        throw std::runtime_error("bind failed");
    }
    puts("bind done");

    //Listen
    listen(server_sock, 3);

    //Accept and incoming connection
    puts("Waiting for incoming connections...");
    c = sizeof(struct sockaddr_in);

    client_sock = accept(server_sock, (struct sockaddr *) &client,
                         (socklen_t *) &c);

    if (client_sock <= 0) {
        perror("accept failed");
        throw std::runtime_error("accept failed");
    }

    puts("Connection accepted");

    receivedCondVar.notify_all();

    puts("Handler assigned");
}

void FpgaAvalon::receiver() {
    char clientMessage[2000];
    char messageCommand[2000];
    int read_size;

    waitConnection();

    while ((read_size = (int)recv(client_sock, clientMessage, 2000, 0)) > 0) {
        clientMessage[read_size] = '\0';

        std::stringstream stream(clientMessage);
        stream >> messageCommand;

        if (strcmp(messageCommand, "irq") == 0) {
            if (handler != nullptr) {
                std::string clientStr(clientMessage);
                handler(clientStr);
            } else {
                std::cout << "IRQ received, but no handler!"
                          << std::endl;
            }
        } else {
            // We got a response to a command, add it to the FIFO and inform responsible thread
            std::unique_lock<std::mutex> lk(receiveMutex);

            receivedFifo.emplace(clientMessage);
            receivedCondVar.notify_all();
        }
    }
}

void FpgaAvalon::waitConnection() {
    std::unique_lock<std::mutex> lk(receiveMutex);
    receivedCondVar.wait(lk, [this] { return isConnected(); });
}

bool FpgaAvalon::isConnected() {
    return client_sock != 0;
}

void FpgaAvalon::endTest() {
    if (isConnected()) {
        std::string message = "end_test\n";
        write(client_sock, message.c_str(), message.length());
    }
}

void FpgaAvalon::setFileName(const std::string &filePath) const {
    std::string message = "file_set " + filePath + '\n';
    write(client_sock, message.c_str(), message.length());
}
