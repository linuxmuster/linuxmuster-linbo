#ifndef FORTSCHRITTDIALOG_H
#define FORTSCHRITTDIALOG_H

#include <QDialog>
#include <qobject.h>
#include <QProcess>
#include <QTextEdit>
#include <QTime>

#include "linboLogConsole.h"
#include "folgeaktion.h"

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
    linboLogConsole *logConsole, *logDetails;
    int timerId;

public:
    explicit FortschrittDialog(QWidget *parent = 0, QStringList* command = 0, linboLogConsole *new_log = 0,
                               const QString& aktion  = NULL, FolgeAktion folgeAktion = FolgeAktion::None,
                               bool newDetails = false);
    ~FortschrittDialog();

    void setProgress(int i);
    void setShowCancelButton(bool show);
    void setProcess(QProcess *new_process);

public slots:
    void killLinboCmd();

private slots:
    void processReadyReadStandardError();
    void processReadyReadStandardOutput();
    void processFinished( int exitCode, QProcess::ExitStatus exitStatus );

    void on_buttonBox_clicked(QAbstractButton *button);

protected:
    void timerEvent(QTimerEvent *event);

private:
    Ui::FortschrittDialog *ui;
};

#endif // FORTSCHRITTDIALOG_H
