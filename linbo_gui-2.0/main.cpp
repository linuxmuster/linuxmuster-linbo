#include "linbogui.h"
#include <QApplication>
#include <qdebug.h>
#include <qfont.h>
#ifdef DEBUG
#include <stdio.h>
#include <stdlib.h>

void myMessageOutput(QtMsgType type, const QMessageLogContext &, const QString & str)
{
    const char * msg = str.toStdString().c_str();
 //in this function, you can write the message to any stream!
 switch (type) {
 case QtInfoMsg:
     fprintf(stderr, "Info: %s\n", msg);
     break;
 case QtDebugMsg:
     fprintf(stderr, "Debug: %s\n", msg);
     break;
 case QtWarningMsg:
     fprintf(stderr, "Warning: %s\n", msg);
     break;
 case QtCriticalMsg:
     fprintf(stderr, "Critical: %s\n", msg);
     break;
 case QtFatalMsg:
     fprintf(stderr, "Fatal: %s\n", msg);
     abort();
 }
}
#endif

int main(int argc, char *argv[])
{
#ifdef DEBUG
    qInstallMessageHandler(myMessageOutput);
#endif
    QApplication a(argc, argv);
    QFont f(QApplication::font());
    qDebug()<< qPrintable(f.family()) << f.pointSize();
    LinboGUI w;
    w.show();

    return a.exec();
}
