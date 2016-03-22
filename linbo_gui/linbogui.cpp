#include <qfile.h>
#include <qtextstream.h>

#include <plugins/oswidget/linbooswidget.h>

#include "linbogui.h"
#include "ui_linbogui.h"
#include "registrierungsdialog.h"
#include "configuration.h"
#include "command.h"
#include "linboRegisterBox.h"

LinboGUI::LinboGUI(QWidget *parent): QWidget(parent),
    conf(),command(), process(new QProcess(this)), logConsole(new linboLogConsole),
    ui(new Ui::LinboGUI)
{
    ui->setupUi(this);
    conf = new Configuration();
    command = new Command(conf);

    // reset root - we're an user now
    root = false;

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
    connect(process,SIGNAL(started()),this,SLOT(disableButtons));
    connect(process,SIGNAL(finished(int)),this,SLOT(restoreButtonsState));

    // clear buttons array
    p_buttons.clear();
    buttons_config.clear();

    p_buttons.push_back(ui->update);
    buttons_config.push_back(ui->update->isEnabled() ? 1 : 0);
    p_buttons.push_back(ui->halt);
    buttons_config.push_back(ui->halt->isEnabled() ? 1 : 0);
    p_buttons.push_back(ui->reboot);
    buttons_config.push_back(ui->reboot->isEnabled() ? 1 : 0);

    // we can set this now since our globals have been read
    logConsole->setLinboLogConsole( conf->config.get_consolefontcolorstdout(),
                                    conf->config.get_consolefontcolorstderr(),
                                    ui->log );

    // since some tabs can be hidden, we have to maintain this counter
    int nextPosForTabInsert = 0;
    int horizontalOffset = 0;
    // this is for separating the elements
    int innerVerticalOffset = 32;

    for( unsigned int i = 0; i < conf->elements.size(); i++ ) {
        // this determines our vertical offset
        if( i % 2 == 1 ) {
            // an odd element is moved to the right
            horizontalOffset = 300;
        } else {
            horizontalOffset = 0;
        }


    }

    showInfos();

    showOSs();

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
            if( p_buttons[ ( p_buttons.size() - 1 ) ]->isEnabled() ) {
                ui->systeme->setCurrentIndex( preTab );
                myQPasswordBox->show();
                myQPasswordBox->raise();
               //FIXME:  myQPasswordBox->setActiveWindow();
                myQPasswordBox->setEnabled( true );
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
    linboRegisterBox *regdlg = new linboRegisterBox( this );
    connect(regdlg,SIGNAL(finished(int)),this,SLOT(do_register(int)));
    regdlg->show();
}

void LinboGUI::do_register(int result)
{
    if(result == QDialog::Accepted){

    }
}

void LinboGUI::showOSs()
{
    QWidget *osarea = ui->osarea;
    LinboOSWidget *os = new LinboOSWidget(osarea);
    osarea->adjustSize();
}
