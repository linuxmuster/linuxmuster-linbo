#include <vector>

#include <QMessageBox>
#include <qfile.h>
#include <qtextstream.h>
#include <qobject.h>
#include <qtimer.h>

#include "linbooswidget.h"

#include "linbogui.h"
#include "ui_linbogui.h"
#include "registrierungsdialog.h"
#include "configuration.h"
#include "command.h"
#include "linboConsole.h"
#include "fortschrittdialog.h"
#include "registrierungsdialog.h"
#include "linboimagewidget.h"
#include "login.h"
#include "linboImageSelector.h"
#include "linboImageUpload.h"
#include "aktion.h"
#include "downloadtype.h"
#include "image_description.h"
#include "linboInfoBrowser.h"
#include "linboMulticastBox.h"
#include "autostart.h"

LinboGUI::LinboGUI(QWidget *parent): QMainWindow(parent),
    conf(),command(), process(new QProcess(this)),
    logConsole(new linboLogConsole),
    ui(new Ui::LinboGUI)
{
    ui->setupUi(this);
    conf = new Configuration();
    command = new Command(conf);
    
    showMaximized();

    details = false;

    // reset root - we're an user now
    root = false;
    // automatic logout after roottimeout;
    roottimeout = 600;

    // we want to see icons
    withicons = true;

    // show command output on LINBO console
    outputvisible = true;

    // first "last visited" tab is start tab
    preTab = 0;

    // logfilepath
#ifdef TESTCOMMAND
    logfilepath = QString("./linbo.log");
#else
    logfilepath = QString("/tmp/linbo.log");
#endif

    // we can set this now since our globals have been read
    logConsole->setLinboLogConsole( conf->config.get_consolefontcolorstdout(),
                                    conf->config.get_consolefontcolorstderr(),
                                    ui->log, logfilepath);

    showInfos();

    showOSs();

    showImages();

    ui->systeme->setCurrentIndex(0);

    //process autostart
    if(conf->config.get_autostart() != NULL && conf->config.get_autostarttimeout() != 0){
        QTimer::singleShot(500, this, SLOT(doAutostartDialog()));
    }
}

LinboGUI::~LinboGUI()
{
    delete ui;
}

bool LinboGUI::isRoot() const {
    return root;
}

void LinboGUI::showImagingTab() {
    ui->systeme->setCurrentIndex( ADMINTAB );
}

void LinboGUI::readFromStdout()
{
    if( outputvisible ) {
        logConsole->writeStdOut( process->readAllStandardOutput() );
    }
}

void LinboGUI::readFromStderr()
{
    if( outputvisible ) {
        logConsole->writeStdErr( process->readAllStandardError() );
    }
}



bool LinboGUI::isAdminTab(int tabIndex) {
    return (tabIndex == ADMINTAB);
}

bool LinboGUI::isLogTab(int tabIndex) {
    return (tabIndex == LOGTAB);
}

globals LinboGUI::config()
{
    return conf->config;
}

void LinboGUI::showInfos()
{
    ui->rechner->setText(QString("Host: ") + command->doSimpleCommand(QString("hostname")));
    ui->gruppe->setText(QString("Gruppe: ") + conf->config.get_hostgroup());
    ui->ip->setText(QString("IP: ") + command->doSimpleCommand(QString("ip")));
    ui->mac->setText(QString("MAC: ") + command->doSimpleCommand(QString("mac")));
    ui->battery->setText(QString("Batterie: ") + command->doSimpleCommand(QString("battery")));
    ui->cpu->setText(QString("CPU: ") + command->doSimpleCommand(QString("cpu")));
    ui->ram->setText(QString("RAM: ") + command->doSimpleCommand(QString("memory")));
    ui->cache->setText(QString("Cache: ") + command->doSimpleCommand(QString("size"),conf->config.get_cache()));
    ui->hd->setText(QString("HD: ") + command->doSimpleCommand(QString("size"),conf->config.get_hd()));

    ui->version->setText(command->doSimpleCommand(QString("version")) + QString(" auf Server ") + conf->config.get_server());

}

void LinboGUI::on_halt_clicked()
{
    QStringList cmd;
      cmd.clear();
#ifdef TESTCOMMAND
      cmd = QStringList("echo busybox");
#else
      cmd = QStringList("busybox");
#endif
      cmd.append("poweroff");
      logConsole->writeStdOut( QString("shutdown entered") );
      process->start( cmd.join(" ") );
}

void LinboGUI::on_reboot_clicked()
{
    QStringList cmd;
      cmd.clear();
#ifdef TESTCOMMAND
      cmd = QStringList("echo busybox");
#else
      cmd = QStringList("busybox");
#endif
      cmd.append("reboot");
      logConsole->writeStdOut( QString("reboot entered") );
      process->start( cmd.join(" ") );
}

void LinboGUI::on_update_clicked()
{
      logConsole->writeStdOut( QString("update entered") );
#ifdef TESTCOMMAND
      QStringList cmd;
      cmd <<"sleep 10";
#else
      QStringList cmd = command->mklinboupdatecommand();
#endif
      doCommand( cmd, false, QString("update"), Aktion::None, &details );
}

void LinboGUI::on_systeme_currentChanged(int index)
{
    if( !isRoot() ) {
        if( isAdminTab(index)) {
            // if our partition button is disabled, there is a linbo_cmd running
            if( process->state() != QProcess::Running ) {
                ui->systeme->setCurrentIndex( preTab );
                Login *dlg = new Login();
                connect(dlg, SIGNAL(acceptLogin(QString)), this, SLOT(performLogin(QString)));
                dlg->exec();
            }
            else {
                ui->systeme->setCurrentIndex( preTab );
            }
        }
    }
    if( (ui->systeme->currentIndex() != ADMINTAB && ui->systeme->currentIndex() != LOGTAB)  )
        preTab = ui->systeme->currentIndex();
}

void LinboGUI::on_doregister_clicked()
{
    // Die vorgeschlagenen Daten fuer die Rechneraufnahme lesen und anzeigen
    QStringList registerDataList;
    command->doSimpleCommand(command->mkpreregistercommand().join(" "));
#ifdef TESTCOMMAND
    registerDataList << QString("Testraum") << QString("testclient")
                     << QString("192.168.1.1") << QString("pc_group");
#else
    char line[1024];
    ifstream newdata;
    QString registerData;
    newdata.open("/tmp/newregister", ios::in);
    if (newdata.is_open()) {
        newdata.getline(line,1024,'\n');
        registerData = QString::fromUtf8( line, -1 ).trimmed();
        newdata.close();
        registerDataList = registerData.split(',');
    }
#endif
    RegistrierungsDialog *regdlg;
    if( registerDataList.size() >= 4 ){
        regdlg = new RegistrierungsDialog( this, registerDataList[0], registerDataList[1],
                registerDataList[2], registerDataList[3]);
    }
    else {
        regdlg = new RegistrierungsDialog( this );
    }
    connect(regdlg,SIGNAL(finished(QString&, QString&, QString&, QString&)),
            this,SLOT(do_register(QString&, QString&, QString&, QString&)));
    regdlg->exec();
}

void LinboGUI::do_register(QString& roomName, QString& clientName, QString& ipAddress, QString& clientGroup)
{
    doCommand(command->mkregistercommand(roomName, clientName, ipAddress, clientGroup), true, QString("Registrieren..."), Aktion::None, &details);
}

void LinboGUI::showOSs()
{
    const int MAXOSCOLUMN = 1;
    int row = 0;
    int col = 0;
    for(std::vector<os_item>::iterator it = conf->elements.begin(); it != conf->elements.end(); ++it) {
        LinboOSWidget *os = new LinboOSWidget(ui->osarea, (MAXOSCOLUMN+1)*row+col, &*it);
        connect(os, &LinboOSWidget::doStart, this, &LinboGUI::doStart);
        connect(os, &LinboOSWidget::doSync, this, &LinboGUI::doSync);
        connect(os, &LinboOSWidget::doNew, this, &LinboGUI::doNew);
        connect(os, &LinboOSWidget::doInfo, this, &LinboGUI::doInfoDialog);
        ui->osareaLayout->addWidget(os, row, col);
        os->show();
        col++;
        if(col > MAXOSCOLUMN){
            col = 0;
            row++;
        }
    }
    ui->osarea->adjustSize();
}

void LinboGUI::showImages()
{
    int row = 0;
    for(std::vector<os_item>::iterator it = conf->elements.begin(); it != conf->elements.end(); ++it) {
        LinboImageWidget *img = new LinboImageWidget(ui->imagearea, row, &*it);
        connect(img, &LinboImageWidget::doCreate, this, &LinboGUI::doCreateDialog);
        connect(img, &LinboImageWidget::doUpload, this, &LinboGUI::doUploadDialog);
        ui->imageareaLayout->addWidget(img, row, 0);
        img->show();
        row++;
    }
    ui->imagearea->adjustSize();
}

void LinboGUI::performLogin(QString passwd)
{
#ifdef TESTCOMMAND
    if( passwd.compare(QString("muster")) == 0 ){
#else
    if( command->doAuthenticateCommand( passwd ) ) {
#endif
        root = true;
        ui->cbTimeout->setEnabled( true );
        ui->cbTimeout->setChecked( true );
        ui->timeoutCounter->setEnabled( true );
        ui->timeoutCounter->display( roottimeout );
        logoutTimer = this->startTimer( 1000 );
        ui->systeme->setCurrentIndex( ADMINTAB );
    }
    else {
        QMessageBox::information( this, QString("Login"),
                                  QString("Das angegebene Passwort ist falsch."),
                                  QMessageBox::Ok);
    }
}

void LinboGUI::performLogout()
{
    if( logoutTimer != 0 ){
        this->killTimer( logoutTimer );
        logoutTimer = 0;
    }
    root = false;
    command->clearPassword();
    ui->cbTimeout->setEnabled( false );
    ui->timeoutCounter->setEnabled( false );
    ui->timeoutCounter->display( 0 );
    if( ui->systeme->currentIndex() == ADMINTAB ) {
        ui->systeme->setCurrentIndex(0);
    }
}

void LinboGUI::on_logout_clicked()
{
    performLogout();
}

void LinboGUI::timerEvent(QTimerEvent *event)
{
    if( event->timerId() == logoutTimer ) {
        int time = ui->timeoutCounter->intValue();
        if( --time <= 0 ){
            performLogout();
        }
        else {
            ui->timeoutCounter->display( time );
        }
    }
}

void LinboGUI::on_cbTimeout_toggled(bool checked)
{
    ui->timeoutCounter->setEnabled( checked );
    if( checked ) {
        ui->timeoutCounter->display( roottimeout );
        logoutTimer = this->startTimer( 1000 );
    }
    else {
        if( logoutTimer != 0 ) {
            this->killTimer( logoutTimer );
            logoutTimer = 0;
        }
    }
}

void LinboGUI::doCommand(const QStringList& command, bool interruptible, const QString& titel, Aktion aktion, bool* details)
{
    QStringList *cmd = new QStringList(command);
    progress = new FortschrittDialog( this, cmd, logConsole, titel, aktion, details );
    progress->setShowCancelButton( interruptible );
    progress->exec();
}

void LinboGUI::on_console_clicked()
{
    linboConsole console( this );
    console.exec();
}

void LinboGUI::doAutostart()
{
    doCommand(command->mkstartcommand(conf->config.get_autostartosnr()), false);
}

void LinboGUI::doStart(int nr)
{
    doCommand(command->mkstartcommand(nr), false);
}

void LinboGUI::doSync(int nr)
{
    doCommand(command->mksyncstartcommand(nr), false);
}

void LinboGUI::doNew(int nr)
{
    doCommand(command->mksyncstartcommand(nr), false);
}

void LinboGUI::on_initcache_clicked()
{
    linboMulticastBox* dlg = new linboMulticastBox(this, conf->config.get_autoformat(), conf->config.get_downloadtype());
    connect(dlg, &linboMulticastBox::finished, this, &LinboGUI::doInitCache);
    dlg->exec();
}

void LinboGUI::on_partition_clicked()
{
    doCommand(command->mkpartitioncommand(), false);
}

void LinboGUI::doAutostartDialog()
{
    Autostart* dlg = new Autostart( this, conf->config.get_autostarttimeout(), QString("Autostart " + conf->config.get_autostartosname()));
    connect( dlg, &Autostart::accepted, this, &LinboGUI::doAutostart);
    dlg->exec();
}

void LinboGUI::doInfoDialog(int nr)
{
    QString filename = conf->elements[nr].image_history[conf->elements[nr].find_current_image()].get_image();
    QString description = QString("");
    QFile* file = new QFile( filename );
    // read content
    if( !file->open( QIODevice::ReadOnly ) ) {
      logConsole->writeStdErr( QString("Keine passende Beschreibung im Cache.") );
    }
    else {
      QTextStream ts( file );
      description = ts.readAll();
      file->close();
    }

    linboInfoBrowser* dlg = new linboInfoBrowser( this, filename, description, !isRoot());
    dlg->exec();
}

void LinboGUI::doCreateDialog(int nr)
{
    vector<image_item>* history = &conf->elements[nr].image_history;
    linboImageSelector* dlg = new linboImageSelector( this, nr, history, command );
    connect(dlg,SIGNAL(finished(int, const QString&, const QString&, bool, bool, FolgeAktion)),
            this, SLOT(doCreate(int, const QString&, const QString&, bool, bool, FolgeAktion)));
    dlg->exec();
}

void LinboGUI::doUploadDialog(int nr)
{
    vector<image_item> history = conf->elements[nr].image_history;
    linboImageUpload* dlg = new linboImageUpload( this, &history );
    connect(dlg, SIGNAL(finished(const QString&, FolgeAktion)),
            this, SLOT(doUpload(const QString&, FolgeAktion)));
    dlg->exec();
}

void LinboGUI::doCreate(int nr, const QString& imageName, const QString& description, bool isnew, bool upload, Aktion aktion)
{
    QString baseImage = imageName.left(imageName.lastIndexOf(".")) + Command::BASEIMGEXT;
    doCommand(command->mkcreatecommand(nr, imageName, baseImage), true);
    if(isnew){
        os_item os = conf->elements[nr];
        image_item new_image;
        os.image_history.push_back(new_image);
    }

    QString tmpName = Command::TMPDIR + imageName + Command::DESCEXT;
    QString destination = imageName + Command::DESCEXT;

    QFile* file = new QFile( tmpName );
    if ( !file->open( QIODevice::WriteOnly ) ) {
        logConsole->writeStdErr( QString("Fehler beim Speichern der Beschreibung.") );
    } else {
        QTextStream ts( file );
        ts << description;
        file->flush();
        file->close();
    }
    delete file;
    command->doWritefileCommand(tmpName, destination);

    if( upload ){
        doCommand(command->mkuploadcommand(imageName), true);
    }
    if(aktion == Aktion::Reboot)
        system("busybox reboot");
    else if(aktion == Aktion::Shutdown)
        system("busybox shutdown");
}

void LinboGUI::doUpload(const QString &imageName, Aktion aktion)
{
    doCommand( command->mkuploadcommand( imageName), true );

    if (aktion == Aktion::Shutdown) {
        system("busybox poweroff");
    } else if (aktion == Aktion::Reboot) {
        system("busybox reboot");
    }
}

void LinboGUI::doInfo(const QString& filename, const QString& description)
{
    QString tmpname = command->TMPDIR + filename;
    QFile* file = new QFile( tmpname );
    if ( !file->open( QIODevice::WriteOnly ) ) {
        logConsole->writeStdErr( QString("Fehler beim Speichern der Beschreibung.") );
    } else {
        QTextStream ts( file );
        ts << description;
        file->flush();
        file->close();
    }
    delete file;

    command->doWritefileCommand(tmpname, filename);
}

void LinboGUI::doInitCache(bool formatCache, DownloadType type)
{
    doCommand( command->mkcacheinitcommand(formatCache, type) );
}
