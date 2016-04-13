#include <qregexp.h>

#include "command.h"
#include "qprocess.h"
#include "image_description.h"
#include "downloadtype.h"

#ifdef TESTCOMMAND
#define LINBO_CMD(arg) QStringList("echo linbo_cmd") << (arg);
#else
#define LINBO_CMD(arg) QStringList("linbo_cmd") << (arg);
#endif

const QString Command::USER = "linbo";
const QString Command::BASEIMGEXT = ".cloop";
const QString Command::INCIMGEXT = ".rsync";
const QString Command::DESCEXT = ".desc";
const QString Command::TMPDIR = "/tmp/";

// this appends a quoted space in case item is empty and resolves
// problems with linbo_cmd's weird "shift"-usage
void Command::saveappend( QStringList& command, const QString& item ) {
  if ( item.isEmpty() )
    command.append("");
  else
    command.append( item );

}

// Start image
QStringList Command::mkstartcommand(unsigned int osnr, int imnr) {
  QStringList command = LINBO_CMD("start");
  os_item os = conf->elements[osnr];
  image_item im = os.image_history[imnr == -1 ? os.find_current_image() : imnr];
  saveappend( command, os.get_boot() );
  saveappend( command, os.get_root() );
  saveappend( command, im.get_kernel() );
  saveappend( command, im.get_initrd() );
  saveappend( command, im.get_append() );
  return command;
}

// Sync+start image
QStringList Command::mksyncstartcommand(unsigned int osnr,int imnr) {
  QStringList command = LINBO_CMD("syncstart");
  os_item os = conf->elements[osnr];
  image_item im = os.image_history[imnr == -1 ? os.find_current_image() : imnr];
  globals config = conf->config;
  saveappend( command, config.get_server() );
  saveappend( command, config.get_cache() );
  saveappend( command, os.get_baseimage() );
  saveappend( command, im.get_image() );
  saveappend( command, os.get_boot() );
  saveappend( command, os.get_root() );
  saveappend( command, im.get_kernel() );
  saveappend( command, im.get_initrd() );
  saveappend( command, im.get_append() );
  return command;
}

// Sync image from cache
QStringList Command::mksynccommand(unsigned int osnr, int imnr) {
  QStringList command = LINBO_CMD("sync");
  os_item os = conf->elements[osnr];
  image_item im = os.image_history[imnr];
  globals config = conf->config;
  saveappend( command, config.get_cache() );
  saveappend( command, os.get_baseimage() );
  saveappend( command, im.get_image() );
  saveappend( command, os.get_boot() );
  saveappend( command, os.get_root() );
  saveappend( command, im.get_kernel() );
  saveappend( command, im.get_initrd() );
  saveappend( command, im.get_append() );
  return command;
}

// Sync image from server
QStringList Command::mksyncrcommand(unsigned int osnr, int imnr) {
  QStringList command = LINBO_CMD("syncr");
  os_item os = conf->elements[osnr];
  image_item im = os.image_history[imnr];
  globals config = conf->config;
  saveappend( command, config.get_server() );
  saveappend( command, config.get_cache() );
  saveappend( command, os.get_baseimage() );
  saveappend( command, im.get_image() );
  saveappend( command, os.get_boot() );
  saveappend( command, os.get_root() );
  saveappend( command, im.get_kernel() );
  saveappend( command, im.get_initrd() );
  saveappend( command, im.get_append() );
  saveappend( command, QString("force") );
  return command;
}

QStringList Command::mkpartitioncommand() {
  QStringList command = LINBO_CMD("partition");
  vector<diskpartition> p = conf->partitions;
  for(unsigned int i=0; i<p.size(); i++) {
    saveappend( command, p[i].get_dev() );
    saveappend( command, p[i].get_size() );
    saveappend( command, p[i].get_id() );
    saveappend( command, (QString((p[i].get_bootable())?"bootable":"\" \"")) );
    saveappend( command, p[i].get_fstype() );
  }
  return command;
}

QStringList Command::mkpartitioncommand_noformat() {
  QStringList command = LINBO_CMD("partition_noformat");
  vector<diskpartition> p = conf->partitions;
  for(unsigned int i=0; i<p.size(); i++) {
    saveappend( command, p[i].get_dev() );
    saveappend( command, p[i].get_size() );
    saveappend( command, p[i].get_id() );
    saveappend( command, (QString((p[i].get_bootable())?"bootable":"\" \"")) );
    saveappend( command, p[i].get_fstype() );
  }
  return command;
}

QStringList Command::mkcacheinitcommand(bool formatCache, DownloadType type) {
  QStringList command = LINBO_CMD(formatCache ? "initcache_format" : "initcache");
  globals config = conf->config;
  vector<os_item> os = conf->elements;
  saveappend( command, config.get_server() );
  saveappend( command, config.get_cache() );
  saveappend( command, downloadtypeQString[type]);

  for(unsigned int i = 0; i < os.size(); i++) {
    saveappend( command, os[i].get_baseimage() );
    for(unsigned int j = 0; j < os[i].image_history.size(); j++) {
      saveappend( command, os[i].image_history[j].get_image() );
    }
  }
  return command;
}

QStringList Command::mklinboupdatecommand() {
  QStringList command = LINBO_CMD("update");
  globals config = conf->config;
  saveappend( command, config.get_server() );
  saveappend( command, config.get_cache() );
  return command;
}

QStringList Command::mkpreregistercommand()
{
    QStringList command = LINBO_CMD("preregister");
    saveappend(command, conf->config.get_server());
    return command;
}

QStringList Command::mkregistercommand(QString& roomName, QString& clientName,
                                       QString& ipAddress, QString& clientGroup)
{
    QStringList command = LINBO_CMD("register");
    saveappend(command, "register");
    saveappend(command, conf->config.get_server());
    saveappend(command, "linbo");
    saveappend(command, this->password);
    saveappend(command, roomName);
    saveappend(command, clientName);
    saveappend(command, ipAddress);
    saveappend(command, clientGroup);
    return command;
}

QStringList Command::mkcreatecommand(unsigned int nr, const QString& imageName, const QString& baseImage)
{
    QStringList command = LINBO_CMD("create");
    globals config = conf->config;
    vector<os_item> os = conf->elements;
    if( nr >= os.size()){
        //FIXME: error no such os
        return QStringList();
    }
    saveappend(command, config.get_cache());
    saveappend(command, imageName);
    saveappend(command, baseImage);
    saveappend(command, os[nr].get_boot());
    saveappend(command, os[nr].get_root());
    //FIXME: ist das korrekt zur Identifikation des richtigen Images?
    int img = os[nr].find_current_image();
    saveappend(command, os[nr].image_history[img].get_kernel());
    saveappend(command, os[nr].image_history[img].get_initrd());
    return command;
}

QStringList Command::mkuploadcommand(const QString& imageName)
{
    QStringList command = LINBO_CMD("upload");
    globals config = conf->config;
    if(password.isEmpty()){
        //FIXME: error msg
        return QStringList();
    }
    saveappend(command, config.get_server());
    saveappend(command, USER);
    saveappend(command, password);
    saveappend(command, config.get_cache());
    saveappend(command, imageName);
    return command;
}

QString Command::doSimpleCommand(const QString &cmd)
{
    return doSimpleCommand(cmd, NULL);
}

QString Command::doSimpleCommand(const QString& cmd, const QString& arg)
{
    QProcess *process = new QProcess();
    QStringList command = LINBO_CMD(cmd);
    if( arg != NULL) {
        saveappend( command, arg);
    }
    process->start( command.join(" ") );
#ifdef TESTCOMMAND
    while( !process->waitForFinished(10000) ){
        cerr << "Der Testprozess wurde nicht korrekt durchgeführt.";
     }
#else
    while( !process->waitForFinished(10000) ){
        cerr << "Der Prozess wurde nicht korrekt durchgeführt.";
     }
#endif
    return QString(process->readAllStandardOutput()).remove(QRegExp("[\\n\\r\\t]"));
}

bool Command::doAuthenticateCommand(const QString &password)
{
    QStringList command = LINBO_CMD("authenticate");
    saveappend(command, conf->config.get_server());
    saveappend(command, "linbo");
    saveappend(command, password);
    QProcess *process = new QProcess();
    process->start( command.join(" ") );
    while( !process->waitForFinished(10000)) {}
    if( process->exitCode() == 0 ) {
        this->password = password;
        return true;
    } else {
        this->password = "";
        return false;
    }
}

void Command::doReadfileCommand(const QString &source, const QString &destination)
{
    QStringList command = LINBO_CMD("readfile");
    saveappend(command, conf->config.get_cache());
    saveappend(command, source);
    saveappend(command, destination);
    QProcess *process = new QProcess();
    process->start( command.join(" ") );
    while( !process->waitForFinished(10000)) {}
}

void Command::doWritefileCommand(const QString &source, const QString &destination)
{
    QStringList command = LINBO_CMD("writefile");
    saveappend(command, conf->config.get_cache());
    saveappend(command, destination);
    saveappend(command, source);
    QProcess *process = new QProcess();
    process->start( command.join(" ") );
    while( !process->waitForFinished(10000)) {}
}

Command::Command(Configuration *conf)
{
    this->conf = conf;
}

void Command::clearPassword()
{
    this->password = "";
}
