#ifndef LINBOGUI_H
#define LINBOGUI_H

#include <QMainWindow>
#include <qstring.h>
#include <QProcess>
#include <QTimer>
#include <QTextEdit>
#include <QPushButton>
#include <qdatetime.h>
#include <qtimer.h>

#include <vector>
#include <fstream>
#include <istream>

#include "configuration.h"
#include "command.h"
#include "image_description.h"
#include "linboLogConsole.h"
#include "fortschrittdialog.h"
#include "aktion.h"
#include "downloadtype.h"

#define ADMINTAB ui->systeme->count()-2
#define LOGTAB ui->systeme->count()-1

namespace Ui {
class LinboGUI;
}

class linboLogConsole;
class FortschrittDialog;

class LinboGUI : public QMainWindow
{
    Q_OBJECT
private:
    Configuration* conf;
    Command* command;
    QString logfilepath;
    bool details, root, withicons, outputvisible;
    QProcess* process;
    FortschrittDialog* progress;
    int preTab, roottimeout, logoutTimer;
    linboLogConsole* logConsole;

    void showInfos();
    void showOSs();
    void showImages();

public:
    globals config();

    bool isRoot() const;
    void showImagingTab();

    explicit LinboGUI(QWidget *parent = 0);
    ~LinboGUI();

    void readFromStdout();
    void readFromStderr();
    void resetButtons();
    bool isAdminTab(int tabIndex);
    bool isLogTab(int tabIndex);

public slots:
    void do_register(QString& roomName, QString& clientName, QString& ipAddress, QString& clientGroup);
    void doInitCache(bool formatCache, DownloadType type);
    void performLogin(QString passwd);
    void performLogout();
    void doWrapperCommands();
    void doAutostartDialog();
    void doAutostart();
    void doStart(int nr);
    void doSync(int nr);
    void doNew(int nr);
    void doCreateDialog(int nr);
    void doCreate(int nr, const QString& imageName, const QString& description, bool isnew, bool upload, Aktion aktion);
    void doUploadDialog(int nr);
    void doUpload(const QString& imageName, Aktion aktion);
    void doInfoDialog(int nr);
    void doInfo(const QString& filename, const QString& desription);

private slots:


    void on_halt_clicked();

    void on_reboot_clicked();

    void on_update_clicked();

    void on_systeme_currentChanged(int index);

    void on_doregister_clicked();

    void on_logout_clicked();

    void on_cbTimeout_toggled(bool checked);

    void on_console_clicked();

    void on_initcache_clicked();

    void on_partition_clicked();

protected:
    void timerEvent(QTimerEvent *event);

private:
    void doCreate();
    void doUpload();
    void doCommand(const QStringList& command, bool interruptible = false, const QString& titel = QString(""),
                   Aktion aktion = Aktion::None, bool* details = NULL);
    Ui::LinboGUI *ui;
};

#endif // LINBOGUI_H
