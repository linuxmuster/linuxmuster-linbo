#ifndef ANMELDEFENSTER_H
#define ANMELDEFENSTER_H

#include <QDialog>

namespace Ui {
class Anmeldefenster;
}

class Anmeldefenster : public QDialog
{
    Q_OBJECT

public:
    explicit Anmeldefenster(QWidget *parent = 0);
    ~Anmeldefenster();

private:
    Ui::Anmeldefenster *ui;
};

#endif // ANMELDEFENSTER_H
