#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QPushButton>
#include "messagejob.h"

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
};

#endif
