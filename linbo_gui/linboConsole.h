#ifndef LINBOCONSOLE_H
#define LINBOCONSOLE_H

#include <qobject.h>
#include <qdialog.h>

#include "linboLogConsole.h"

namespace Ui {
    class linboConsole;
}

class linboConsole : public QDialog
{
  Q_OBJECT
  
private:
  linboLogConsole* logConsole;

public:
  linboConsole( QWidget* parent = 0, linboLogConsole* logConsole = 0 );

  ~linboConsole();


public slots:

private slots:
  void on_pushButton_clicked();

private:
  Ui::linboConsole *ui;

};
#endif
