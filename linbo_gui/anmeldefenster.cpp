#include "anmeldefenster.h"
#include "ui_anmeldefenster.h"

Anmeldefenster::Anmeldefenster(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::Anmeldefenster)
{
    ui->setupUi(this);
}

Anmeldefenster::~Anmeldefenster()
{
    delete ui;
}
