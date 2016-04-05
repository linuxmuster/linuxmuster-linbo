#ifndef LOGIN_H
#define LOGIN_H

#include <qdialog.h>
#include <qobject.h>

namespace Ui {
    class Login;
}

class Login : public QDialog
{
  Q_OBJECT

private:

public:
  Login( QWidget* parent = 0 );

   ~Login();

signals:
  void acceptLogin(QString passwd);

public slots:

private slots:
  void on_password_returnPressed();

  void on_toolButton_clicked();

private:
    Ui::Login *ui;

};
#endif
