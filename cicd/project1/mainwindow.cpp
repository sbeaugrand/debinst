#include <QApplication>
#include <QThreadPool>
#include <QEvent>
#include <iostream>
#include "mainwindow.h"
#include "mqexception.h"

MainWindow::MainWindow(QWidget* parent)
    : QMainWindow(parent)
{
    mButton = new QPushButton("My Button", this);
    mButton->setGeometry(QRect(QPoint(100, 100), QSize(200, 50)));
    connect(mButton, &QPushButton::released,
            this, &MainWindow::handleButton);

    mMessageJob = new mq::MessageJob(
        QApplication::applicationName().toStdString());

    connect(mMessageJob, &mq::MessageJob::clickSignal,
            mButton, &QPushButton::click);
    connect(mMessageJob, &mq::MessageJob::closeSignal,
            this, &MainWindow::quit);

    QThreadPool::globalInstance()->start(mMessageJob);
}

void MainWindow::quit()
{
    emit quitSignal();
}

bool MainWindow::event(QEvent* event)
{
    if (event->type() == QEvent::Close) {
        mMessageJob->close();
    }
    return QMainWindow::event(event);
}

void MainWindow::handleButton()
{
    mButton->setText("Example");
}
