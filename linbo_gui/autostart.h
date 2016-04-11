#ifndef AUTOSTART_H
#define AUTOSTART_H

#include <QDialog>

namespace Ui {
class Autostart;
}

class Autostart : public QDialog
{
    Q_OBJECT
private:
    int timerId;

public:
    explicit Autostart(QWidget *parent = 0, int autoTimeout = 10, const QString& new_title = QString("Autostart..."));
    ~Autostart();

private slots:
    void on_abort_clicked();

private:
    void timerEvent(QTimerEvent *);
    Ui::Autostart *ui;
};

#endif // AUTOSTART_H
