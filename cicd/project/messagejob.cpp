/******************************************************************************!
 * \file messagejob.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <unistd.h>
#include <amqp.h>
#include <amqp_tcp_socket.h>
#include <iostream>
#include "messagejob.h"
#include "mqexception.h"

namespace mq {

/******************************************************************************!
 * \fn open
 ******************************************************************************/
void
MessageJob::open()
{
    mConn = amqp_new_connection();

    auto sock = amqp_tcp_socket_new(mConn);
    if (sock == NULL) {
        throw Exception("amqp_tcp_socket_new");
    }

    auto status = amqp_socket_open(sock, hostname.c_str(), port);
    if (status != AMQP_STATUS_OK) {
        throw Exception("amqp_socket_open", status);
    }

    auto res = amqp_login(mConn, "/", 0, 131072, 0,
                          AMQP_SASL_METHOD_PLAIN, "guest", "guest");
    if (res.reply_type != AMQP_RESPONSE_NORMAL) {
        throw Exception(res);
    }

    amqp_channel_open(mConn, 1);
    res = amqp_get_rpc_reply(mConn);
    if (res.reply_type != AMQP_RESPONSE_NORMAL) {
        throw Exception(res);
    }

    amqp_queue_declare(mConn, 1, amqp_cstring_bytes(mQueueName.c_str()),
                       0,  // passive
                       0,  // durable
                       0,  // exclusive
                       1,  // auto_delete
                       amqp_empty_table);
    res = amqp_get_rpc_reply(mConn);
    if (res.reply_type != AMQP_RESPONSE_NORMAL) {
        throw Exception(res);
    }

    amqp_basic_consume(mConn, 1, amqp_cstring_bytes(mQueueName.c_str()),
                       amqp_empty_bytes,
                       0,  // no_local
                       1,  // no_ack
                       0,  // exclusive
                       amqp_empty_table);
    res = amqp_get_rpc_reply(mConn);
    if (res.reply_type != AMQP_RESPONSE_NORMAL) {
        throw Exception(res);
    }

    amqp_maybe_release_buffers(mConn);
}

/******************************************************************************!
 * \fn run
 ******************************************************************************/
void
MessageJob::run()
{
    while (mLoop) {
        try {
            this->loop();
        } catch (const Exception& e) {
            std::cerr << "error: " << e.what() << std::endl;
            sleep(5);
            try {
                this->destroy();
            } catch (const Exception&) {
            }
            mConn = nullptr;
        }
    }

    try {
        this->destroy();
    } catch (const Exception& e) {
        std::cerr << "error: " << e.what() << std::endl;
    }
}

/******************************************************************************!
 * \fn loop
 ******************************************************************************/
void
MessageJob::loop()
{
    amqp_envelope_t envelope;
    struct timeval timeout = { 1, 0 };

    if (mConn == nullptr) {
        this->open();
    }

    auto res = amqp_consume_message(mConn, &envelope, &timeout, 0);

    if (res.reply_type == AMQP_RESPONSE_LIBRARY_EXCEPTION &&
        res.library_error == AMQP_STATUS_TIMEOUT) {
        return;
    }
    if (res.reply_type != AMQP_RESPONSE_NORMAL) {
        throw Exception(res);
    }

    std::string str(static_cast<const char*>(envelope.message.body.bytes),
                    envelope.message.body.len);
    /*  */ if (str == "status") {
        this->reply("status: ok", envelope);
    } else if (str == "click") {
        this->reply("click: ok", envelope);
        emit clickSignal();
    } else if (str == "quit") {
        this->reply("quit: ok", envelope);
        emit closeSignal();
    }

    amqp_destroy_envelope(&envelope);
}

/******************************************************************************!
 * \fn reply
 ******************************************************************************/
void
MessageJob::reply(const std::string& msg,
                  const amqp_envelope_t& envelope) const
{
    amqp_basic_properties_t props;
    props._flags =
        AMQP_BASIC_CONTENT_TYPE_FLAG |
        AMQP_BASIC_DELIVERY_MODE_FLAG |
        AMQP_BASIC_CORRELATION_ID_FLAG;
    props.content_type = amqp_cstring_bytes("text/plain");
    props.delivery_mode = 1;
    props.correlation_id = envelope.message.properties.correlation_id;

    auto status = amqp_basic_publish(mConn, 1,
                                     amqp_cstring_bytes(""),
                                     envelope.message.properties.reply_to,
                                     1,  // mandatory
                                     0,  // immediate
                                     &props,
                                     amqp_cstring_bytes(msg.c_str()));
    if (status != AMQP_STATUS_OK) {
        throw Exception("amqp_basic_publish", status);
    }
}

/******************************************************************************!
 * \fn destroy
 ******************************************************************************/
void
MessageJob::destroy()
{
    if (mConn == nullptr) {
        return;
    }

    auto res = amqp_channel_close(mConn, 1, AMQP_REPLY_SUCCESS);
    if (res.reply_type != AMQP_RESPONSE_NORMAL) {
        throw Exception(res);
    }

    res = amqp_connection_close(mConn, AMQP_REPLY_SUCCESS);
    if (res.reply_type != AMQP_RESPONSE_NORMAL) {
        throw Exception(res);
    }

    auto status = amqp_destroy_connection(mConn);
    if (status != AMQP_STATUS_OK) {
        throw Exception("amqp_destroy_connection", status);
    }

    mConn = nullptr;
}

}
