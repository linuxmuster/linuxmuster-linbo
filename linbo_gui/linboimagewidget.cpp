#include "linboimagewidget.h"
#include "ui_linboimagewidget.h"

LinboImageWidget::LinboImageWidget(QWidget *parent, int newnr, os_item* newItem) :
    QWidget(parent), nr(newnr), item(newItem), ui(new Ui::LinboImageWidget)
{
    ui->setupUi(this);
    if( item != NULL ){
        ui->lName->setText(item->get_name());
    } else {
        ui->lName->setText("unnamed");
    }
}

LinboImageWidget::~LinboImageWidget()
{
    delete ui;
}

void LinboImageWidget::on_tbCreate_clicked()
{
    emit(doCreate(nr));
}

void LinboImageWidget::on_tbUpload_clicked()
{
    emit(doUpload(nr));
}
