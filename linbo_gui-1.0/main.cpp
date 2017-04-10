#include <QApplication>

#include "myqtapp.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    myQtApp *dialog = new myQtApp;

    dialog->show();
    return app.exec();
}

