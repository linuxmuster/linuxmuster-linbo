#include "login.h"
#include "ui_login.h"

Login::Login(  QWidget* parent ) : QDialog(parent), ui(new Ui::Login)
{
  ui->setupUi(this);
}

Login::~Login()
{
} 

void Login::on_password_returnPressed()
{
    emit(acceptLogin(ui->password->text()));
    close();
}
