#include <qdialog.h>
#include <qwidget.h>

#include "linboConsole.h"
#include "ui_linboConsole.h"

linboConsole::linboConsole(  QWidget* parent, linboLogConsole* newLog ) : QDialog( parent ),
    logConsole(newLog), ui(new Ui::linboConsole)
{
  ui->setupUi(this);

}

linboConsole::~linboConsole()
{
} 

void linboConsole::on_pushButton_clicked()
{
    close();
}
