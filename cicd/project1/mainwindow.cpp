#include <QApplication>
#include <QThreadPool>
#include <QEvent>
#include <iostream>
#include "mainwindow.h"
#include "mqexception.h"

#include <iostream>
G_DEFINE_TYPE(TestGReceiver, TestReceiver, G_TYPE_OBJECT)
static void TestReceiver_class_init(TestGReceiverClass* /*self*/) {
}
static void TestReceiver_init(TestGReceiver* self) {
    self->testSlot = NULL;
}
//static void gTestSlot(_TestGReceiver* /*receiver*/) {
//    std::cout << "info: signal received" << std::endl;
//}
static void
notify(GObject* /*object*/, GParamSpec* /*spec*/, gpointer /*user_data*/)
{
    std::cout << "notify: signal received" << std::endl;
}

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

    mTestGReceiver = static_cast<TestGReceiver*>(
        g_object_new(TestReceiver_get_type(), NULL));
    //mTestGReceiver->testSlot = gTestSlot;
    mSignal = g_signal_new(
        "test-signal",
        G_TYPE_OBJECT,
        G_SIGNAL_RUN_LAST,
        //G_STRUCT_OFFSET(_TestGReceiver, testSlot),
        0,
        NULL,
        NULL,
        g_cclosure_marshal_VOID__VOID,
        G_TYPE_NONE,
        0,
        G_TYPE_NONE);
    g_signal_connect(mTestGReceiver, "test-signal", G_CALLBACK(notify), NULL);
}

void
MainWindow::quit()
{
    g_object_unref(mTestGReceiver);
    emit quitSignal();
}

bool
MainWindow::event(QEvent* event)
{
    if (event->type() == QEvent::Close) {
        mMessageJob->close();
    }
    return QMainWindow::event(event);
}

void
MainWindow::handleButton()
{
    g_signal_emit(G_OBJECT(mTestGReceiver), mSignal, 0, 0);
    //g_signal_emit_by_name(G_OBJECT(mTestGReceiver), "test-signal", 0, 0);
    mButton->setText("Example");
}
