#include "fortschrittdialog.h"
#include "ui_fortschrittdialog.h"

FortschrittDialog::FortschrittDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::FortschrittDialog)
{
    ui->setupUi(this);
}

FortschrittDialog::~FortschrittDialog()
{
    delete ui;
}
