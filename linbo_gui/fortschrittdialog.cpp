#include <unistd.h>
#include <QDesktopWidget>
#include <qdialog.h>
#include <qprocess.h>
#include <qbytearray.h>

#include "linboLogConsole.h"
#include "folgeaktion.h"
#include "fortschrittdialog.h"
#include "ui_fortschrittdialog.h"

FortschrittDialog::FortschrittDialog(  QWidget* parent, QStringList* command, linboLogConsole* new_log,
                                       const QString& aktion, FolgeAktion folgeAktion,
                                       bool newDetails):
    QDialog(parent), process(new QProcess(this)), logConsole(new_log), logDetails(), timerId(0),
    ui(new Ui::FortschrittDialog)
{
    ui->setupUi(this);
    logDetails = new linboLogConsole();
    logDetails->setLinboLogConsole(logConsole == NULL ? linboLogConsole::COLORSTDOUT
                                                        : logConsole->get_colorstdout(),
                                     logConsole == NULL ? linboLogConsole::COLORSTDERR
                                                        : logConsole->get_colorstderr(),
                                     ui->log);
    ui->aktion->setText(aktion == NULL ? QString("unbekannt") : aktion );
    if(folgeAktion == FolgeAktion::None) {
        ui->folgeAktion->setDisabled(true);
    } else {
        ui->folgeAktion->setText(folgeAktionQString[folgeAktion]);
    }
    ui->details->setChecked(newDetails);
    connect( process, SIGNAL(finished(int,QProcess::ExitStatus)),
             this, SLOT(processFinished(int,QProcess::ExitStatus)));
    process->start(command->join(" "));
    ui->progressBar->setMinimum( 0 );
    ui->progressBar->setMaximum( 100 );
    ui->progressBar->setValue(0);
    timerId = startTimer( 1000 );
}

FortschrittDialog::~FortschrittDialog()
{
    delete ui;
}

void FortschrittDialog::killLinboCmd() {

    process->terminate();
    ui->aktion->setText("Die Ausführung wird abgebrochen...");
    ui->buttonBox->button(QDialogButtonBox::Cancel)->setEnabled( false );
    QTimer::singleShot( 10000, this, SLOT( close() ) );

}

void FortschrittDialog::timerEvent(QTimerEvent *event) {
    if(event->timerId() == timerId){
        ui->processTime->setTime(ui->processTime->time().addSecs(1));
    }
#ifdef TESTCOMMAND
    ui->progressBar->setValue((ui->progressBar->value() + 10) % 100);
#endif
}

void FortschrittDialog::processReadyReadStandardOutput()
{
    QByteArray data = process->readAllStandardOutput();
    logDetails->writeStdOut(data);
    if(logConsole != NULL)
        logConsole->writeStdOut(data);
}

void FortschrittDialog::processReadyReadStandardError()
{
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
    this->close();
}

void FortschrittDialog::setProgress(int i)
{
    ui->progressBar->setValue(i);
}

void FortschrittDialog::setShowCancelButton(bool show)
{
    if( show ){
        ui->buttonBox->button(QDialogButtonBox::Cancel)->show();
    }
    else {
        ui->buttonBox->button(QDialogButtonBox::Cancel)->hide();
    }
}

void FortschrittDialog::on_buttonBox_clicked(QAbstractButton *button)
{
    killLinboCmd();
}
