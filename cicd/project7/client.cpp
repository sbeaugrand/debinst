/******************************************************************************!
 * \file client.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <iostream>
#include <thread>
#include <mutex>
#include <string.h>

#include <nng/nng.h>
#include <nng/protocol/pair0/pair.h>

using namespace std::chrono_literals;

/******************************************************************************!
 * \class RecvThread
 ******************************************************************************/
class RecvThread
{
public:
    explicit RecvThread(nng_socket sock) {
        mThread = std::thread(RecvThread::run, this, sock);
    }
    ~RecvThread() {
        loop = false;
        mThread.join();
    }
    std::string getMessage() {
        std::lock_guard<std::mutex> guard(mutex);
        empty = true;
        return message;
    }

    std::atomic_bool loop = true;
    std::atomic_bool empty = true;
    std::mutex mutex;
    std::string message;
private:
    static void run(RecvThread* self, nng_socket sock) {
        char* buf = NULL;
        size_t sz;
        int rv;

        while (self->loop) {
            std::cout << "thread: recv ..." << std::endl;
            if ((rv = nng_recv(sock, &buf, &sz, NNG_FLAG_ALLOC)) != 0) {
                std::cerr << "thread: nng_recv "
                          << nng_strerror(rv) << std::endl;
                std::this_thread::sleep_for(500ms);
                continue;
            }
            if (strcmp(buf, "alert") == 0) {
                std::cout << "thread: alert" << std::endl;
            } else {
                std::cout << "thread: recv "
                          << buf << std::endl;
                while (! self->empty) {
                    std::this_thread::sleep_for(100ms);
                }
                std::lock_guard<std::mutex> guard(self->mutex);
                self->message = buf;
                self->empty = false;
            }
            nng_free(buf, sz);
        }
    }

    std::thread mThread;
};

/******************************************************************************!
 * \fn rpc
 ******************************************************************************/
void
rpc(RecvThread& recvThread, nng_socket sock, const char* method)
{
    int rv;

    std::cout << "client: send "
              << method << std::endl;
    rv = nng_send(sock, const_cast<char*>(method), strlen(method) + 1, 0);
    if (rv != 0) {
        std::cerr << "client: nng_send "
                  << nng_strerror(rv) << std::endl;
    }
    while (recvThread.empty) {
        std::this_thread::sleep_for(100ms);
    }
    std::cout << "client: recv "
              << recvThread.getMessage() << std::endl;
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int argc, char** argv)
{
    if (argc != 2) {
        return 1;
    }
    const char* url = argv[1];

    nng_socket sock;
    int rv;

    if ((rv = nng_pair0_open(&sock)) != 0) {
        std::cerr << "client: nng_pair0_open "
                  << nng_strerror(rv) << std::endl;
    }
    if ((rv = nng_dial(sock, url, NULL, 0)) != 0) {
        std::cerr << "client: nng_dial "
                  << nng_strerror(rv) << std::endl;
    }
    if ((rv = nng_setopt_ms(sock, NNG_OPT_RECVTIMEO, 100)) != 0) {
        std::cerr << "client: nng_setopt_ms "
                  << nng_strerror(rv) << std::endl;
    }

    {
        RecvThread recvThread(sock);
        rpc(recvThread, sock, "status");
        rpc(recvThread, sock, "emit alert");
        rpc(recvThread, sock, "quit");
    }
    nng_close(sock);

    return 0;
}
