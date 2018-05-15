#include <qdebug.h>
#include <unistd.h>
#include <QDesktopWidget>
#include <qdialog.h>
#include <qprocess.h>
#include <qbytearray.h>
#include <qevent.h>
#include <qobject.h>

#include "linboLogConsole.h"
#include "aktion.h"
#include "linboremote.h"
#include "filtertime.h"
#include "fortschrittdialog.h"
#include "ui_fortschrittdialog.h"

/**
 * @brief FortschrittDialog::FortschrittDialog
 * @param parent
 * @param new_active true: execute command in own process, false: show dialog and wait for process to finish
 * @param command
 * @param new_log
 * @param titel
 * @param aktion
 * @param newDetails
 * @param new_filter
 */
FortschrittDialog::FortschrittDialog(QWidget* parent, bool new_active, QStringList* command, linboLogConsole* new_log,
                                     const QString& new_title, Aktion aktion, bool* newDetails,
                                     Filter *new_filter):
    QDialog(parent), active(new_active), title(new_title), ldetails(false),
    details(newDetails), process((new_active?new QProcess(this):NULL)),
    logConsole(new_log), timerId(0), filter(new_filter),
    ui(new Ui::FortschrittDialog)
{
    ui->setupUi(this);
    if(details == NULL){
        details = &ldetails;
    }
    ui->details->setChecked(*details);
    logDetails = new linboLogConsole();
    logDetails->setLinboLogConsole(logConsole == NULL ? linboLogConsole::COLORSTDOUT
                                                      : logConsole->get_colorstdout(),
                                   logConsole == NULL ? linboLogConsole::COLORSTDERR
                                                      : logConsole->get_colorstderr(),
                                   ui->log, NULL);
    ui->aktion->setText(title == NULL ? QString("unbekannt") : title );
    if(aktion == Aktion::None) {
        ui->folgeAktion->hide();
    } else {
        ui->folgeAktion->setText(aktion.toQString());
    }
    QStringList args = *command;
    if(active){
        connect( process, &QProcess::readyReadStandardOutput,
                 this, &FortschrittDialog::processReadyReadStandardOutput);
        connect( process, &QProcess::readyReadStandardError,
                 this, &FortschrittDialog::processReadyReadStandardError);
        connect( process, SIGNAL(finished(int,QProcess::ExitStatus)),
                 this, SLOT(processFinished(int,QProcess::ExitStatus)));

        //args need to be passed separate because of empty args
        cmd = command->at(0);
        args.removeFirst();
        const QStringList cargs = args;
    }
    if(filter == 0){
        filter = new FilterTime(this, ui->processTime);
    }
    connect(filter,&Filter::valueChanged,ui->progressBar,&QProgressBar::setValue);
    connect(filter,&Filter::maximumChanged,ui->progressBar,&QProgressBar::setMaximum);
    connect(filter,&Filter::titleChanged,this,&FortschrittDialog::appendTitle);
    ui->progressBar->setValue(0);
    ui->progressBar->setMaximum(100);
    timerId = startTimer( 1000 );
    if(active){
        process->start(cmd, args, QIODevice::ReadWrite );
    }
}

FortschrittDialog::~FortschrittDialog()
{
    delete logDetails;
    delete ui;
}

void FortschrittDialog::appendTitle(const QString& new_title)
{
    if(new_title != NULL && new_title.compare(QString("")) != 0)
        ui->aktion->setText(title + QString(": ") + new_title);
    else
        ui->aktion->setText(title);
}

void FortschrittDialog::killLinboCmd() {

    if(active){
        process->terminate();
    }
    ui->aktion->setText("Die Ausführung wird abgebrochen...");
    ui->cancelButton->setEnabled( false );
    QTimer::singleShot( 10000, this, SLOT( close() ) );

}

void FortschrittDialog::timerEvent(QTimerEvent *event) {
    if(event->timerId() == timerId){
        ui->processTime->setTime(ui->processTime->time().addSecs(1));
        if(!active && !LinboRemote::is_running()){
            close();
        }
    }
}

void FortschrittDialog::processReadyReadStandardOutput()
{
    if(!active){
        return;
    }
    QByteArray data = process->readAllStandardOutput();
    filter->filter(data);
    logDetails->writeStdOut(data);
    if(logConsole != NULL)
        logConsole->writeStdOut(data);
}

void FortschrittDialog::processReadyReadStandardError()
{
    if(!active){
        return;
    }
    QByteArray data = process->readAllStandardError();
    logDetails->writeStdErr(data);
    if(logConsole != NULL)
        logConsole->writeStdErr(data);
}

void FortschrittDialog::processFinished( int exitCode, QProcess::ExitStatus exitStatus ) {
    if( timerId != 0) {
        this->killTimer( timerId );
        timerId = 0;
    }
    if(logConsole != NULL){
        logConsole->writeStdOut(process->program() + " " + process->arguments().join(" ")
                                + " was finished");
        logConsole->writeResult(exitCode, exitStatus, exitCode);
    }
    if(exitStatus == QProcess::NormalExit){
        this->accept();
    } else {
        this->reject();
    }
    this->close();
}

void FortschrittDialog::keyPressEvent(QKeyEvent *event)
{
    if(event->key() == Qt::Key_Escape){
        // ignorieren
    }
}

void FortschrittDialog::setShowCancelButton(bool show)
{
    if( show && active){
        ui->cancelButton->show();
    }
    else {
        ui->cancelButton->hide();
    }
}

void FortschrittDialog::on_details_toggled(bool checked)
{
    *details = checked;
}

void FortschrittDialog::on_cancelButton_clicked()
{
    if(active){
        killLinboCmd();
    }
}
