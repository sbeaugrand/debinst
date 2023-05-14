#include <QThreadPool>
#include <QEvent>
#include <iostream>
#include "mainwindow.h"

MainWindow::MainWindow(QWidget* parent)
    : QMainWindow(parent)
{
    // Create the button, make "this" the parent
    m_button = new QPushButton("My Button", this);
    // set size and location of the button
    m_button->setGeometry(QRect(QPoint(100, 100), QSize(200, 50)));

    // Connect button signal to appropriate slot
    connect(m_button, &QPushButton::released, this, &MainWindow::handleButton);

    mMessageJob = new MessageJob("localhost",
                                 AMQP_PROTOCOL_PORT,
                                 "projectqueue");
    //connect(this, &MainWindow::quitSignal, mMessageJob, &MessageJob::quit);
    connect(mMessageJob, &MessageJob::quitSignal, this, &MainWindow::quit);
    QThreadPool::globalInstance()->start(mMessageJob);
}

void MainWindow::quit()
{
    emit quitSignal();
}

bool MainWindow::event(QEvent* event)
{
    if (event->type() == QEvent::Close) {
        mMessageJob->quit();
    }
    return QMainWindow::event(event);
}

void MainWindow::handleButton()
{
    m_button->setText("Example");
}
