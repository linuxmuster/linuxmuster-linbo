/* class building the LINBO GUI

Copyright (C) 2007 Martin Oehler <oehler@knopper.net>
Copyright (C) 2007 Klaus Knopper <knopper@knopper.net>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

*/


#ifndef LINBOGUIIMPL_HH
#define LINBOGUIIMPL_HH

#include "ui_linboGUI.h"
#include "image_description.hh"
#include <qstring.h>
#include <QProcess>
#include <QTimer>
#include <QTextEdit>
#include <qdatetime.h>
#include <qtimer.h>
#include <vector>
#include <fstream>
#include <istream>
#include "linboPushButton.hh"
#include "linboMsgImpl.hh"
#include "linboCounterImpl.hh"
#include "linboPasswordBoxImpl.hh"
#include "linboLogConsole.hh"
// #include "linboProgressImpl.hh"

using namespace std;
class linbopushbutton;
class linboMsgImpl;
class linboPasswordBoxImpl;
// class linboProgressImpl;


class linboGUIImpl : public QDialog, public Ui::linboGUI
{
  Q_OBJECT

public slots:
  void readFromStdout();
  void readFromStderr();
  void enableButtons();
  void resetButtons();
  void disableButtons();
  void restoreButtonsState();
  void tabWatcher( QWidget* );
  void processTimeout();
  void executeAutostart();
  void shutdown();
  void reboot();
  void autostartTimeoutSlot();

private:
  linboCounterImpl* myCounter;
  QTimer* myTimer;
  QTimer* myAutostartTimer;
  linboMsgImpl *waiting;
  QString linestdout, linestderr;
  QString logfilepath, fonttemplate;
  bool root, withicons, outputvisible;
  QProcess* process;
  QDialog* myQPasswordBox;
  linboPasswordBoxImpl* myLPasswordBox;
  linbopushbutton *autostart, *autopartition, *autoinitcache;
  int preTab, autostarttimeout;
  linboLogConsole* logConsole;
  
  vector<int> buttons_config;
  vector<bool> buttons_config_save;
public:
  vector<linbopushbutton*> p_buttons;
  // 0 = disabled
  // 1 = enabled
  // 2 = admin button

  globals config;
  vector<os_item> elements;
  vector<diskpartition> partitions;

  linboGUIImpl();

  ~linboGUIImpl();

  bool isRoot() const;
  void showImagingTab();
  void log( const QString& data );

};

#endif
