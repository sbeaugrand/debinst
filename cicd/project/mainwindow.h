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
private slots:
    void handleButton();
    void quit();
signals:
    void quitSignal();
private:
    bool event(QEvent* event) override;
    QPushButton* m_button;
    MessageJob* mMessageJob;
};
#endif  // MAINWINDOW_H
