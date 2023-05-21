#include <QApplication>
#include "mainwindow.h"

int main(int argc, char** argv)
{
    QApplication app(argc, argv);
    MainWindow mainWindow;
    mainWindow.resize(400, 250);
    mainWindow.show();
    QObject::connect(&mainWindow,
                     &MainWindow::quitSignal,
                     &app,
                     &QApplication::closeAllWindows);
    return app.exec();
}
