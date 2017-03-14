#include <qregexp.h>
#include <qdebug.h>

#include "command.h"
#include "qprocess.h"
#include "image_description.h"
#include "downloadtype.h"

#define LINBO_CMD(arg) QStringList("linbo_cmd") << (arg);

const QString Command::USER = "linbo";
const QString Command::BASEIMGEXT = ".cloop";
const QString Command::INCIMGEXT = ".rsync";
const QString Command::DESCEXT = ".desc";
const QString Command::TMPDIR = "/tmp/";
const QString Command::LINBOCMDSEP = ",";

//Pattern mit genau einer heraus gefilterten ganzen Zahl
std::map<Command::CmdValue, QString> Command::mapMaxPattern
= {
      {linbo,"DONT MATCH"},
      {partition,"DONT MATCH"},
      {format,"DONT MATCH"},
      {initcache,"Total\\:\\s+(\\d+)\\s+MB"},
      {create_cloop,"Block size \\d+, expected number of blocks: (\\d+)"},
      {upload_cloop,"DONT MATCH"}, //es bleibt bei der Prozentanzeige
      {create_rsync,"DONT MATCH"},
      {upload_rsync,"DONT MATCH"},
      {sync,"DONT MATCH"},
      {start,"DONT MATCH"},
      {update,"DONT MATCH"},
      {reboot,"DONT MATCH"},
      {halt,"DONT MATCH"},
      {poweroff,"DONT MATCH"}
};

// Pattern mit genau einer heraus gefilterten ganzen Zahl
std::map<Command::CmdValue, QString> Command::mapValPattern
= {
      {linbo,"DONT MATCH"},
      {partition,"DONT MATCH"},
      {format,"DONT MATCH"},
      {initcache,"\\d+\\]\\s+(\\d+)MB,"},
      {create_cloop,"Blk#\\s+(\\d+),"},
      {upload_cloop,"\\s+(\\d+)%\\s+"},
      {create_rsync,"DONT MATCH"},
      {upload_rsync,"DONT MATCH"},
      {sync,"DONT MATCH"},
      {start,"DONT MATCH"},
      {update,"DONT MATCH"},
      {reboot,"DONT MATCH"},
      {halt,"DONT MATCH"},
      {poweroff,"DONT MATCH"}
};

// this appends a quoted space in case item is empty and resolves
// problems with linbo_cmd's weird "shift"-usage
void Command::saveappend( QStringList& command, const QString& item ) {
  if ( item.isEmpty() )
    command.append("\"\"");
  else
    command.append( item );

}

// parse Wrapper commands and create List of QStringList
vector<QStringList> Command::parseWrapperCommands(const QString& input)
{
    vector<QStringList> ret = vector<QStringList>();
    QStringListIterator cmds(input.split(LINBOCMDSEP));
    while( cmds.hasNext() ){
        ret.push_back(parseWrapperCommand(cmds.next()));
    }
    return ret;
}

std::map<QString, Command::CmdValue> Command::s_mapCommand
    = {
          {"linbo",linbo},
          {"partition",partition},
          {"format",format},
          {"initcache",initcache},
          {"create_cloop",create_cloop},
          {"upload_cloop",upload_cloop},
          {"create_rsync",create_rsync},
          {"upload_rsync",upload_rsync},
          {"sync",sync},
          {"start",start},
          {"update",update},
          {"reboot",reboot},
          {"halt",halt},
          {"poweroff",poweroff}
    };

// parse Warpper command
QStringList Command::parseWrapperCommand(const QString& input)
{
    QString s = input.trimmed();
    qDebug() << "parseWrapperCommand: " << s;
    QStringList parts = s.split(":");
    QString cmd = QString(""), param = QString(""), msg = QString(""), customimage = QString("");
    cmd = parts.at(0);
    if(parts.length() > 1){
           param = parts.at(1);
           if(parts.length() > 2){
               msg = parts.at(2);
               if(parts.length() > 3){
                   customimage = parts.at(3);
               }
           }
    }

    QStringList cmds;
    bool ok;
    std::map<QString, Command::CmdValue>::iterator it = s_mapCommand.find(cmd);
    if( it == s_mapCommand.end() ){
        qWarning() << "Fehler: unbekannter Befehl " << cmd << "!\n";
        return QStringList();
    }
    switch(s_mapCommand.at(cmd)){
    case linbo:
        if(param != NULL){
            this->password = param;
        }
    break;

    case partition:
        return mkpartitioncommand_noformat();

    case initcache:
        if(param == NULL || param.compare(QString("")) == 0){
            return mkcacheinitcommand(false, conf->config.get_downloadtype());
        } else {
            DownloadType type = conf->config.get_downloadtype();
            if(param.compare(downloadtypeQString[RSync]) == 0) {
                type = RSync;
            } else if(param.compare(downloadtypeQString[Torrent]) == 0){
                type = Torrent;
            } else if(param.compare(downloadtypeQString[Multicast]) == 0){
                type = Multicast;
            }
            return mkcacheinitcommand(false, type);
        }

    case update:
        return mklinboupdatecommand();

    case reboot:
        cmds = QStringList("busybox");
        cmds.append("reboot");
        return cmds;

    case halt:
    case poweroff:
        cmds = QStringList("busybox");
        cmds.append("halt");
        return cmds;

    // commands with parameter "partition nr (extern: 1,... | intern: 0,...)
    case format:
        if( param != NULL && param.compare(QString("")) != 0){
            int partnr = conf->toPartitionNr(param, &ok);
            if(ok){
                return mkformatcommand(partnr);
            } else {
                qWarning() << "Fehler: Ungültige Partitionsnummer!\n";
            }
        } else {
            return mkpartitioncommand();
        }
        break;

    // commands with parameter "os nr (extern: 1,... | intern: 0,...)
    case upload_cloop:
    case upload_rsync:
        if( param != NULL && param.compare(QString("")) != 0){
            int osnr = conf->toOSNr(param, &ok);
            if(ok){
                os_item os = conf->elements[osnr];
                if(customimage == NULL || customimage.compare(QString("")) == 0){
                    customimage = os.get_baseimage();
                }
                return mkuploadcommand(customimage);
            } else {
                qWarning() << "Fehler: Ungültige OS-Nr!\n";
            }
        } else {
            qWarning() << "Fehler: Keine OS-Nr!\n";
        }
        break;

    case create_cloop:
        if( param != NULL && param.compare(QString("")) != 0){
            int osnr = conf->toOSNr(param, &ok);
            os_item os = conf->elements[osnr];
            if(ok){
                if(customimage == NULL || customimage.compare(QString("")) == 0){
                    customimage = os.get_baseimage();
                }
                //FIXME create_desc
                return mkcreatecommand(osnr, customimage, QString(""));
            } else {
                qWarning() << "Fehler: Ungültige OS-Nr!\n";
            }
        } else {
            qWarning() << "Fehler: Keine Partitionsnummer!\n";
        }
        break;

    case create_rsync:
        if( param != NULL && param.compare(QString("")) != 0){
            int osnr = conf->toOSNr(param, &ok);
            os_item os = conf->elements[osnr];
            if(ok){
                if(customimage == NULL || customimage.compare(QString("")) == 0){
                    customimage = os.get_baseimage();
                }
                //FIXME create_desc
                return mkcreatecommand(osnr, customimage, os.get_baseimage());
            } else {
                qWarning() << "Fehler: Ungültige OS-Nr!\n";
            }
        } else {
            qWarning() << "Fehler: Keine OS-Nr!\n";
        }
        break;

    case sync:
        if( param != NULL && param.compare(QString("")) != 0){
            int osnr = conf->toOSNr(param, &ok);
            if(ok){
                return mksynconlycommand(osnr);
            } else {
                qWarning() << "Fehler: Ungültige OS-Nr!\n";
            }
        } else {
            qWarning() << "Fehler: Keine OS-Nr!\n";
        }
        break;

    case start:
        if( param != NULL && param.compare(QString("")) != 0){
            int osnr = conf->toOSNr(param, &ok);
            if(ok){
                return mkstartcommand(osnr);
            } else {
                qWarning() << "Fehler: Ungültige OS-Nr!\n";
            }
        } else {
            qWarning() << "Fehler: Keine OS-Nr!\n";
        }
        break;
    }
    return QStringList();
}

// format partition
QStringList Command::mkformatcommand(unsigned int partnr) {
  QStringList command = LINBO_CMD("format");
  diskpartition part = conf->partitions[partnr];
  saveappend( command, part.get_dev() );
  saveappend( command, part.get_fstype() );
  saveappend( command, part.get_label() );
  return command;
}

// Start image
QStringList Command::mkstartcommand(unsigned int osnr, int imnr) {
  QStringList command = LINBO_CMD("start");
  os_item os = conf->elements[osnr];
  image_item im = os.image_history[imnr == -1 ? os.find_current_image() : imnr];
  globals config = conf->config;
  saveappend( command, os.get_boot() );
  saveappend( command, os.get_root() );
  saveappend( command, im.get_kernel() );
  saveappend( command, im.get_initrd() );
  saveappend( command, im.get_append() );
  saveappend( command, config.get_cache() );
  return command;
}

// Sync+start image
QStringList Command::mksyncstartcommand(unsigned int osnr,int imnr, bool format) {
  QStringList command = LINBO_CMD("syncstart");
  os_item os = conf->elements[osnr];
  image_item im = os.image_history[imnr == -1 ? os.find_current_image() : imnr];
  QString imgname = os.get_baseimage().compare(im.get_image()) == 0 ? "\"\"" : im.get_image();
  globals config = conf->config;
  saveappend( command, config.get_server() );
  saveappend( command, config.get_cache() );
  saveappend( command, os.get_baseimage() );
  saveappend( command, imgname );
  saveappend( command, os.get_boot() );
  saveappend( command, os.get_root() );
  saveappend( command, im.get_kernel() );
  saveappend( command, im.get_initrd() );
  saveappend( command, im.get_append() );
  if( format ){
      saveappend( command, QString("force") );
  }
  return command;
}

// Only sync image from cache
QStringList Command::mksynconlycommand(unsigned int osnr, int imnr) {
  QStringList command = LINBO_CMD("synconly");
  os_item os = conf->elements[osnr];
  image_item im = os.image_history[imnr == -1 ? os.find_current_image() : imnr];
  QString imgname = os.get_baseimage().compare(im.get_image()) == 0 ? "" : im.get_image();
  globals config = conf->config;
  saveappend( command, config.get_server() );
  saveappend( command, config.get_cache() );
  saveappend( command, os.get_baseimage() );
  saveappend( command, imgname );
  saveappend( command, os.get_boot() );
  saveappend( command, os.get_root() );
  saveappend( command, im.get_kernel() );
  saveappend( command, im.get_initrd() );
  saveappend( command, im.get_append() );
  return command;
}

// Only sync image from cache
QStringList Command::mksynconlycommand(unsigned int osnr, int imnr) {
  QStringList command = LINBO_CMD("synconly");
  os_item os = conf->elements[osnr];
  image_item im = os.image_history[imnr == -1 ? os.find_current_image() : imnr];
  QString imgname = os.get_baseimage().compare(im.get_image()) == 0 ? "" : im.get_image();
  globals config = conf->config;
  saveappend( command, config.get_server() );
  saveappend( command, config.get_cache() );
  saveappend( command, os.get_baseimage() );
  saveappend( command, imgname );
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
  image_item im = os.image_history[imnr == -1 ? os.find_current_image() : imnr];
  QString imgname = os.get_baseimage().compare(im.get_image()) == 0 ? "" : im.get_image();
  globals config = conf->config;
  saveappend( command, config.get_cache() );
  saveappend( command, os.get_baseimage() );
  saveappend( command, imgname );
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
  image_item im = os.image_history[imnr == -1 ? os.find_current_image() : imnr];
  QString imgname = os.get_baseimage().compare(im.get_image()) == 0 ? "" : im.get_image();
  globals config = conf->config;
  saveappend( command, config.get_server() );
  saveappend( command, config.get_cache() );
  saveappend( command, os.get_baseimage() );
  saveappend( command, imgname );
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
    if( nr > os.size()){
        //FIXME: error no such os
        return QStringList();
    }
    saveappend(command, config.get_cache());
    saveappend(command, imageName);
    saveappend(command, baseImage);
    saveappend(command, os[nr].get_boot());
    saveappend(command, os[nr].get_root());
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
    while( !process->waitForFinished(10000) ){
        qWarning() << "Der Prozess " << cmd << " wurde nicht korrekt durchgeführt.";
     }
    QString result = QString(process->readAllStandardOutput());
    delete process;
    result.remove(QRegExp("\\t"));
    result.remove(QRegExp("[\\n\\r]{1,2}$"));
    return result;
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
        delete process;
        return true;
    } else {
        this->password = "";
        delete process;
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
    delete process;
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
    delete process;
}

Command::Command(Configuration *conf)
{
    this->conf = conf;
}

Command::~Command()
{

}

void Command::clearPassword()
{
    this->password = "";
}
