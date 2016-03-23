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
    QWidget(parent), process(new_process), logConsole(new_log), timerId(0),
    ui(new Ui::linboProgress)
{
    ui->setupUi(this);
    connect( ui->cancelButton,SIGNAL(clicked()),this,SLOT(killLinboCmd()) );

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
}

linboProgress::~linboProgress() {
    // nothing to do
}



void linboProgress::setProcess( QProcess* newProcess ) {
    if( newProcess != 0 ) {
        process = newProcess;
    }
}

void linboProgress::killLinboCmd() {

    process->terminate();

    QTimer::singleShot( 10000, this, SLOT( close() ) );
}

void linboProgress::startTimer() {
    if( timerId != 0) {
        this->killTimer(timerId);
    }
    timerId = QObject::startTimer( 1000 );
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

void linboProgress::processFinished( int retval,
                                     QProcess::ExitStatus status) {
    if( timerId != 0) {
        this->killTimer( timerId );
        timerId = 0;
    }
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
