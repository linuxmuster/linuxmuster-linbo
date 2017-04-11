#include "autostart.h"
#include "ui_autostart.h"

Autostart::Autostart(QWidget *parent, int autoTimeout, const QString& new_title) :
    QDialog(parent), timerId(0),
    ui(new Ui::Autostart)
{
    ui->setupUi(this);
    ui->dialogTitle->setText(new_title);
    ui->timeout->display(autoTimeout);
    timerId = this->startTimer(1000);
}

Autostart::~Autostart()
{
    delete ui;
}

void Autostart::timerEvent(QTimerEvent *event)
{
    if(event->timerId() == timerId){
        int timeLeft = ui->timeout->intValue();
        timeLeft--;
        ui->timeout->display(timeLeft);
        if(timeLeft <= 0){
            this->killTimer(timerId);
            accept();
        }
    }
}

void Autostart::on_abort_clicked()
{
    if(timerId != 0)
        this->killTimer(timerId);
    reject();
}
