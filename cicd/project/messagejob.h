#ifndef MESSAGEJOB_H
#define MESSAGEJOB_H

#include <amqp.h>
#include <amqp_tcp_socket.h>
#include <QObject>
#include <QRunnable>

class MessageJob : public QObject, public QRunnable
{
    Q_OBJECT
public:
    MessageJob(const char* hostname, int port, const char* queuename);
    virtual ~MessageJob();
    virtual void run();
    void quit();
signals:
    void quitSignal();
private:
    amqp_connection_state_t mConn;
    amqp_socket_t* mSocket = nullptr;
    bool mQuit = false;
};

#endif
