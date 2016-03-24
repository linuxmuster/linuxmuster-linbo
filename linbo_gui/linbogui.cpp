#include <QMessageBox>
#include <qfile.h>
#include <qtextstream.h>
#include <qobject.h>

#include "linbooswidget.h"

#include "linbogui.h"
#include "ui_linbogui.h"
#include "registrierungsdialog.h"
#include "configuration.h"
#include "command.h"
#include "linboRegisterBox.h"
#include "linboimagewidget.h"
#include "login.h"

LinboGUI::LinboGUI(QWidget *parent): QWidget(parent),
    conf(),command(), process(new QProcess(this)),
    logConsole(new linboLogConsole),
    ui(new Ui::LinboGUI)
{
    ui->setupUi(this);
    conf = new Configuration();
    command = new Command(conf);

    // reset root - we're an user now
    root = false;
    // automatic logout after roottimeout;
    roottimeout = 600;
    // we want to see icons
    withicons = true;

    // show command output on LINBO console
    outputvisible = true;

    // default setting -> no image selected for autostart
    autostart = 0;
    autostarttimeout = 0;

    // first "last visited" tab is start tab
    preTab = 0;

    // logfilepath
    logfilepath = QString("/tmp/linbo.log");

    // connect to process
    connect(process,SIGNAL(started()),this,SLOT(disableButtons()));
    connect(process,SIGNAL(finished(int)),this,SLOT(restoreButtonsState()));

    // clear buttons array
    p_buttons.clear();
    buttons_config.clear();

    p_buttons.push_back(ui->update);
    buttons_config.push_back(ui->update->isEnabled() ? 1 : 0);
    p_buttons.push_back(ui->halt);
    buttons_config.push_back(ui->halt->isEnabled() ? 1 : 0);
    p_buttons.push_back(ui->reboot);
    buttons_config.push_back(ui->reboot->isEnabled() ? 1 : 0);

    // administrator buttons
    p_buttons.push_back(ui->console);
    buttons_config.push_back(ui->console->isEnabled() ? 1 : 0);
    p_buttons.push_back(ui->partition);
    buttons_config.push_back(ui->partition->isEnabled() ? 1 : 0);
    p_buttons.push_back(ui->initcache);
    buttons_config.push_back(ui->initcache->isEnabled() ? 1 : 0);
    p_buttons.push_back(ui->doregister);
    buttons_config.push_back(ui->doregister->isEnabled() ? 1 : 0);
    p_buttons.push_back(ui->logout);
    buttons_config.push_back(ui->logout->isEnabled() ? 1 : 0);

    // we can set this now since our globals have been read
    logConsole->setLinboLogConsole( conf->config.get_consolefontcolorstdout(),
                                    conf->config.get_consolefontcolorstderr(),
                                    ui->log );

    showInfos();

    showOSs();

    showImages();

    ui->systeme->setCurrentIndex(0);
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

void LinboGUI::log( const QString& data ) {
    // write to our logfile
    QFile logfile( logfilepath  );
    logfile.open( QIODevice::WriteOnly | QIODevice::Append );
    QTextStream logstream( &logfilepath );
    logstream << data << "\n";
    logfile.flush();
    logfile.close();
}

void LinboGUI::readFromStdout()
{
    // TODO: reactivate log
    // log( linestdout );

    if( outputvisible ) {
        logConsole->writeStdOut( process->readAllStandardOutput() );
    }
}

void LinboGUI::readFromStderr()
{
    // TODO: reactivate log
    // log( linestderr );

    if( outputvisible ) {

        logConsole->writeStdErr( process->readAllStandardError() );
    }

}



void LinboGUI::enableButtons() {
    root = true;
    for( unsigned int i = 0; i < p_buttons.size(); i++ ) {
        if( buttons_config[i] == 2 )
            p_buttons[i]->setEnabled( false );
        else
            p_buttons[i]->setEnabled( true );
    }
}

void LinboGUI::resetButtons() {
    root = false;
    ui->systeme->setCurrentIndex( preTab );
    for( unsigned int i = 0; i < p_buttons.size(); i++ ) {
        if( buttons_config[i] == 2 )
            p_buttons[i]->setEnabled( true );
        else
            p_buttons[i]->setEnabled( buttons_config[i] );

        buttons_config_save[i] = p_buttons[i]->isEnabled();
    }
}

void LinboGUI::disableButtons() {
    for( unsigned int i = 0; i < p_buttons.size(); i++ ) {
        // save buttons state

        buttons_config_save[i] = p_buttons[i]->isEnabled();
        p_buttons[i]->setEnabled( false );
    }
}

void LinboGUI::restoreButtonsState() {
    for( unsigned int i = 0; i < p_buttons.size(); i++ ) {
        p_buttons[i]->setEnabled( buttons_config_save[i] );
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
      process->start( command->mklinboupdatecommand().join(" ") );
}

void LinboGUI::on_systeme_currentChanged(int index)
{
    if( !isRoot() ) {
        if( isAdminTab(index)) {
            // if our partition button is disabled, there is a linbo_cmd running
            if( process->state() != QProcess::Running ) {
                ui->systeme->setCurrentIndex( preTab );
                Login *dlg = new Login( this );
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
    ifstream newdata;
    QString registerData;
    QStringList registerDataList;
    char line[1024];
    command->doSimpleCommand(command->mkpreregistercommand().join(" "));
    newdata.open("/tmp/newregister", ios::in);
    if (newdata.is_open()) {
        newdata.getline(line,1024,'\n');
        registerData = QString::fromUtf8( line, -1 ).trimmed();
        newdata.close();
        registerDataList = registerData.split(',');
    }
    linboRegisterBox *regdlg;
    if( registerDataList.size() >= 4 ){
        regdlg = new linboRegisterBox( this, registerDataList[0], registerDataList[1],
                registerDataList[2], registerDataList[3]);
    }
    else {
        regdlg = new linboRegisterBox( this );
    }
    connect(regdlg,SIGNAL(finished(QString&, QString&, QString&, QString)),
            this,SLOT(do_register(QString&, QString&, QString&, QString)));
    regdlg->exec();
}

void LinboGUI::do_register(QString& roomName, QString& clientName, QString& ipAddress, QString& clientGroup)
{
    command->mkregistercommand(roomName, clientName, ipAddress, clientGroup);
}

void LinboGUI::showOSs()
{
    //FIXME: howto place several OS Widgets
    QWidget *osarea = ui->osarea;
    LinboOSWidget *os = new LinboOSWidget(osarea);
    logConsole->writeStdOut(QString("operating system widget ")+os->windowFilePath()
                            +QString(" added"));
    osarea->adjustSize();
}

void LinboGUI::showImages()
{
    //FIXME: howto place several Image Widgets
    QWidget *imagearea = ui->imagearea;
    LinboImageWidget *img = new LinboImageWidget(imagearea);
    logConsole->writeStdOut(QString("image widget ")+img->windowFilePath()
                            +QString(" added"));
    imagearea->adjustSize();
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
