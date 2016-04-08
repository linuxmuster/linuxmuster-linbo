#ifndef FORTSCHRITTDIALOG_H
#define FORTSCHRITTDIALOG_H

#include <QDialog>
#include <qobject.h>
#include <QProcess>
#include <QTextEdit>
#include <QTime>

#include "linboLogConsole.h"

namespace Ui {
class FortschrittDialog;
}

class linboLogConsole;

class FortschrittDialog : public QDialog
{
    Q_OBJECT
private:
    QProcess *process;
    bool connected;
    linboLogConsole *logConsole;
    int timerId;
    QTextEdit* Console;
    QTime time;

public:
    explicit FortschrittDialog(QWidget *parent = 0, QStringList* command = 0, linboLogConsole *new_log = 0 );
    ~FortschrittDialog();

    void setProgress(int i);
    void setShowCancelButton(bool show);
    void setProcess(QProcess *new_process);

public slots:
    void killLinboCmd();

private slots:
    void processFinished( int exitCode, QProcess::ExitStatus exitStatus );

protected:
    void timerEvent(QTimerEvent *event);

private:
    Ui::FortschrittDialog *ui;
};

#endif // FORTSCHRITTDIALOG_H
