#include <unistd.h>
#include <QDesktopWidget>
#include <qdialog.h>
#include <qprocess.h>

#include "linboLogConsole.h"

#include "linboProgress.h"
#include "ui_linboProgress.h"

linboProgress::linboProgress(  QWidget* parent, QStringList* command, linboLogConsole* new_log ):
    QDialog(parent), process(new QProcess(this)), logConsole(new_log), timerId(0), time(0),
    ui(new Ui::linboProgress)
{
    ui->setupUi(this);
    connect( ui->cancelButton,SIGNAL(clicked()),this,SLOT(killLinboCmd()) );

    connect( process, SIGNAL(finished(int,QProcess::ExitStatus)),
             this, SLOT(processFinished(int,QProcess::ExitStatus)));

    process->start(command->join(" "));

    ui->progressBar->setMinimum( 0 );
    ui->progressBar->setMaximum( 100 );
    time = 0;
    ui->processTime->setText("00:00");
    timerId = startTimer( 1000 );
}

linboProgress::~linboProgress() {
    // nothing to do
}



void linboProgress::killLinboCmd() {

    process->terminate();
    ui->progressLabel->setText("Die Ausführung wird abgebrochen...");
    ui->cancelButton->setEnabled( false );
    QTimer::singleShot( 10000, this, SLOT( close() ) );

}

void linboProgress::timerEvent(QTimerEvent *event) {
    if( event->timerId() == timerId ){
        time++;

        minutes = (int)(time / 60);
        seconds = (int)(time % 60);

        if( minutes < 10 )
            minutestr = QString("0") + QString::number( minutes );
        else
            minutestr = QString::number( minutes );

        if( seconds < 10 )
            secondstr = QString("0") + QString::number( seconds );
        else
            secondstr = QString::number( seconds );


        ui->processTime->setText( minutestr + QString(":") + secondstr );
    }
}

void linboProgress::processFinished( int exitCode, QProcess::ExitStatus exitStatus ) {
    if( timerId != 0) {
        this->killTimer( timerId );
        timerId = 0;
    }
    logConsole->writeStdOut(process->program() + " " + process->arguments().join(" ")
                            + " was finished");
    logConsole->writeResult(exitCode, exitStatus, exitCode);

    this->close();
}

void linboProgress::setProgress(int i)
{
    ui->progressBar->setValue(i);
}

void linboProgress::setShowCancelButton(bool show)
{
    if( show ){
        ui->cancelButton->show();
    }
    else {
        ui->cancelButton->hide();
    }
}
