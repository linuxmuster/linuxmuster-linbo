#include <sys/types.h>
#include <signal.h>
#include <stdlib.h>
#include <QtGui>
#include <QDesktopWidget>
#include <QRect>
#include <qapplication.h>

#include "linboProgress.h"
#include "ui_linboProgress.h"

linboProgress::linboProgress(  QWidget* parent, QProcess* new_process, linboLogConsole* new_log ):
    QDialog(parent), process(new_process), logConsole(new_log), timerId(0),
    ui(new Ui::linboProgress)
{
    ui->setupUi(this);
    connect( ui->cancelButton,SIGNAL(clicked()),this,SLOT(killLinboCmd()) );
    if( process != 0 ){
        connect( process, SIGNAL(finished(int, QProcess::ExitStatus)),
                 this, SLOT(processFinished(int,QProcess::ExitStatus)));
    }
    Qt::WindowFlags flags;
    flags = Qt::Dialog | Qt::WindowStaysOnTopHint | Qt::WindowTitleHint;
    setWindowFlags( flags );

    QRect qRect(QApplication::desktop()->screenGeometry());
    int xpos=qRect.width()/2-this->width()/2;
    int ypos=qRect.height()/2-this->height()/2;
    this->move(xpos,ypos);
    this->setFixedSize( this->width(), this->height() );
    ui->progressBar->setMinimum( 0 );
    ui->progressBar->setMaximum( 100 );
    timerId = startTimer( 1000 );
}

linboProgress::~linboProgress() {
    // nothing to do
}



void linboProgress::setProcess( QProcess* newProcess ) {
    if( process ){
        disconnect(this, SLOT(finished(int,QProcess::ExitStatus)));
    }
    process = newProcess;
    if( process != 0 ){
        if( process->state() == QProcess::Running ){
            connect( process, SIGNAL(finished(int, QProcess::ExitStatus)),
                     this, SLOT(processFinished(int,QProcess::ExitStatus)));
        }
    }
}

void linboProgress::killLinboCmd() {

    process->terminate();

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
    if( process != 0 && process->state() == QProcess::NotRunning){
        processFinished(process->exitCode(),process->exitStatus());
    }
}

void linboProgress::processFinished( int retval, QProcess::ExitStatus status) {
    if( timerId != 0) {
        this->killTimer( timerId );
        timerId = 0;
    }
    logConsole->writeStdOut(process->program() + " " + process->arguments().join(" ")
                            + " was finished");
    logConsole->writeResult(retval, status, retval);

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
