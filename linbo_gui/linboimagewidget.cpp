#include "linboimagewidget.h"
#include "ui_linboimagewidget.h"

LinboImageWidget::LinboImageWidget(QWidget *parent) :
    QWidget(parent), ui(new Ui::LinboImageWidget)
{
    ui->setupUi(this);

    connect(ui->lName,SIGNAL(textChanged(const QString&)),this,SIGNAL(osnameChanged(const QString&)));
    connect(ui->tbCreate,SIGNAL(clicked()),this,SIGNAL(doCreate()));
    connect(ui->tbUpload,SIGNAL(clicked()),this,SIGNAL(doUpload()));

    setFocusProxy( ui->tbCreate );
}

QString LinboImageWidget::osname() const
{
    return ui->lName->text();
}

void LinboImageWidget::setOsname(const QString &new_osname)
{
    ui->lName->setText(new_osname);
}
