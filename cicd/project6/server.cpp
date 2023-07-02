/******************************************************************************!
 * \file server.cpp
 * \sa https://doc.qt.io/qt-5/qtwebsockets-examples.html
 ******************************************************************************/
#include <QtCore/QCoreApplication>
#include <QtCore/QCommandLineParser>
#include <QtCore/QCommandLineOption>
#include <QtCore/QDebug>

#include "QtWebSockets/qwebsocketserver.h"
#include "QtWebSockets/qwebsocket.h"
#include "server.h"

QT_USE_NAMESPACE

EchoServer::EchoServer(quint16 port, bool debug, QObject* parent) :
    QObject(parent),
    m_pWebSocketServer(new QWebSocketServer(QStringLiteral("Echo Server"),
                                            QWebSocketServer::NonSecureMode,
                                            this)),
    m_debug(debug)
{
    if (m_pWebSocketServer->listen(QHostAddress::Any, port)) {
        if (m_debug) {
            qDebug() << "Echoserver listening on port" << port;
        }
        connect(m_pWebSocketServer, &QWebSocketServer::newConnection,
                this, &EchoServer::onNewConnection);
        connect(m_pWebSocketServer, &QWebSocketServer::closed,
                this, &EchoServer::closed);
    }
}

EchoServer::~EchoServer()
{
    m_pWebSocketServer->close();
    qDeleteAll(m_clients.begin(), m_clients.end());
}

void EchoServer::onNewConnection()
{
    QWebSocket* pSocket = m_pWebSocketServer->nextPendingConnection();
    if (m_debug) {
        qDebug() << "onNewConnection:" << pSocket;
    }
    connect(pSocket, &QWebSocket::textMessageReceived,
            this, &EchoServer::processTextMessage);
    connect(pSocket, &QWebSocket::disconnected, this,
            &EchoServer::socketDisconnected);

    m_clients << pSocket;
}

void EchoServer::processTextMessage(QString message)
{
    QWebSocket* pClient = qobject_cast<QWebSocket*>(sender());
    if (m_debug) {
        qDebug() << "Message received:" << message;
    }
    if (pClient) {
        if (message == "status") {
            pClient->sendTextMessage("alert");
        }
        pClient->sendTextMessage(message);
    }
}

void EchoServer::socketDisconnected()
{
    QWebSocket* pClient = qobject_cast<QWebSocket*>(sender());
    if (m_debug) {
        qDebug() << "socketDisconnected:" << pClient;
    }
    if (pClient) {
        m_clients.removeAll(pClient);
        pClient->deleteLater();
    }
    m_pWebSocketServer->close();
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int argc, char** argv)
{
    QCoreApplication a(argc, argv);

    QCommandLineParser parser;
    parser.setApplicationDescription("QtWebSockets example: echoserver");
    parser.addHelpOption();

    QCommandLineOption
        dbgOption(QStringList() << "d" << "debug",
                  QCoreApplication::translate(
                      "main", "Debug output [default: off]."));
    parser.addOption(dbgOption);
    QCommandLineOption
        portOption(QStringList() << "p" << "port",
                   QCoreApplication::translate(
                       "main", "Port for echoserver [default: 1234]."),
                   QCoreApplication::translate(
                       "main", "port"), QLatin1String("1234"));
    parser.addOption(portOption);
    parser.process(a);
    bool debug = parser.isSet(dbgOption);
    int port = parser.value(portOption).toInt();

    EchoServer* server = new EchoServer(port, debug);
    QObject::connect(server, &EchoServer::closed, &a, &QCoreApplication::quit);

    return a.exec();
}
