#pragma once
#include <QMainWindow>
#include <QPushButton>
#include "messagejob.h"

#include <glib-object.h>
typedef struct _TestGReceiver TestGReceiver;
struct _TestGReceiver {
    GObjectClass parent_class;
    void (*testSlot) (_TestGReceiver* /*receiver*/);
};
typedef struct _TestGReceiverClass TestGReceiverClass;
struct _TestGReceiverClass {
    GObjectClass parent_class;
};

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT
public:
    explicit MainWindow(QWidget* parent = nullptr);
signals:
    void quitSignal();
private:
    void quit();
    bool event(QEvent* event) override;
    void handleButton();

    QPushButton* mButton;
    mq::MessageJob* mMessageJob;

    void (*testSignal) (TestGReceiver* receiver);
    guint mSignal;
    TestGReceiver* mTestGReceiver;
};
