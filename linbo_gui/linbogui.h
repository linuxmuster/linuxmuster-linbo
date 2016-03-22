#ifndef LINBOGUI_H
#define LINBOGUI_H

#include <QWidget>
#include <qstring.h>
#include <QProcess>
#include <QTimer>
#include <QTextEdit>
#include <qdatetime.h>
#include <qtimer.h>

#include <vector>
#include <fstream>
#include <istream>

#include "configuration.h"
#include "command.h"
#include "image_description.h"
#include "linboPushButton.h"
#include "linboMsg.h"
#include "linboCounter.h"
#include "linboPasswordBox.h"
#include "linboLogConsole.h"

#define ADMINTAB ui->systeme->count()-2
#define LOGTAB ui->systeme->count()-1

namespace Ui {
class LinboGUI;
}

class linbopushbutton;
class linboPasswordBox;

class LinboGUI : public QWidget
{
    Q_OBJECT
private:
    Configuration* conf;
    Command* command;

    linboCounter* myCounter;
    QTimer* myTimer;
    QTimer* myAutostartTimer;
    linboMsg *waiting;
    QString linestdout, linestderr;
    QString logfilepath, fonttemplate;
    bool root, withicons, outputvisible;
    QProcess* process;
    QWidget* myQPasswordBox;
    linboPasswordBox* myLPasswordBox;
    linbopushbutton *autostart, *autopartition, *autoinitcache;
    int preTab, autostarttimeout;
    linboLogConsole* logConsole;

    vector<int> buttons_config;
    vector<bool> buttons_config_save;

    void showInfos();
    void showOSs();
    void showImages();

public:
    globals config();
    vector<linbopushbutton*> p_buttons;
    // 0 = disabled
    // 1 = enabled
    // 2 = admin button

    bool isRoot() const;
    void showImagingTab();
    void log( const QString& data );

    explicit LinboGUI(QWidget *parent = 0);
    ~LinboGUI();

    void readFromStdout();
    void readFromStderr();
    void disableButtons();
    void resetButtons();
    bool isAdminTab(int tabIndex);
    bool isLogTab(int tabIndex);

public slots:
    void do_register(int result);
    void restoreButtonsState();
    void enableButtons();

private slots:


    void on_halt_clicked();

    void on_reboot_clicked();

    void on_update_clicked();

    void on_systeme_currentChanged(int index);

    void on_doregister_clicked();

private:
    Ui::LinboGUI *ui;
};

#endif // LINBOGUI_H
