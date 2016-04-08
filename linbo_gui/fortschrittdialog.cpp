#include <unistd.h>
#include <QDesktopWidget>
#include <qdialog.h>
#include <qprocess.h>

#include "linboLogConsole.h"

#include "fortschrittdialog.h"
#include "ui_fortschrittdialog.h"

FortschrittDialog::FortschrittDialog(  QWidget* parent, QStringList* command, linboLogConsole* new_log ):
    QDialog(parent), process(new QProcess(this)), logConsole(new_log), timerId(0), time(),
    ui(new Ui::FortschrittDialog)
{
    ui->setupUi(this);
    connect( ui->buttonBox,SIGNAL(clicked()),this,SLOT(killLinboCmd()) );

    connect( process, SIGNAL(finished(int,QProcess::ExitStatus)),
             this, SLOT(processFinished(int,QProcess::ExitStatus)));

    process->start(command->join(" "));
    time.start();
    ui->progressBar->setMinimum( 0 );
    ui->progressBar->setMaximum( 100 );
    ui->processTime->setTime(time);
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
    ui->processTime->setTime(time);
}

void FortschrittDialog::processFinished( int exitCode, QProcess::ExitStatus exitStatus ) {
    if( timerId != 0) {
        this->killTimer( timerId );
        timerId = 0;
    }
    logConsole->writeStdOut(process->program() + " " + process->arguments().join(" ")
                            + " was finished");
    logConsole->writeResult(exitCode, exitStatus, exitCode);

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
