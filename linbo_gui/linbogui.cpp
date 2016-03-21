#include <qfile.h>
#include <qtextstream.h>

#include "linbogui.h"
#include "ui_linbogui.h"
#include "registrierungsdialog.h"
#include "configuration.h"
#include "command.h"

LinboGUI::LinboGUI(QWidget *parent) :
    QWidget(parent),
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

    // clear buttons array
    p_buttons.clear();
    buttons_config.clear();

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
}

LinboGUI::~LinboGUI()
{
    delete ui;
}

bool LinboGUI::isRoot() const {
    return root;
}

void LinboGUI::showImagingTab() {
    ui->systeme->setCurrentIndex( (ui->systeme->count() - 1) );
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

void LinboGUI::tabWatcher( QWidget* currentWidget) {

    if( !isRoot() ) {
        if( isAdminTab(ui->systeme->indexOf(currentWidget) )) {
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

globals LinboGUI::config()
{
    return conf->config;
}
