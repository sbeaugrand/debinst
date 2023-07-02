/******************************************************************************!
 * \file server.h
 * \sa https://doc.qt.io/qt-5/qtwebsockets-examples.html
 ******************************************************************************/
#pragma once
#include <QtCore/QObject>
#include <QtCore/QList>
#include <QtCore/QByteArray>

QT_FORWARD_DECLARE_CLASS(QWebSocketServer)
QT_FORWARD_DECLARE_CLASS(QWebSocket)

class EchoServer : public QObject
{
    Q_OBJECT
public:
    explicit EchoServer(quint16 port, bool debug = false,
                        QObject* parent = nullptr);
    ~EchoServer();

Q_SIGNALS:
    void closed();

private Q_SLOTS:
    void onNewConnection();
    void processTextMessage(QString message);
    void socketDisconnected();

private:
    QWebSocketServer* m_pWebSocketServer;
    QList<QWebSocket*> m_clients;
    bool m_debug;
};
