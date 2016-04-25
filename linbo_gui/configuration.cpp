#include "configuration.h"

#include <fstream>
#include <iostream>
#include <unistd.h>

#include <qstring.h>
#include <qstringlist.h>
#include <qdebug.h>

#include "image_description.h"
#include "commandline.h"

void Configuration::read_qstring( QString& tmp ) {
  char line[500];
  input.getline(line,500,'\n');
  tmp = QString::fromUtf8( line, -1 ).trimmed();
}

void Configuration::read_bool(bool& tmp) {
  char line[500];
  input.getline(line,500,'\n');
  tmp = atoi( line );
}

// Return true unless beginning of new section '[' is found.
bool Configuration::read_pair(QString& key, QString& value) {
  char line[1024];
  if(input.peek() == '[') return false; // Next section found.
  input.getline(line,1024,'\n');
  QString s = QString::fromUtf8( line, -1 ).trimmed();
  key = s.section("=",0,0).trimmed().toLower();
  if(s.startsWith("#")||key.isEmpty()) {
   key = QString(""); value = QString("");
  } else {
   value=s.section("=",1).section("#",0,0).trimmed();
  }
  return true;
}

bool Configuration::toBool(const QString& value) {
  if(value.startsWith("yes",Qt::CaseInsensitive)) return true;
  if(value.startsWith("true",Qt::CaseInsensitive)) return true;
  if(value.startsWith("enable",Qt::CaseInsensitive)) return true;
  return false;
}

void Configuration::read_os( os_item& tmp_os, image_item& tmp_image ) {
  QString key, value;
  while(!input.eof() && read_pair(key, value)) {
    if(key.compare("name") == 0) tmp_os.set_name(value);
    else if(key.compare("description") == 0)  tmp_image.set_description(value);
    else if(key.compare("version") == 0)      tmp_image.set_version(value);
    else if(key.compare("iconname") == 0)     tmp_os.set_iconname(value);
    else if(key.compare("image") == 0)        tmp_image.set_image(value);
    else if(key.compare("baseimage") == 0)    tmp_os.set_baseimage(value);
    else if(key.compare("boot") == 0)         tmp_os.set_boot(value);
    else if(key.compare("root") == 0)         tmp_os.set_root(value);
    else if(key.compare("kernel") == 0)       tmp_image.set_kernel(value);
    else if(key.compare("initrd") == 0)       tmp_image.set_initrd(value);
    else if(key.compare("append") == 0) {
        tmp_image.set_append(value);
    }
    else if(key.compare("syncenabled") == 0)  tmp_image.set_syncbutton(toBool(value));
    else if(key.compare("startenabled") == 0) tmp_image.set_startbutton(toBool(value));
    else if((key.compare("remotesyncenabled") == 0) || (key.compare("newenabled") == 0))   tmp_image.set_newbutton(toBool(value));
    else if(key.compare("defaultaction") == 0) tmp_image.set_defaultaction(value);
    else if(key.compare("autostart") == 0)   tmp_image.set_autostart(toBool(value));
    else if(key.compare("autostarttimeout") == 0)   tmp_image.set_autostarttimeout(value.toInt());
    else if(key.compare("hidden") == 0)   tmp_image.set_hidden(toBool(value));
  }
  if(tmp_image.get_image().isEmpty())
      tmp_image.set_image(tmp_os.get_baseimage());
}

void Configuration::read_partition( diskpartition& p ) {
  QString key, value;
  while(!input.eof() && read_pair(key, value)) {
    if(key.compare("dev") == 0) p.set_dev(value);
    else if(key.compare("size") == 0)  p.set_size(value);
    else if(key.compare("id") == 0)  p.set_id(value);
    else if(key.compare("fstype") == 0)  p.set_fstype(value);
    else if(key.compare("label") == 0) p.set_label(value);
    else if(key.startsWith("bootable", Qt::CaseInsensitive))  p.set_bootable(toBool(value));
  }
}

void Configuration::read_globals() {
  QString key, value;
  while(!input.eof() && read_pair(key, value)) {
    if(key.compare("server") == 0) config.set_server(value);
    else if(key.compare("cache") == 0)  config.set_cache(value);
    else if(key.compare("roottimeout") == 0)  config.set_roottimeout((unsigned int)value.toInt());
    else if(key.compare("group") == 0)  config.set_hostgroup(value);
    else if(key.compare("kerneloptions") == 0) config.set_kerneloptions(value);
    else if(key.compare("systemtype") == 0) config.set_systemtype(value);
    else if(key.compare("autopartition") == 0) config.set_autopartition(toBool(value));
    else if(key.compare("autoinitcache") == 0) config.set_autoinitcache(toBool(value));
    else if(key.compare("backgroundfontcolor") == 0) config.set_backgroundfontcolor(value);
    else if(key.compare("consolefontcolorstdout") == 0) config.set_consolefontcolorstdout(value);
    else if(key.compare("consolefontcolorstderr") == 0) config.set_consolefontcolorstderr(value);
    else if(key.compare("usemulticast") == 0) {
      if( (unsigned int)value.toInt() == 0 )
        config.set_downloadtype("rsync");
      else
        config.set_downloadtype("multicast");
    }
    else if(key.compare("downloadtype") == 0) config.set_downloadtype(value);
    else if(key.compare("autoformat") == 0) config.set_autoformat(toBool(value));
  }
}


void Configuration::init(const char name[])
{
    char filename[FILENAME_MAX];
    getcwd(filename,sizeof(filename));
    strcat(filename, "/");
    strcat(filename, name);
      input.open( filename, ios_base::in );
      if( input.fail() ){
          qWarning() << "Die Datei " << filename << " konnte nicht geöffnet werden.";
          return;
      }

	  QString tmp_qstring;

	  while( !input.eof() ) {
	    // entry in start tab
        read_qstring(tmp_qstring);
	    if ( tmp_qstring.startsWith("#") || tmp_qstring.isEmpty() ) continue;

        tmp_qstring = tmp_qstring.section("#",0,0).trimmed(); // Strip comment
        if(tmp_qstring.toLower().compare("[os]") == 0) {
	      os_item tmp_os;
	      image_item tmp_image;
          read_os(tmp_os, tmp_image);
	      if(!tmp_os.get_name().isEmpty()) {
	        // check if this is an additional/incremental image for an existing OS
	        unsigned int i; // Being checked later.
	        for(i = 0; i < elements.size(); i++ ) {
              if(tmp_os.get_name().toLower().compare(elements[i].get_name().toLower()) == 0) {
	            elements[i].image_history.push_back(tmp_image); break;
	          }
	        }
	        if(i==elements.size()) { // Not included yet -> new image
	          tmp_os.image_history.push_back(tmp_image);
	          elements.push_back(tmp_os);
              if(tmp_image.get_autostart() && tmp_image.get_autostarttimeout() != 0){
                  config.set_autostart(&tmp_image);
                  config.set_autostarttimeout(tmp_image.get_autostarttimeout());
                  config.set_autostartosname(tmp_os.get_name());
                  config.set_autostartosnr(elements.size()-1);
              }
	        }
	      }
        } else if(tmp_qstring.toLower().compare("[linbo]") == 0) {
          read_globals();
        } else if(tmp_qstring.toLower().compare("[partition]") == 0) {
	      diskpartition tmp_partition;
          read_partition(tmp_partition);
	      if(!tmp_partition.get_dev().isEmpty()) {
	        partitions.push_back(tmp_partition);
	      }
	    }
	  }
	  input.close();
}

Configuration::Configuration(const char name[]): commandline()
{
    init(name);
    if( commandline.getConf() != NULL ){
        init(commandline.getConf().toLocal8Bit());
        if(commandline.getExtraConf() != NULL ){
            init(commandline.getExtraConf().toLocal8Bit());
        }
    }
    if( commandline.noAuto() ){
        this->config.set_autostart(NULL);
        this->config.set_autostartosname(NULL);
        this->config.set_autostartosnr( 0 );
    }
    if( commandline.noButtons() ){
        for(std::vector<os_item>::iterator it = this->elements.begin(); it != this->elements.end(); ++it) {
            os_item os = *it;
            for(std::vector<image_item>::iterator iit = os.image_history.begin(); iit != os.image_history.end(); ++iit) {
                image_item img = *iit;
                img.set_newbutton(false);
                img.set_startbutton(false);
                img.set_syncbutton(false);
                img.set_autostart(false);
                img.set_hidden(true);
            }
        }
    }
}

Configuration::Configuration(): commandline()
{
    init("start.conf");
}

CommandLine Configuration::getCommandLine()
{
    return commandline;
}
