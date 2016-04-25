#include <unistd.h>
#include <QDesktopWidget>
#include <qdialog.h>
#include <qprocess.h>
#include <qbytearray.h>
#include <qevent.h>

#include "linboLogConsole.h"
#include "aktion.h"
#include "fortschrittdialog.h"
#include "ui_fortschrittdialog.h"

FortschrittDialog::FortschrittDialog(QWidget* parent, QStringList* command, linboLogConsole* new_log,
                                     const QString& titel, Aktion aktion, bool* newDetails,
                                     int (*new_maximum)(const QByteArray& output),
                                     int (*new_value)(const QByteArray& output)):
    QDialog(parent), details(newDetails), process(new QProcess(this)), logConsole(new_log), logDetails(),
    timerId(0), maximum(new_maximum), value(new_value),
    ui(new Ui::FortschrittDialog)
{
    ui->setupUi(this);
    if(details == NULL){
        details = new bool(false);
    }
    ui->details->setChecked(*details);
    logDetails = new linboLogConsole();
    logDetails->setLinboLogConsole(logConsole == NULL ? linboLogConsole::COLORSTDOUT
                                                        : logConsole->get_colorstdout(),
                                     logConsole == NULL ? linboLogConsole::COLORSTDERR
                                                        : logConsole->get_colorstderr(),
                                     ui->log, NULL);
    ui->aktion->setText(titel == NULL ? QString("unbekannt") : titel );
    if(aktion == Aktion::None) {
        ui->folgeAktion->hide();
    } else {
        ui->folgeAktion->setText(aktion.toQString());
    }
    connect( process, &QProcess::readyReadStandardOutput,
             this, &FortschrittDialog::processReadyReadStandardOutput);
    connect( process, &QProcess::readyReadStandardError,
             this, &FortschrittDialog::processReadyReadStandardError);
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
        if( maximum == NULL || value == NULL ){
            ui->progressBar->setValue(5*ui->processTime->time().elapsed() % ui->progressBar->maximum());
        }
    }
}

void FortschrittDialog::processReadyReadStandardOutput()
{
    QByteArray data = process->readAllStandardOutput();
    if( maximum != NULL && value != NULL ){
        ui->progressBar->setMaximum(maximum(data));
        ui->progressBar->setValue(value(data));
    }
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

void FortschrittDialog::keyPressEvent(QKeyEvent *event)
{
    if(event->key() == Qt::Key_Escape){
        // ignorieren
    }
}

//void FortschrittDialog::closeEvent(QCloseEvent *event)
//{
//    event->ignore();
//}

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
    if( QDialogButtonBox::Cancel == ui->buttonBox->standardButton(button))
        killLinboCmd();
}

void FortschrittDialog::on_details_toggled(bool checked)
{
    *details = checked;
}
