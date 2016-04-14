#ifndef FORTSCHRITTDIALOG_H
#define FORTSCHRITTDIALOG_H

#include <QDialog>
#include <qobject.h>
#include <QProcess>
#include <QTextEdit>
#include <QTime>

#include "linboLogConsole.h"
#include "aktion.h"

namespace Ui {
class FortschrittDialog;
}

class linboLogConsole;

class FortschrittDialog : public QDialog
{
    Q_OBJECT
private:
    bool* details;
    QProcess *process;
    bool connected;
    linboLogConsole *logConsole, *logDetails;
    int timerId;

public:
    explicit FortschrittDialog(QWidget *parent = 0, QStringList* command = 0, linboLogConsole *new_log = 0,
                               const QString& titel  = NULL, Aktion aktion = Aktion::None,
                               bool* newDetails = NULL);
    ~FortschrittDialog();

    void setProgress(int i);
    void setShowCancelButton(bool show);
    void setProcess(QProcess *new_process);
    void keyPressEvent(QKeyEvent *);
//    void closeEvent(QCloseEvent *);

public slots:
    void killLinboCmd();

private slots:
    void processReadyReadStandardError();
    void processReadyReadStandardOutput();
    void processFinished( int exitCode, QProcess::ExitStatus exitStatus );

    void on_buttonBox_clicked(QAbstractButton *button);

    void on_details_toggled(bool checked);

protected:
    void timerEvent(QTimerEvent *event);

private:
    Ui::FortschrittDialog *ui;
};

#endif // FORTSCHRITTDIALOG_H
