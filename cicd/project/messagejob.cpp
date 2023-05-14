#include <amqp.h>
#include <amqp_tcp_socket.h>
#include <iostream>
#include "messagejob.h"

MessageJob::MessageJob(const char* hostname, int port, const char* queuename)
{
    mConn = amqp_new_connection();

    mSocket = amqp_tcp_socket_new(mConn);
    if (! mSocket) {
        perror("creating TCP socket");
        exit(1);
    }

    int status = amqp_socket_open(mSocket, hostname, port);
    if (status) {
        perror("opening TCP socket");
        exit(1);
    }

    amqp_login(mConn, "/", 0, 131072, 0,
               AMQP_SASL_METHOD_PLAIN, "guest", "guest");
    amqp_channel_open(mConn, 1);
    amqp_get_rpc_reply(mConn);

    amqp_basic_consume(mConn, 1, amqp_cstring_bytes(queuename),
                       amqp_empty_bytes, 0, 1, 0,
                       amqp_empty_table);
    amqp_get_rpc_reply(mConn);

    amqp_maybe_release_buffers(mConn);
}

MessageJob::~MessageJob()
{
    amqp_channel_close(mConn, 1, AMQP_REPLY_SUCCESS);
    amqp_connection_close(mConn, AMQP_REPLY_SUCCESS);
    amqp_destroy_connection(mConn);
}

void MessageJob::run()
{
    amqp_rpc_reply_t res;
    amqp_envelope_t envelope;
    struct timeval timeout = { 1, 0 };

    while (! mQuit) {
        res = amqp_consume_message(mConn, &envelope, &timeout, 0);

        if (AMQP_RESPONSE_LIBRARY_EXCEPTION == res.reply_type &&
            res.library_error == AMQP_STATUS_TIMEOUT) {
            continue;
        }
        if (AMQP_RESPONSE_NORMAL != res.reply_type) {
            std::cerr << res.reply_type << std::endl;
            std::cerr << res.library_error << std::endl;
            break;
        }

        if (envelope.message.properties._flags &
            AMQP_BASIC_CONTENT_TYPE_FLAG) {
            printf("Content-type: %.*s\n",
                   (int) envelope.message.properties.content_type.len,
                   (char*) envelope.message.properties.content_type.bytes);
        }

        std::string str(static_cast<const char*>(envelope.message.body.bytes),
                        envelope.message.body.len);
        std::cerr << "Message: " << str << std::endl;
        /*  */ if (str == "status") {
        } else if (str == "quit") {
            emit quitSignal();
        }

        amqp_destroy_envelope(&envelope);
    }
}

void MessageJob::quit()
{
    mQuit = true;
}
