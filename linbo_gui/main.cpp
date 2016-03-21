#include "linbogui.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    LinboGUI w;
    w.show();

    return a.exec();
}
