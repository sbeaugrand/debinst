/******************************************************************************!
 * \file client.h
 * \sa https://doc.qt.io/qt-5/qtwebsockets-examples.html
 ******************************************************************************/
#pragma once
#include <QtCore/QObject>
#include <QtWebSockets/QWebSocket>

class EchoClient : public QObject
{
    Q_OBJECT
public:
    explicit EchoClient(const QUrl& url, bool debug = false,
                        QObject* parent = nullptr);

Q_SIGNALS:
    void closed();

private Q_SLOTS:
    void onConnected();
    void onTextMessageReceived(QString message);

private:
    QWebSocket m_webSocket;
    QUrl m_url;
    bool m_debug;
};
