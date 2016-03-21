#ifndef FORTSCHRITTDIALOG_H
#define FORTSCHRITTDIALOG_H

#include <QDialog>

namespace Ui {
class FortschrittDialog;
}

class FortschrittDialog : public QDialog
{
    Q_OBJECT

public:
    explicit FortschrittDialog(QWidget *parent = 0);
    ~FortschrittDialog();

private:
    Ui::FortschrittDialog *ui;
};

#endif // FORTSCHRITTDIALOG_H
