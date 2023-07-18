/******************************************************************************!
 * \file client.cpp
 * \sa https://doc.qt.io/qt-5/qtwebsockets-examples.html
 ******************************************************************************/
#include <QtCore/QCoreApplication>
#include <QtCore/QCommandLineParser>
#include <QtCore/QCommandLineOption>
#include <QtCore/QDebug>

#include "client.h"

QT_USE_NAMESPACE

EchoClient::EchoClient(const QUrl& url, bool debug, QObject* parent) :
    QObject(parent),
    m_url(url),
    m_debug(debug)
{
    if (m_debug) {
        qDebug() << "WebSocket server:" << url;
    }
    connect(&m_webSocket, &QWebSocket::connected,
            this, &EchoClient::onConnected);
    connect(&m_webSocket, &QWebSocket::disconnected,
            this, &EchoClient::closed);
    m_webSocket.open(QUrl(url));
}

void EchoClient::onConnected()
{
    if (m_debug) {
        qDebug() << "WebSocket connected";
    }
    connect(&m_webSocket, &QWebSocket::textMessageReceived,
            this, &EchoClient::onTextMessageReceived);
    m_webSocket.sendTextMessage(QStringLiteral("status"));
}

void EchoClient::onTextMessageReceived(QString message)
{
    if (m_debug) {
        qDebug() << "Message received:" << message;
    }
    if (message == "status") {
        m_webSocket.sendTextMessage(QStringLiteral("quit"));
    } else if (message == "quit") {
        m_webSocket.close();
    }
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int argc, char** argv)
{
    QCoreApplication a(argc, argv);

    QCommandLineParser parser;
    parser.setApplicationDescription("QtWebSockets example: echoclient");
    parser.addHelpOption();

    QCommandLineOption
        dbgOption(QStringList() << "d" << "debug",
                  QCoreApplication::translate(
                      "main", "Debug output [default: off]."));

    QCommandLineOption
        urlOption(QStringList() << "u" << "url",
                  QCoreApplication::translate(
                      "main", "[ws://localhost:1234]."),
                  QCoreApplication::translate(
                      "main", "url"), QLatin1String("ws://localhost:1234"));

    parser.addOption(dbgOption);
    parser.addOption(urlOption);
    parser.process(a);
    bool debug = parser.isSet(dbgOption);
    QUrl url(parser.value(urlOption));

    EchoClient client(url, debug);
    QObject::connect(&client, &EchoClient::closed, &a, &QCoreApplication::quit);

    return a.exec();
}
