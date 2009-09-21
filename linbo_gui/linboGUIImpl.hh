#ifndef LINBOGUIIMPL_HH
#define LINBOGUIIMPL_HH

#include "ui_linboGUI.h"
#include "image_description.hh"
#include <qstring.h>
#include <q3process.h>
#include <q3textbrowser.h>
#include <qdatetime.h>
#include <qtimer.h>
#include <vector>
#include <fstream>
#include <istream>
#include "linboPushButton.hh"
#include "linboMsgImpl.hh"
#include "linboPasswordBoxImpl.hh"
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

private:
  linboMsgImpl *waiting;
  QString linestdout, linestderr;
  QString logfilepath;
  bool root, withicons, outputvisible;
  Q3Process* myprocess;
  QDialog* myQPasswordBox;
  linboPasswordBoxImpl* myLPasswordBox;
  linbopushbutton *autostart, *autopartition, *autoinitcache;
  int preTab;
  QTimer *myTimer;
  
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
