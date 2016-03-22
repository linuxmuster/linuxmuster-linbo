#include "linbooswidget.h"
#include "ui_linbooswidget.h"

LinboOSWidget::LinboOSWidget(QWidget *parent) :
    QWidget(parent), ui(new Ui::LinboOSWidget)
{
    ui->setupUi(this);

    connect(ui->lName,SIGNAL(textChanged(const QString&)),this,SIGNAL(osnameChanged(const QString&)));
    connect(ui->tbDefault,SIGNAL(clicked()),this,SIGNAL(doDefault()));
    connect(ui->tbStart,SIGNAL(clicked()),this,SIGNAL(doStart()));
    connect(ui->tbSync,SIGNAL(clicked()),this,SIGNAL(doSync()));
    connect(ui->tbNew,SIGNAL(clicked()),this,SIGNAL(doNew()));
    connect(ui->tbInfo,SIGNAL(clicked()),this,SIGNAL(doInfo()));

    setFocusProxy( ui->tbDefault );
}

QString LinboOSWidget::osname() const
{
    return ui->lName->text();
}

void LinboOSWidget::setOsname(const QString &new_osname)
{
    ui->lName->setText(new_osname);
}
