#ifndef LINBOPROGRESS_H
#define LINBOPROGRESS_H

#include <qobject.h>
#include <qdialog.h>
#include <QProcess>
#include <QTextEdit>

#include "linboLogConsole.h"

namespace Ui {
class linboProgress;
}

class linboLogConsole;

class linboProgress : public QDialog
{
    Q_OBJECT

private:
    QProcess *process;
    linboLogConsole *logConsole;
    int timerId;
    QTextEdit* Console;
    int time, minutes,seconds;
    QString minutestr,secondstr;

public:
    linboProgress( QWidget* parent = 0, QProcess *new_process = 0, linboLogConsole *new_log = 0 );

    ~linboProgress();

    void setProgress(int i);
    void setShowCancelButton(bool show);
    void setProcess(QProcess *new_process);

public slots:
    void killLinboCmd();
    void processFinished( int retval,
                          QProcess::ExitStatus status);
protected:
    void timerEvent(QTimerEvent *event);

private:
    Ui::linboProgress *ui;

};
#endif
