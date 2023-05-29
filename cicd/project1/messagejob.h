/******************************************************************************!
 * \file messagejob.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#pragma once
#include <amqp.h>
#include <amqp_tcp_socket.h>
#include <QObject>
#include <QRunnable>

namespace mq {

class MessageJob : public QObject, public QRunnable
{
    Q_OBJECT
public:
    explicit MessageJob(const std::string& name) : mQueueName(name) {}
    virtual void run();
    void open();
    void close() { mLoop = false; }

    std::string hostname = "localhost";
    int port = AMQP_PROTOCOL_PORT;
signals:
    void clickSignal();
    void closeSignal();
private:
    void loop();
    void reply(const std::string& response,
               const amqp_envelope_t& envelope) const;
    void destroy();

    std::string mQueueName;
    bool mLoop = true;
    amqp_connection_state_t mConn = nullptr;
};

}
