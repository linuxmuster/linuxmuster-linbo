/* class building the LINBO GUI

Copyright (C) 2007 Martin Oehler <oehler@knopper.net>
Copyright (C) 2007 Klaus Knopper <knopper@knopper.net>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

*/

#include "linboGUIImpl.hh"
#include <signal.h> // for signal()
#include <qpushbutton.h>
#include <q3buttongroup.h>
#include <qstringlist.h>
#include <qlabel.h>
#include <qtabwidget.h>
#include <q3listbox.h>
#include <qapplication.h>
#include <q3scrollview.h>
#include <qtooltip.h>
#include <qfile.h>
#include <q3textstream.h>
#include <qpixmap.h>
#include <qimage.h>
#include <QBrush>
#include <qregexp.h>
#include <stdlib.h>
#include <q3stylesheet.h>

#include "linboProgressImpl.hh"
#include "linboMulticastBoxImpl.hh"
#include "linboDialog.hh"
#include "linboYesNoImpl.hh"
#include "linboInputBoxImpl.hh"
#include "linboImageSelectorImpl.hh"
#include "linboImageUploadImpl.hh"
#include "linboInfoBrowserImpl.hh"
#include "linboRegisterBoxImpl.hh"
#include "linboConsoleImpl.hh"
#include <QtGui>
#include <QTextCursor>
#include <qwindowsystem_qws.h>
#include <QWSServer>

#define LINBO_CMD(arg) QStringList("linbo_cmd") << (arg);

void read_qstring( ifstream* input,
                   QString& tmp ) {
  char line[500];
  input->getline(line,500,'\n');
  tmp = QString::fromAscii( line, -1 ).stripWhiteSpace(); 
}

void read_bool( ifstream* input,
                bool& tmp) {
  char line[500];
  input->getline(line,500,'\n');
  tmp = atoi( line );
}

// Return true unless beginning of new section '[' is found.
bool read_pair(ifstream* input, QString& key, QString& value) {
  char line[1024];
  if(input->peek() == '[') return false; // Next section found.
  input->getline(line,1024,'\n');
  QString s = QString::fromAscii( line, -1 ).stripWhiteSpace();
  key = s.section("=",0,0).stripWhiteSpace().lower();
  if(s.startsWith("#")||key.isEmpty()) {
   key = QString(""); value = QString("");
  } else {
   value=s.section("=",1).section("#",0,0).stripWhiteSpace();
  }
  return true;
}

bool toBool(const QString& value) {
  if(value.startsWith("yes",false)) return true;
  if(value.startsWith("true",false)) return true;
  if(value.startsWith("enable",false)) return true;
  return false;
}

void read_os( ifstream* input, os_item& tmp_os, image_item& tmp_image ) {
  QString key, value;
  while(!input->eof() && read_pair(input, key, value)) {
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
    else if(key.compare("append") == 0)       tmp_image.set_append(value);
    else if(key.compare("syncenabled") == 0)  tmp_image.set_syncbutton(toBool(value));
    else if(key.compare("startenabled") == 0) tmp_image.set_startbutton(toBool(value));
    else if((key.compare("remotesyncenabled") == 0) || (key.compare("newenabled") == 0))   tmp_image.set_newbutton(toBool(value));
    else if(key.compare("defaultaction") == 0) tmp_image.set_defaultaction(value);
    else if(key.compare("autostart") == 0)   tmp_image.set_autostart(toBool(value));
    else if(key.compare("autostarttimeout") == 0)   tmp_image.set_autostarttimeout(value.toInt());
    else if(key.compare("hidden") == 0)   tmp_image.set_hidden(toBool(value));
  }
}

void read_partition( ifstream* input, diskpartition& p ) {
  QString key, value;
  while(!input->eof() && read_pair(input, key, value)) {
    if(key.compare("dev") == 0) p.set_dev(value);
    else if(key.compare("size") == 0)  p.set_size(value.toInt());
    else if(key.compare("id") == 0)  p.set_id(value);
    else if(key.compare("fstype") == 0)  p.set_fstype(value);
    else if(key.startsWith("bootable", false))  p.set_bootable(toBool(value));
  }
}

void read_globals( ifstream* input, globals& g ) {
  QString key, value;
  while(!input->eof() && read_pair(input, key, value)) {
    if(key.compare("server") == 0) g.set_server(value);
    else if(key.compare("cache") == 0)  g.set_cache(value);
    else if(key.compare("roottimeout") == 0)  g.set_roottimeout((unsigned int)value.toInt());
    else if(key.compare("group") == 0)  g.set_hostgroup(value);
    else if(key.compare("autopartition") == 0) g.set_autopartition(toBool(value));
    else if(key.compare("autoinitcache") == 0) g.set_autoinitcache(toBool(value));
    else if(key.compare("backgroundfontcolor") == 0) g.set_backgroundfontcolor(value);
    else if(key.compare("consolefontcolorstdout") == 0) g.set_consolefontcolorstdout(value);
    else if(key.compare("consolefontcolorstderr") == 0) g.set_consolefontcolorstderr(value);
    else if(key.compare("usemulticast") == 0) {
      if( (unsigned int)value.toInt() == 0 ) 
        g.set_downloadtype("rsync"); 
      else
        g.set_downloadtype("multicast"); 
    }
    else if(key.compare("downloadtype") == 0) g.set_downloadtype(value);
    else if(key.compare("autoformat") == 0) g.set_autoformat(toBool(value));
  }
}

// this appends a quoted space in case item is empty and resolves
// problems with linbo_cmd's weird "shift"-usage
void saveappend( QStringList& command,
		 const QString& item ) {
  if ( item.isEmpty() ) 
    command.append("");
  else
    command.append( item );

}

// Sync+start image
QStringList mksyncstartcommand(globals& config, os_item& os, image_item& im) {
  QStringList command = LINBO_CMD("syncstart");
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
QStringList mksynccommand(globals& config, os_item& os, image_item& im) {
  QStringList command = LINBO_CMD("sync");
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
QStringList mksyncrcommand(globals& config, os_item& os, image_item& im) {
  QStringList command = LINBO_CMD("syncr");
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

QStringList mkpartitioncommand(vector <diskpartition> &p) {
  QStringList command = LINBO_CMD("partition");
  for(unsigned int i=0; i<p.size(); i++) {
    saveappend( command, p[i].get_dev() );
    saveappend( command, (QString::number(p[i].get_size())) );
    saveappend( command, p[i].get_id() );
    saveappend( command, (QString((p[i].get_bootable())?"bootable":"\" \"")) );
    saveappend( command, p[i].get_fstype() ); 
  }
  return command;
}

QStringList mkpartitioncommand_noformat(vector <diskpartition> &p) {
  QStringList command = LINBO_CMD("partition_noformat");
  for(unsigned int i=0; i<p.size(); i++) {
    saveappend( command, p[i].get_dev() );
    saveappend( command, (QString::number(p[i].get_size())) );
    saveappend( command, p[i].get_id() );
    saveappend( command, (QString((p[i].get_bootable())?"bootable":"\" \"")) );
    saveappend( command, p[i].get_fstype() );
  }
  return command;
}

// type is 0 for rsync, 1 for multicast, 3 for bittorrent
QStringList mkcacheinitcommand(globals& config, vector<os_item> &os, const QString& type) {
  QStringList command = LINBO_CMD("initcache");
  saveappend( command, config.get_server() );
  saveappend( command, config.get_cache() );
  if( ! type.isEmpty() )
    command.append(type);
  else
    command.append("rsync");

  for(unsigned int i = 0; i < os.size(); i++) {
    saveappend( command, os[i].get_baseimage() );
    for(unsigned int j = 0; j < os[i].image_history.size(); j++) {
      saveappend( command, os[i].image_history[j].get_image() );
    }
  }
  return command;
}

QStringList mklinboupdatecommand(globals& config) {
  QStringList command = LINBO_CMD("update");
  saveappend( command, config.get_server() );
  saveappend( command, config.get_cache() );
  return command;
}



linboGUIImpl::linboGUIImpl()

{ 
 
  Ui_linboGUI::setupUi((QDialog*)this);
 
  QImage tmpImage;

  // our early default
  fonttemplate = tr("<font color='black'>%1</font>");

  logConsole = new linboLogConsole(0);

  Qt::WindowFlags flags;
  flags = Qt::FramelessWindowHint | Qt::WindowStaysOnBottomHint;
  setWindowFlags( flags );
  setAttribute( Qt::WA_AlwaysShowToolTips );

  QRect qRect(QApplication::desktop()->screenGeometry());

  this->move(qRect.width()/2-this->width()/2,
             qRect.height()/2-this->height()/2 );

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

  // connect our shutdown and reboot buttons
  connect( shutdownButton, SIGNAL(clicked()), this, SLOT(shutdown()) );
  connect( rebootButton, SIGNAL(clicked()), this, SLOT(reboot()) );

  // set and scale up our icons
  rebootButton->setIconSet(   QIcon(":/icons/system-reboot-32x32.png" ) );
  rebootButton->setIconSize(QSize(32,32));
  QToolTip::add( rebootButton, QString("Startet den Rechner neu.") );

  shutdownButton->setIconSet( QIcon(":/icons/system-shutdown-32x32.png" ) );
  shutdownButton->setIconSize(QSize(32,32));
  QToolTip::add( shutdownButton, QString("Schaltet den Rechner aus.") );

  hdlogowidget->setPixmap( QPixmap(":/icons/drive-harddisk-64x64.png" ) );
  // hdlogowidget->setIconSize(QSize(64,64));

  pclogowidget->setPixmap( QPixmap(":/icons/computer-64x64.png" ) );
  // pclogowidget->setIconSize(QSize(64,64));

  // clear buttons array
  p_buttons.clear();
  buttons_config.clear();
  // hide the main GUI
  this->hide();

  waiting = new linboMsgImpl( this );
  waiting->message->setText(  QString("LINBO<br>Netzwerk Check") );

  QStringList waitCommand = LINBO_CMD("ready");

  waiting->setWindowFlags( flags );
  waiting->setCommand( waitCommand );
  waiting->move(qRect.width()/2-waiting->width()/2,
                qRect.height()/2-waiting->height()/2 );
    
  waiting->show();
  waiting->raise();
  waiting->setActiveWindow();
  waiting->update();
  waiting->execute();

  QWSServer* wsServer = QWSServer::instance();
  QImage bgimg( "/icons/linbo_wallpaper.png", "PNG" );
  if ( wsServer ) {
    wsServer->setBackground( QBrush( bgimg.scaled( qRect.width(), qRect.height(), Qt::IgnoreAspectRatio ) ) );
    wsServer->refresh();
  }

  // check whether we need to invert the color of some of our labels because of a
  // dark background picture

  ifstream input;
  input.open( "start.conf", ios_base::in );

  QString tmp_qstring;

  while( !input.eof() ) {

    // *** Image description section ***

    // entry in start tab
    read_qstring(&input, tmp_qstring);
    if ( tmp_qstring.startsWith("#") || tmp_qstring.isEmpty() ) continue;

    tmp_qstring = tmp_qstring.section("#",0,0).stripWhiteSpace(); // Strip comment
    if(tmp_qstring.lower().compare("[os]") == 0) {
      os_item tmp_os;
      image_item tmp_image;
      read_os(&input, tmp_os, tmp_image);
      if(!tmp_os.get_name().isEmpty()) {
        // check if this is an additional/incremental image for an existing OS
        unsigned int i; // Being checked later.
        for(i = 0; i < elements.size(); i++ ) {
          if(tmp_os.get_name().lower().compare(elements[i].get_name().lower()) == 0) {
            elements[i].image_history.push_back(tmp_image); break;
          }
        }
        if(i==elements.size()) { // Not included yet -> new image
          tmp_os.image_history.push_back(tmp_image);
          elements.push_back(tmp_os);
        }
      }
    } else if(tmp_qstring.lower().compare("[linbo]") == 0) {
      read_globals(&input, config);
    } else if(tmp_qstring.lower().compare("[partition]") == 0) {
      diskpartition tmp_partition;
      read_partition(&input, tmp_partition);
      if(!tmp_partition.get_dev().isEmpty()) {
        partitions.push_back(tmp_partition);
      }
    }
  }
  input.close();

  // we can set this now since our globals have been read
  logConsole->setLinboLogConsole( config.get_consolefontcolorstdout(),
				  config.get_consolefontcolorstderr(),
				  Console );

  int height = 5;
  int imagingHeight = 5;

  QStringList command;

  startView->setHScrollBarMode(Q3ScrollView::AlwaysOff);
  startView->setVScrollBarMode(Q3ScrollView::Auto);
  startView->setGeometry( QRect( 10, 10, 600, 180 ) );
  startView->viewport()->setBackgroundColor( "white" );

  imagingView->setHScrollBarMode(Q3ScrollView::AlwaysOff);
  imagingView->setVScrollBarMode(Q3ScrollView::Auto);
  imagingView->setGeometry( QRect( 10, 10, 410, 180 ) );
  imagingView->viewport()->setBackgroundColor( "white" );

  partitionView->setHScrollBarMode(Q3ScrollView::AlwaysOff);
  partitionView->setVScrollBarMode(Q3ScrollView::Auto);
  partitionView->setGeometry( QRect( 420, 10, 180, 180 ) );
  partitionView->viewport()->setBackgroundColor( "white" );


  // since some tabs can be hidden, we have to maintain this counter
  int nextPosForTabInsert = 0;
  int horizontalOffset = 0;
  // this is for separating the elements
  int innerVerticalOffset = 32;
 
  for( unsigned int i = 0; i < elements.size(); i++ ) {
    // this determines our vertical offset
    if( i % 2 == 1 ) {
      // an odd element is moved to the right
      horizontalOffset = 300;
    } else {
      horizontalOffset = 0;
    }

    int n = elements[i].find_current_image();
    if ( i == 0 ) {
      height = 14;
      imagingHeight = 14;
    }
    // Start View
    QLabel *startlabel = new QLabel( startView->viewport() );
    startlabel->setGeometry( QRect( (90 + horizontalOffset), height, 180, 30 ) );
    startlabel->setText( elements[i].get_name() + " " + elements[i].image_history[n].get_version() );
    startView->addChild( startlabel, (90 + horizontalOffset), height );

    // Imaging View
    QLabel *imaginglabel = new QLabel( imagingView->viewport() );
    imaginglabel->setGeometry( QRect( 15, imagingHeight, 165, 30 ) );
    imaginglabel->setText( elements[i].get_name() );
    imagingView->addChild( imaginglabel, 15, imagingHeight );

    if( i == 0 ) {
      height = 5;
      imagingHeight = 5;
    }
    // Start Tab
    linbopushbutton *defaultbutton = new linbopushbutton( startView->viewport() );
    defaultbutton->setGeometry( QRect( (15 + horizontalOffset), height, 64, 64 ) );

    QLabel *defaultactionlabel = new QLabel( startView->viewport() );
    defaultactionlabel->setGeometry( QRect( (15 + horizontalOffset), height+42, 22, 22 ) );

    if( withicons ) {
      if( elements[i].get_iconname() == "defaulticon.png" ) {
	defaultbutton->setIconSet( QIcon(":/icons/default.png" ) );
      } else {
	defaultbutton->setIconSet( QIcon(  QString("/icons/") + elements[i].get_iconname() ) );
      }
      defaultbutton->setIconSize( QSize(64,64) );
    }

    if( elements[i].image_history[n].get_defaultaction() == "sync") {
      // assign command
      command = mksyncstartcommand(config, elements[i],elements[i].image_history[n]);
      QToolTip::add( defaultbutton, QString("Startet " + elements[i].get_name() + " " +
                                       elements[i].image_history[n].get_version() +
                                       " synchronisiert") );

      defaultactionlabel->setPixmap( QPixmap(":/icons/sync+start-22x22.png" ) );
      defaultbutton->setEnabled( elements[i].image_history[n].get_syncbutton() );

    } 
    if( elements[i].image_history[n].get_defaultaction() == "new" ) {
      // assign command
      command = mksyncrcommand(config, elements[i],elements[i].image_history[n]);
      QToolTip::add( defaultbutton, QString("Installiert " + elements[i].get_name() + " " +
					elements[i].image_history[n].get_version() +
					" neu und startet es") );

      defaultactionlabel->setPixmap( QPixmap(":/icons/new+start-22x22.png" ) );
      defaultbutton->setEnabled( elements[i].image_history[n].get_newbutton() );
    }
    if( elements[i].image_history[n].get_defaultaction() == "start" ) {
      // assign command
      command = LINBO_CMD("start");
      saveappend( command, elements[i].get_boot() );
      saveappend( command, elements[i].get_root() );
      saveappend( command, elements[i].image_history[n].get_kernel() );
      saveappend( command, elements[i].image_history[n].get_initrd() );
      saveappend( command, elements[i].image_history[n].get_append() );
      saveappend( command, config.get_cache() );


      QToolTip::add( defaultbutton, QString("Startet " + elements[i].get_name() + " " +
					  elements[i].image_history[n].get_version() +
					  " unsynchronisiert") );

      defaultactionlabel->setPixmap( QPixmap(":/icons/start-22x22.png" ) );
      defaultbutton->setEnabled( elements[i].image_history[n].get_startbutton() );
    }
    
    defaultbutton->setTextBrowser( config.get_consolefontcolorstdout(),
				   config.get_consolefontcolorstderr(),
				   Console );

    defaultbutton->setMainApp( (QDialog*)this );
    defaultbutton->setCommand( command );
    defaultbutton->setMainApp( this );

    // assign button to button list
    p_buttons.push_back( defaultbutton );
    buttons_config.push_back( 1 );
    // startView->addChild( defaultbutton, (90 + horizontalOffset), (height + innerVerticalOffset) );

    linbopushbutton *syncbutton = new linbopushbutton( startView->viewport() );
    syncbutton->setGeometry( QRect( (90 + horizontalOffset), (height + innerVerticalOffset), 32, 32 ) );
    // syncbutton->setText( QString("Sync+Start") );
    syncbutton->setTextBrowser( config.get_consolefontcolorstdout(),
				config.get_consolefontcolorstderr(),
				Console );

    // add tooltip and icon
    QToolTip::add( syncbutton, QString("Startet " + elements[i].get_name() + " " +
                                       elements[i].image_history[n].get_version() +
                                       " synchronisiert") );

    if( withicons ) {
      syncbutton->setIconSet( QIcon(":/icons/sync+start-22x22.png" ) );
      syncbutton->setIconSize( QSize(32,32) );
    }

    // assign command
    command = mksyncstartcommand(config, elements[i],elements[i].image_history[n]);
    syncbutton->setCommand( command );
    syncbutton->setMainApp( this );
    syncbutton->setEnabled( elements[i].image_history[n].get_syncbutton() );

    // assign button to button list
    p_buttons.push_back( syncbutton );
    buttons_config.push_back( elements[i].image_history[n].get_syncbutton() );
    startView->addChild( syncbutton, (90 + horizontalOffset), (height + innerVerticalOffset) );

    // Start Tab
    linbopushbutton *startbutton = new linbopushbutton( startView->viewport() );
    startbutton->setGeometry( QRect( (124 + horizontalOffset), (height  + innerVerticalOffset), 32, 32 ) );
    // startbutton->setText( QString("Start") );
    startbutton->setTextBrowser( config.get_consolefontcolorstdout(),
				 config.get_consolefontcolorstderr(),
				 Console );
         
    // add tooltip and icon
    QToolTip::add( startbutton, QString("Startet " + elements[i].get_name() + " " +
                                        elements[i].image_history[n].get_version() +
                                        " unsynchronisiert") );

    if( withicons ) {
      startbutton->setIconSet( QIcon(":/icons/start-22x22.png" ) );
      startbutton->setIconSize( QSize(32,32) );
    }

    // build "start" command
    command = LINBO_CMD("start");
    saveappend( command, elements[i].get_boot() );
    saveappend( command, elements[i].get_root() );
    saveappend( command, elements[i].image_history[n].get_kernel() );
    saveappend( command, elements[i].image_history[n].get_initrd() );
    saveappend( command, elements[i].image_history[n].get_append() );
    saveappend( command, config.get_cache() );
     
    startbutton->setCommand( command );
    startbutton->setMainApp( this );
    startbutton->setEnabled( elements[i].image_history[n].get_startbutton() );

    // assign button to button list
    p_buttons.push_back( startbutton );
    buttons_config.push_back( elements[i].image_history[n].get_startbutton() );
    startView->addChild( startbutton, (124 + horizontalOffset), (height  + innerVerticalOffset) );

    // Imaging Tab
    linbopushbutton *createbutton = new linbopushbutton( imagingView->viewport() ); 
    createbutton->setGeometry( QRect( 150, imagingHeight, 120, 30 ) );
    createbutton->setText( QString("Image erstellen") );
    createbutton->setTextBrowser( config.get_consolefontcolorstdout(),
				  config.get_consolefontcolorstderr(),
				  Console );

    linboImageSelectorImpl *buildImageSelector = new linboImageSelectorImpl( createbutton );
    // clear list
    buildImageSelector->listBox->clear();

    // incremental image - when assigned
    if( !(elements[i].image_history[n].get_image().stripWhiteSpace()).isEmpty() ) 
      buildImageSelector->listBox->insertItem(elements[i].image_history[n].get_image());

    // fill list with images
    // base image
    buildImageSelector->listBox->insertItem(elements[i].get_baseimage());

    // entry for creating a new image
    buildImageSelector->listBox->insertItem( QString("[Neuer Dateiname]") );

   
    buildImageSelector->setTextBrowser( config.get_consolefontcolorstdout(),
					config.get_consolefontcolorstderr(),
					Console );
    buildImageSelector->setCache( config.get_cache() );
    buildImageSelector->setBaseImage( elements[i].get_baseimage()  );
    buildImageSelector->setMainApp( this ); 

    command = LINBO_CMD("readfile");
    saveappend( command, config.get_cache() );
    saveappend( command, elements[i].get_baseimage() + QString(".desc") );
    saveappend( command, ( QString("/tmp/") + elements[i].get_baseimage() + QString(".desc") ) );
    buildImageSelector->setLoadCommand( command );

    command = LINBO_CMD("writefile");
    saveappend( command, config.get_cache() );
    saveappend( command, ( elements[i].get_baseimage() + QString(".desc") ) );
    saveappend( command, ( QString("/tmp/") + elements[i].get_baseimage() + QString(".desc") ) );
    buildImageSelector->setSaveCommand( command );

    createbutton->setLinboDialog( (linboDialog*)(buildImageSelector) );
    createbutton->setQDialog( (QDialog*)(buildImageSelector) );
    createbutton->setProgress( false );
    createbutton->setEnabled( true );
    createbutton->setMainApp((QDialog*)this );

    // add tooltip and icon
     QToolTip::add( createbutton, QString("Ein neues Image für " + elements[i].get_name() + " " +
                                          elements[i].image_history[n].get_version() +
                                          " erstellen") ); 

     if( withicons ) {
      createbutton->setIconSet( QIcon( ":/icons/image-22x22.png" ) );
      createbutton->setIconSize( QSize(32,32) );
     }
    

    // build "create" command
    command = LINBO_CMD("create");
    saveappend( command, config.get_cache() );

    saveappend( command, (elements[i].image_history[n].get_image()) );
    saveappend( command, (elements[i].get_baseimage()) );
    saveappend( command, (elements[i].get_boot()) );
    saveappend( command, (elements[i].get_root()) );
    saveappend( command, (elements[i].image_history[n].get_kernel()) );
    saveappend( command, (elements[i].image_history[n].get_initrd()) );
    buildImageSelector->setCommand( command );

    // this is done really late now to prevent segfaulting our main app (because
    // commands are not set earlier)
    buildImageSelector->listBox->setSelected(0,true);

    // assign button to button list
    p_buttons.push_back( createbutton );
    buttons_config.push_back( 1 );
    imagingView->addChild( createbutton, 150, imagingHeight );

    // Start Tab
    linbopushbutton *newbutton = new linbopushbutton( startView->viewport() );
    newbutton->setGeometry( QRect( (158 + horizontalOffset), (height + innerVerticalOffset), 32, 32 ) );
    // newbutton->setText( QString("Neu+Start") );
    newbutton->setTextBrowser( config.get_consolefontcolorstdout(),
			       config.get_consolefontcolorstderr(),
			       Console );

    // add tooltip and icon
    QToolTip::add( newbutton, QString("Installiert " + elements[i].get_name() + " " +
                                      elements[i].image_history[n].get_version() +
                                      " neu und startet es") );

    if( withicons ) {
      newbutton->setIconSet( QIcon( ":/icons/new+start-22x22.png" ) );
      newbutton->setIconSize( QSize(32,32) );
    }
   

    // assign command
    command = mksyncrcommand(config, elements[i],elements[i].image_history[n]);
    newbutton->setCommand( command );
    newbutton->setMainApp((QDialog*)this );
    newbutton->setEnabled( elements[i].image_history[n].get_newbutton() );

    // assign button to button list
    p_buttons.push_back( newbutton );
    buttons_config.push_back( elements[i].image_history[n].get_newbutton() );
    startView->addChild( newbutton, (158 + horizontalOffset), (height + innerVerticalOffset) );

    linbopushbutton *infobuttonstart = new linbopushbutton( startView->viewport() );
    infobuttonstart->setGeometry( QRect( (192 + horizontalOffset), (height + innerVerticalOffset), 32, 32 ) );
    // infobuttonstart->setText( QString("Info") );
    infobuttonstart->setEnabled( true );
    infobuttonstart->setTextBrowser( config.get_consolefontcolorstdout(),
				     config.get_consolefontcolorstderr(),
				     Console );    

    // add tooltip and icon
    QToolTip::add( infobuttonstart, QString("Informationen zu " + elements[i].get_name() + " " +
                                       elements[i].image_history[n].get_version()) );

    if( withicons ) {
      infobuttonstart->setIconSet( QIcon( ":/icons/information-22x22.png" ) );
      infobuttonstart->setIconSize( QSize(32,32) );
    }

    linboInfoBrowserImpl *infoBrowser = new linboInfoBrowserImpl( infobuttonstart );
    infoBrowser->setTextBrowser( config.get_consolefontcolorstdout(),
				 config.get_consolefontcolorstderr(),
				 Console );    
    infoBrowser->setMainApp( this );
    infoBrowser->setFilePath( QString("/tmp/") + elements[i].get_baseimage() + QString(".desc") );

    command = LINBO_CMD("readfile");
    saveappend( command, config.get_cache() );
    saveappend( command, ( elements[i].get_baseimage() + QString(".desc") ) );
    saveappend( command, ( QString("/tmp/") + elements[i].get_baseimage() + QString(".desc") ) );
    infoBrowser->setLoadCommand( command );
   
    command = LINBO_CMD("writefile");
    saveappend( command, config.get_cache() );
    saveappend( command, ( elements[i].get_baseimage() + QString(".desc") ) );
    saveappend( command, ( QString("/tmp/") + elements[i].get_baseimage() + QString(".desc") ) );
    infoBrowser->setSaveCommand( command );

    command = LINBO_CMD("upload");
    saveappend( command, config.get_server() );
    saveappend( command, QString("linbo") );
    saveappend( command, QString("password") );
    saveappend( command, config.get_cache() );
    saveappend( command, ( elements[i].get_baseimage() + QString(".desc") ) );
    infoBrowser->setUploadCommand( command );
    
    infobuttonstart->setProgress( false );
    infobuttonstart->setMainApp((QDialog*)this );
    infobuttonstart->setLinboDialog( (linboDialog*)(infoBrowser) );
    infobuttonstart->setQDialog( (QDialog*)(infoBrowser) );

    // assign button to button list
    p_buttons.push_back( infobuttonstart );
    buttons_config.push_back( 1 );
    startView->addChild( infobuttonstart, (192 + horizontalOffset), (height + innerVerticalOffset) );

    // Imaging Tab
    linbopushbutton *uploadbutton = new linbopushbutton( imagingView->viewport() );
    uploadbutton->setGeometry( QRect( 270, imagingHeight, 120, 30 ) );
    uploadbutton->setText( QString("Image hochladen") );
    uploadbutton->setEnabled( true );
    uploadbutton->setTextBrowser( config.get_consolefontcolorstdout(),
				  config.get_consolefontcolorstderr(),
				  Console );

    // add tooltip and icon
    QToolTip::add( uploadbutton, QString("Ein Image für " + elements[i].get_name() + " " +
                                       elements[i].image_history[n].get_version() + 
                                         " auf den Server hochladen" ) );

    if( withicons )
      uploadbutton->setIconSet( QIcon( ":/icons/upload-22x22.png" ) );

    linboImageUploadImpl *imageUpload = new linboImageUploadImpl( uploadbutton);
    imageUpload->setTextBrowser( config.get_consolefontcolorstdout(),
				 config.get_consolefontcolorstderr(),
				 Console );
    imageUpload->setMainApp( this );

    // clear list
    imageUpload->listBox->clear();
    // fill list with images

    // incremental image - when assigned
    if( !(elements[i].image_history[n].get_image().stripWhiteSpace()).isEmpty() ) 
      imageUpload->listBox->insertItem(elements[i].image_history[n].get_image());

    // base image
    imageUpload->listBox->insertItem(elements[i].get_baseimage());

    command = LINBO_CMD("upload");
    saveappend( command, config.get_server() );
    saveappend( command, QString("linbo") );
    saveappend( command, QString("password") );
    saveappend( command, config.get_cache() );
    if( (elements[i].image_history[n].get_image().stripWhiteSpace()).isEmpty() ) {
      saveappend( command, elements[i].get_baseimage() );
    } else {
      saveappend( command, elements[i].image_history[n].get_image() );
    }
    imageUpload->setCommand( command );

    uploadbutton->setMainApp((QDialog*)this );
    uploadbutton->setLinboDialog( (linboDialog*)(imageUpload) );
    uploadbutton->setQDialog( (QDialog*)(imageUpload) );
    uploadbutton->setProgress( false );

    // assign button to button list
    p_buttons.push_back( uploadbutton );
    buttons_config.push_back( 1 );
    imagingView->addChild( uploadbutton, 270, imagingHeight );

    // where is my homie?
    createbutton->setNeighbour( uploadbutton );
    uploadbutton->setNeighbour( createbutton );



    // only for an odd element
    if( i % 2 == 1 ) {
      height += 69;
    }

    // the height of 69 is one complete element row, 5 is our start height
    startView->resizeContents( 600, ( (int)((i+2)/2) * 69 + 5 ) );  

    imagingHeight += 32;

    int height2 = 5;

    // check: if one of the history entries is declared hidden,
    // hide the complete tab
    bool isHidden = false;

    for( unsigned int n = 0; n < elements[i].image_history.size(); n++ ) {
      isHidden |=  elements[i].image_history[n].get_hidden();
    }

    // check whether our per-OS tabs should be displayed or not
    // we save a lot of memory by not building these elements
    if ( !isHidden ) {
      QWidget* newtab = new QWidget( Tabs );
      Q3ScrollView* view = new Q3ScrollView( newtab );

      view->setHScrollBarMode(Q3ScrollView::AlwaysOff);
      view->setVScrollBarMode(Q3ScrollView::Auto);
      view->viewport()->setBackgroundColor( "white" );
      view->setGeometry( QRect( 10, 10, 600, 180 ) );

      int iHorizontalOffset = 0;

      for( unsigned int n = 0; n < elements[i].image_history.size(); n++ ) {

        // QT BUG!
        if ( n == 0 ) {
          height2 = 14;
        }

	if( n % 2 == 1 ) {
	  // an odd element is moved to the right
	  iHorizontalOffset = 300;
	} else {
	  iHorizontalOffset = 0;
	}
        QLabel *imagename = new QLabel( view->viewport() );
        imagename->setGeometry( QRect( (90 + iHorizontalOffset), height2, 180, 30 ) );
        imagename->setText( elements[i].image_history[n].get_version() + ";" + elements[i].image_history[n].get_description() );
        view->addChild( imagename, (90 + iHorizontalOffset), height2 );
        if ( n == 0 ) {
          height2 = 5;
        }

	/*        QLabel *imagetext = new QLabel( view->viewport() );
		  imagetext->setGeometry( QRect( 120, height2, 260, 30 ) );
		  imagetext->setText( elements[i].image_history[n].get_description() );
		  view->addChild( imagetext, 120, height2 );
	*/

	linbopushbutton *idefaultbutton = new linbopushbutton( view->viewport() );
	idefaultbutton->setGeometry( QRect( (15 + iHorizontalOffset), height2, 64, 64 ) );

	QLabel *idefaultactionlabel = new QLabel( startView->viewport() );
	idefaultactionlabel->setGeometry( QRect( (15 + iHorizontalOffset), height2+42, 22, 22 ) );


	if( withicons ) {
	  if( elements[i].get_iconname() == "defaulticon.png" ) {
	    // TODO: choose another default icon - something that looks like the LINBO-Logo
	    idefaultbutton->setIconSet( QIcon(":/icons/default.png" ) );
	  } else {
	    idefaultbutton->setIconSet( QIcon(  QString("/icons/") + elements[i].get_iconname() ) );
	  }
	  idefaultbutton->setIconSize( QSize(64,64) );
	}

	if( elements[i].image_history[n].get_defaultaction() == "sync") {
	  // assign command
	  command = mksyncstartcommand(config, elements[i],elements[i].image_history[n]);
	  QToolTip::add( idefaultbutton, QString("Startet " + elements[i].get_name() + " " +
						elements[i].image_history[n].get_version() +
						" synchronisiert") );
	  
	  idefaultactionlabel->setPixmap( QPixmap(":/icons/sync+start-22x22.png" ) );
	} 
	if( elements[i].image_history[n].get_defaultaction() == "new" ) {
	  // assign command
	  command = mksyncrcommand(config, elements[i],elements[i].image_history[n]);
	  QToolTip::add( idefaultbutton, QString("Installiert " + elements[i].get_name() + " " +
						elements[i].image_history[n].get_version() +
						" neu und startet es") );

	  defaultactionlabel->setPixmap( QPixmap(":/icons/new+start-22x22.png" )  );
	}
	if( elements[i].image_history[n].get_defaultaction() == "start" ) {
	  // assign command
	  command = LINBO_CMD("start");
	  saveappend( command, elements[i].get_boot() );
	  saveappend( command, elements[i].get_root() );
	  saveappend( command, elements[i].image_history[n].get_kernel() );
	  saveappend( command, elements[i].image_history[n].get_initrd() );
	  saveappend( command, elements[i].image_history[n].get_append() );
	  saveappend( command, config.get_cache() );
	  
	  
	  QToolTip::add( idefaultbutton, QString("Startet " + elements[i].get_name() + " " +
						elements[i].image_history[n].get_version() +
						" unsynchronisiert") );

	  defaultactionlabel->setPixmap( QPixmap(":/icons/start-22x22.png" ) );
	}
	
	idefaultbutton->setCommand( command );
	idefaultbutton->setTextBrowser( config.get_consolefontcolorstdout(),
					config.get_consolefontcolorstderr(),
					Console );
	idefaultbutton->setMainApp( (QDialog*)this );
	p_buttons.push_back( idefaultbutton );
        buttons_config.push_back( 1 );

        linbopushbutton *isyncbutton = new linbopushbutton( view->viewport() );
        isyncbutton->setGeometry( QRect( (90 + iHorizontalOffset), (height2 + innerVerticalOffset), 32, 32 ) );
        // isyncbutton->setText( QString("Sync+Start") );
        isyncbutton->setTextBrowser( config.get_consolefontcolorstdout(),
				     config.get_consolefontcolorstderr(),
				     Console );    
        isyncbutton->setEnabled( true );

        // add tooltip and icon
        QToolTip::add( isyncbutton, QString("Startet " + elements[i].get_name() + " " +
                                            elements[i].image_history[n].get_version() +
                                            " synchronisiert") );

        if( withicons ) {
          isyncbutton->setIconSet( QIcon( ":/icons/sync+start-22x22.png" ) );
	  isyncbutton->setIconSize( QSize(32,32) );
	}

        command = mksyncstartcommand(config, elements[i],elements[i].image_history[n]);
        isyncbutton->setCommand( command );
        isyncbutton->setMainApp((QDialog*)this );

        // assign button to button list
        p_buttons.push_back( isyncbutton );
        buttons_config.push_back( 1 );
        view->addChild( isyncbutton, (90 + iHorizontalOffset), (height2 + innerVerticalOffset) );

        linbopushbutton *irecreatebutton = new linbopushbutton( view->viewport() );
        irecreatebutton->setGeometry( QRect( (124 + iHorizontalOffset), (height2 + innerVerticalOffset), 32, 32 ) );
        // irecreatebutton->setText( QString("Neu+Start") );
        irecreatebutton->setTextBrowser( config.get_consolefontcolorstdout(),
					 config.get_consolefontcolorstderr(),
					 Console );
      
        command = mksyncrcommand(config, elements[i],elements[i].image_history[n]);
        irecreatebutton->setCommand( command );
        irecreatebutton->setEnabled( true );
      
        // add tooltip and icon
        QToolTip::add( irecreatebutton, QString("Installiert " + elements[i].get_name() + " " +
                                                elements[i].image_history[n].get_version() +
                                                " neu und startet es") );

        if( withicons ) {
          irecreatebutton->setIconSet( QIcon( ":/icons/new+start-22x22.png" ) );
	  irecreatebutton->setIconSize( QSize(32,32) );
	}

        irecreatebutton->setMainApp(this );
        // assign button to button list
        p_buttons.push_back( irecreatebutton );
        buttons_config.push_back( 1 );
        view->addChild( irecreatebutton, (124 + iHorizontalOffset), (height2 + innerVerticalOffset) );

        linbopushbutton *iinfobuttonstart = new linbopushbutton( view->viewport() );
        iinfobuttonstart->setGeometry( QRect( (158 + iHorizontalOffset), (height2 + innerVerticalOffset), 32, 32 ) );
	// iinfobuttonstart->setText( QString("Info") );
        iinfobuttonstart->setEnabled( true );
        iinfobuttonstart->setTextBrowser( config.get_consolefontcolorstdout(),
					  config.get_consolefontcolorstderr(),
					  Console );    

        linboInfoBrowserImpl *iinfoBrowser = new linboInfoBrowserImpl( iinfobuttonstart );
        iinfoBrowser->setTextBrowser(  config.get_consolefontcolorstdout(),
				       config.get_consolefontcolorstderr(),
				       Console );
        iinfoBrowser->setMainApp(this);
        iinfoBrowser->setFilePath( QString("/tmp/") + elements[i].get_baseimage() + QString(".desc") );
        iinfobuttonstart->setProgress( false );
        iinfobuttonstart->setMainApp(this );

        command = LINBO_CMD("readfile");
        saveappend( command, config.get_cache() );
        saveappend( command, ( elements[i].get_baseimage() + QString(".desc") ) );
        saveappend( command, ( QString("/tmp/") + elements[i].get_baseimage() + QString(".desc") ) );
        iinfoBrowser->setLoadCommand( command );

        command = LINBO_CMD("writefile");
        saveappend( command, config.get_cache() );
        saveappend( command, ( elements[i].get_baseimage() + QString(".desc") ) );
        saveappend( command, ( QString("/tmp/") + elements[i].get_baseimage() + QString(".desc") ) );
        iinfoBrowser->setSaveCommand( command );

        command = LINBO_CMD("upload");
        saveappend( command, config.get_server() );
        saveappend( command, QString("linbo") );
        saveappend( command, QString("password") );
        saveappend( command, config.get_cache() );
        saveappend( command, ( QString("/tmp/") + elements[i].get_baseimage() + QString(".desc") ) );
        iinfoBrowser->setUploadCommand( command );

        iinfobuttonstart->setLinboDialog( (linboDialog*)(infoBrowser) );
        iinfobuttonstart->setQDialog( (QDialog*)(infoBrowser) );

        // add tooltip and icon
        QToolTip::add( iinfobuttonstart, QString("Informationen zu " + elements[i].get_name() + " " +
                                                 elements[i].image_history[n].get_version()) );

        if( withicons ) {
          iinfobuttonstart->setIconSet( QIcon( ":/icons/information-22x22.png" ) );
	  iinfobuttonstart->setIconSize(QSize(32,32));
	}

        // assign button to button list
        p_buttons.push_back( iinfobuttonstart );
        buttons_config.push_back( 1 );
        view->addChild( iinfobuttonstart, (158 + iHorizontalOffset), (height2 + innerVerticalOffset) );

        if( elements[i].image_history[n].get_autostart() &&
            !autostart ) {
	  

          logConsole->writeStdOut( QString("Autostart selected for OS Nr. ")
                                   + QString::number(i) 
                                   + QString(", Image History Nr. ") 
         			   + QString::number( n ));

	  autostart = idefaultbutton;
	  autostarttimeout = elements[i].image_history[n].get_autostarttimeout();
        }



	if( n % 2 == 1 ) {
	  height2 += 69;
	}
	// the height of 69 is one complete element row
	view->resizeContents( 600, ( (int)((n+2)/2) * 69 + 5 ) );  
      }
      Tabs->insertTab( newtab, elements[i].get_name(), (nextPosForTabInsert+1) );
      nextPosForTabInsert++;
    } else {
      // in case one of the elements is marked as "Autostart", we have to create the
      // matching, invisible sync+start button
    
      for( unsigned int n = 0; n < elements[i].image_history.size(); n++ ) {

        if( elements[i].image_history[n].get_autostart() &&
            !autostart ) {

          logConsole->writeStdOut( QString("Autostart selected for OS Nr. ") 
                                   + QString::number(i) 
                                   + QString(", Image History Nr. ") 
			           + QString::number( n ) );

          autostart = defaultbutton; 
	  autostarttimeout = elements[i].image_history[n].get_autostarttimeout();
        }
      }
    }

  }  

  imagingView->resizeContents( 410, imagingHeight );

  // the first element of a view does have display problems so we add a dummy
  QLabel *partitionlabel = new QLabel( partitionView->viewport() );
  partitionlabel->setGeometry( QRect( 5, 5, 165, 30 ) );
  partitionlabel->setText("");
  partitionView->addChild( partitionlabel, 5,5 );

  linbopushbutton *consolebuttonimaging = new linbopushbutton( partitionView->viewport() );
  // left-align graphics and text
  consolebuttonimaging->setStyleSheet("QPushButton{text-align : left; padding-left: 5px;}");
  consolebuttonimaging->setGeometry( QRect( 15, 27, 130, 30 ) );
  consolebuttonimaging->setText( QString("Console") );
  consolebuttonimaging->setTextBrowser( config.get_consolefontcolorstdout(),
					config.get_consolefontcolorstderr(),
					Console );

  linboConsoleImpl *linboconsole = new linboConsoleImpl( consolebuttonimaging );
  linboconsole->setMainApp(this );
  linboconsole->setTextBrowser( config.get_consolefontcolorstdout(),
				config.get_consolefontcolorstderr(),
				Console ); 

  consolebuttonimaging->setProgress( false );
  consolebuttonimaging->setMainApp(this );
  consolebuttonimaging->setLinboDialog( (linboDialog*)(linboconsole) );
  consolebuttonimaging->setQDialog( (QDialog*)(linboconsole) );

  // add tooltip and icon
  QToolTip::add( consolebuttonimaging, QString("Öffnet das Konsolenfenster") );

  if( withicons )
    consolebuttonimaging->setIconSet( QIcon( ":/icons/console-22x22.png" ) );
  
  // assign button to button list
  p_buttons.push_back( consolebuttonimaging );
  buttons_config.push_back( 1 );
  partitionView->addChild( consolebuttonimaging, 15, 27 );
  
  linbopushbutton *multicastbuttonimaging = new linbopushbutton( partitionView->viewport() );
  // left-align graphics and text
  multicastbuttonimaging->setStyleSheet("QPushButton{text-align : left; padding-left: 5px;}");
  multicastbuttonimaging->setGeometry( QRect( 15, 59, 130, 30 ) );
  multicastbuttonimaging->setText( QString("Cache aktualisieren") );
  multicastbuttonimaging->setTextBrowser( config.get_consolefontcolorstdout(),
					  config.get_consolefontcolorstderr(),
					  Console );

  // add tooltip and icon
  QToolTip::add( multicastbuttonimaging, QString("Aktualisiert den lokalen Cache") );

  if( withicons )
    multicastbuttonimaging->setIconSet( QIcon( ":/icons/cache-22x22.png" ) );

  linboMulticastBoxImpl *multicastbox = new linboMulticastBoxImpl( multicastbuttonimaging ); 
  multicastbox->setMainApp(this );
  multicastbox->setTextBrowser( config.get_consolefontcolorstdout(),
				config.get_consolefontcolorstderr(),
				Console );

  multicastbox->setRsyncCommand( mkcacheinitcommand( config, elements, QString("rsync")) );
  multicastbox->setMulticastCommand( mkcacheinitcommand( config, elements, QString("multicast")) );
  multicastbox->setBittorrentCommand( mkcacheinitcommand( config, elements, QString("torrent")) );

  multicastbuttonimaging->setProgress( false );
  multicastbuttonimaging->setMainApp(this );
  multicastbuttonimaging->setLinboDialog( (linboDialog*)(multicastbox) );
  multicastbuttonimaging->setQDialog( (QDialog*)(multicastbox) );

  autoinitcache = 0;
  // this button MUSTN't have a parent, otherwise we get a artifact button
  // inside the imaging tab 
  linbopushbutton *autoinitcachebutton = new linbopushbutton(0); 
  // this invisible button is needed für autoinitcache
  if( config.get_autoinitcache() ) {
    autoinitcachebutton->setTextBrowser( config.get_consolefontcolorstdout(),
					 config.get_consolefontcolorstderr(),
					 Console );
    autoinitcachebutton->setMainApp(this );
    autoinitcachebutton->setProgress( true );
    autoinitcachebutton->setCommand( mkcacheinitcommand( config, elements, config.get_downloadtype() ) );
    autoinitcache = autoinitcachebutton;
    autoinitcachebutton->hide();
  }

  // assign button to button list
  p_buttons.push_back( multicastbuttonimaging );
  buttons_config.push_back( 1 );
  partitionView->addChild( multicastbuttonimaging, 15, 59 );

  // Partition button - Imaging tab
  linbopushbutton *partitionbutton = new linbopushbutton( partitionView->viewport() );
  // left-align graphics and text
  partitionbutton->setStyleSheet("QPushButton{text-align : left; padding-left: 5px;}");
  partitionbutton->setGeometry( QRect( 15, 91, 130, 30 ) );
  partitionbutton->setText( QString("Partitionieren") );
  partitionbutton->setTextBrowser( config.get_consolefontcolorstdout(),
				   config.get_consolefontcolorstderr(),
				   Console );
  partitionbutton->setMainApp(this );
  partitionbutton->setEnabled( true );

  // add tooltip and icon
  QToolTip::add( partitionbutton, QString("Partitioniert die Festplatte neu") );

  if( withicons )
    partitionbutton->setIconSet( QIcon( ":/icons/partition-22x22.png" ) );

  linboYesNoImpl *yesNoPartition = new linboYesNoImpl( partitionbutton);
  yesNoPartition->question->setText("Alle Daten auf der Festplatte löschen?");
  yesNoPartition->setTextBrowser( config.get_consolefontcolorstdout(),
				  config.get_consolefontcolorstderr(),
				  Console );
  yesNoPartition->setMainApp(this );
  yesNoPartition->setCommand(mkpartitioncommand(partitions));

  autopartition = 0;
  linbopushbutton *autopartitionbutton = new linbopushbutton();
  // this invisible button is needed für autopartition
  if( config.get_autopartition() ) {
    autopartitionbutton->setTextBrowser( config.get_consolefontcolorstdout(),
					 config.get_consolefontcolorstderr(),
					 Console );
    autopartitionbutton->setMainApp(this );
    autopartitionbutton->setProgress( true );
    // here we set whether a partition should be automatically formatted after
    // the partition table has been overwritten
    if( config.get_autoformat() )
      autopartitionbutton->setCommand(mkpartitioncommand(partitions));
    else
      autopartitionbutton->setCommand(mkpartitioncommand_noformat(partitions));
    autopartition = autopartitionbutton;
    autopartitionbutton->setHidden( true );
  }

  partitionbutton->setProgress( false );

  partitionbutton->setLinboDialog( (linboDialog*)(yesNoPartition) );
  partitionbutton->setQDialog( (QDialog*)(yesNoPartition) );
  
  
  partitionView->addChild( partitionbutton, 15, 91 );

  // assign button to button list
  p_buttons.push_back( partitionbutton );
  buttons_config.push_back( 1 );

  // RegisterBox button - Imaging tab
  linbopushbutton *registerbutton = new linbopushbutton( partitionView->viewport() );
  // left-align graphics and text
  registerbutton->setStyleSheet("QPushButton{text-align : left; padding-left: 5px;}");
  registerbutton->setGeometry( QRect( 15, 123, 130, 30 ) );
  registerbutton->setText( QString("Registrieren") );
  registerbutton->setTextBrowser( config.get_consolefontcolorstdout(),
				  config.get_consolefontcolorstderr(),
				  Console );
  registerbutton->setMainApp(this );
  registerbutton->setEnabled( true );

  // add tooltip and icon
  QToolTip::add( registerbutton, QString("Öffnet den Registrierungsdialog zur Aufnahme neuer Rechner") );

  if( withicons )
    registerbutton->setIconSet( QIcon(  ":/icons/register-22x22.png") );

  
  linboRegisterBoxImpl *registerBox = new linboRegisterBoxImpl( registerbutton );
  registerBox->setTextBrowser( config.get_consolefontcolorstdout(),
			       config.get_consolefontcolorstderr(),
			       Console );
  registerBox->setMainApp(this );

  command = LINBO_CMD("register");
  saveappend( command, config.get_server() );
  saveappend( command, QString("linbo") );
  saveappend( command, QString("password") );
  saveappend( command, QString("clientRoom") );
  saveappend( command, QString("clientName") );
  saveappend( command, QString("clientIP") );
  saveappend( command, QString("clientGroup") ); 

  registerBox->setCommand( command );

  registerbutton->setProgress( false );

  registerbutton->setLinboDialog( (linboDialog*)(registerBox) );
  registerbutton->setQDialog( (QDialog*)(registerBox) );

  partitionView->addChild( registerbutton, 15, 123 );

  // assign button to button list
  p_buttons.push_back( registerbutton );
  buttons_config.push_back( 1 );

  buttons_config_save.clear();
  for( unsigned int i = 0; i < p_buttons.size(); i++ ) {
    buttons_config_save.push_back( p_buttons[i]->isEnabled() );
  }

  myLPasswordBox = new linboPasswordBoxImpl( this );
  myQPasswordBox = (QDialog*)(myLPasswordBox);
  myLPasswordBox->setMainApp(this );
  myLPasswordBox->setTextBrowser( config.get_consolefontcolorstdout(),
				  config.get_consolefontcolorstderr(),
				  Console );


  // Code for detecting tab changes
  connect( Tabs, SIGNAL(currentChanged( QWidget* )), 
           this, SLOT(tabWatcher( QWidget* )) );

  // create process for our status bar

  process = new QProcess( this );
  /*  connect( process, SIGNAL(readyReadStandardOutput()),
           this, SLOT(readFromStdout()) );
  connect( process, SIGNAL(readyReadStandardError()),
           this, SLOT(readFromStderr()) );
  */

  // we don't want to see this on the LINBO Console
  outputvisible = false;

  // set backgroundtext color
  fonttemplate = tr("<font color='%1'>%2</font>");

  //  client ip
  command = LINBO_CMD("ip");
  // myprocess->setArguments( command );
  process->start( command.join(" ") );
  while( !process->waitForFinished(10000) ) {
  }

  clientIPLabel->setText( fonttemplate.arg( config.get_backgroundfontcolor(), QString("Client IP: ") + process->readAllStandardOutput() ) ); 

  //  server ip
 
  // serverIPLabel->setText( QString("   Server IP: ") + config.get_server() ); 

  // mac address
  command.clear();
  command = LINBO_CMD("mac");
  
  process->start( command.join(" ") );
  while( !process->waitForFinished(10000) ) {
  }
  macLabel->setText( fonttemplate.arg( config.get_backgroundfontcolor(), QString("MAC: ") + process->readAllStandardOutput() ) ); 
  
  // Server and Version
// hostname and hostgroup 

  command = LINBO_CMD("version");
  // myprocess->setArguments( command );
  process->start( command.join(" ") );
  while( !process->waitForFinished(10000) ) {
  }
 
  versionLabel->setText( (process->readAllStandardOutput()).stripWhiteSpace() + QString(" auf Server ") + config.get_server());

  // hostname and hostgroup 

  command = LINBO_CMD("hostname");
  // myprocess->setArguments( command );
  process->start( command.join(" ") );
  while( !process->waitForFinished(10000) ) {
  }
 


  nameLabel->setText( fonttemplate.arg( config.get_backgroundfontcolor(), QString("Host: ") + process->readAllStandardOutput() ) );
  groupLabel->setText( fonttemplate.arg( config.get_backgroundfontcolor(), QString("Gruppe: ") + config.get_hostgroup() ) );
  
  // our clock displaying the system time
  myTimer = new QTimer(this);
  connect( myTimer, SIGNAL(timeout()), this, SLOT(processTimeout()) );
  myTimer->start( 1000, FALSE );

  // CPU 
  command = LINBO_CMD("cpu");
  // myprocess->setArguments( command );
  process->start( command.join(" ") );
  while( !process->waitForFinished(10000) ) {
  }

  cpuLabel->setText( fonttemplate.arg( config.get_backgroundfontcolor(), QString("CPU: ") + process->readAllStandardOutput() ) ); 

  // Memory
  command = LINBO_CMD("memory");
  process->start( command.join(" ") );
  while( !process->waitForFinished(10000) ) {
  }

  memLabel->setText( fonttemplate.arg( config.get_backgroundfontcolor(), QString("RAM: ") + process->readAllStandardOutput() ) ); 

  // Cache Size
  command = LINBO_CMD("size");
  saveappend( command, config.get_cache() );
  process->start( command.join(" ") );
  while( !process->waitForFinished(10000) ) {
  }
  cacheLabel->setText( fonttemplate.arg( config.get_backgroundfontcolor(), QString("Cache: ") + process->readAllStandardOutput() ) );

  // Harddisk Size
  QRegExp *removePartition = new QRegExp("[0-9]{1,2}");
  QString hd = config.get_cache();
  hd.remove( *removePartition );

  command = LINBO_CMD("size");
  saveappend( command, hd );

  process->start( command.join(" ") );
  while( !process->waitForFinished(10000) ) {
  }

  hdLabel->setText( fonttemplate.arg( config.get_backgroundfontcolor(), QString("HD: ") + process->readAllStandardOutput() ) );

  // enable console output again
  outputvisible = true;

  // select start tab
  Tabs->setCurrentPage(0);

}



void linboGUIImpl::processTimeout() {
  
  timeLabel->setText( fonttemplate.arg( config.get_backgroundfontcolor(), QTime::currentTime().toString() ) );
}


void linboGUIImpl::shutdown() {
  QStringList command;
  command.clear();
  command = QStringList("busybox");
  command.append("poweroff");
  logConsole->writeStdOut( QString("shutdown entered") );
  process->start( command.join(" ") );
}

void linboGUIImpl::reboot() {
  QStringList command;
  command.clear();
  command = QStringList("busybox");
  command.append("reboot");
  logConsole->writeStdOut( QString("reboot entered") );
  process->start( command.join(" ") );
}


void linboGUIImpl::log( const QString& data ) {
  // write to our logfile
  QFile logfile( logfilepath  );
  logfile.open( QIODevice::WriteOnly | QIODevice::Append );
  Q3TextStream logstream( &logfile );
  logstream << data << "\n";
  logfile.flush();
  logfile.close();
}

void linboGUIImpl::readFromStdout()
{
  // TODO: reactivate log
  // log( linestdout );

  if( outputvisible ) {
    logConsole->writeStdOut( process->readAllStandardOutput() );
  } 
}

void linboGUIImpl::readFromStderr()
{
  // TODO: reactivate log
  // log( linestderr );
  
  if( outputvisible ) {

    logConsole->writeStdErr( process->readAllStandardError() );
  }

}


linboGUIImpl::~linboGUIImpl() 
{
  // nothing to do
}

void linboGUIImpl::enableButtons() {
  root = true;
  for( unsigned int i = 0; i < p_buttons.size(); i++ ) {
    if( buttons_config[i] == 2 ) 
      p_buttons[i]->setEnabled( false );
    else
      p_buttons[i]->setEnabled( true );
  }
}

void linboGUIImpl::resetButtons() {
  root = false;
  Tabs->setCurrentPage( preTab );
  for( unsigned int i = 0; i < p_buttons.size(); i++ ) {
    if( buttons_config[i] == 2 )
      p_buttons[i]->setEnabled( true );
    else
      p_buttons[i]->setEnabled( buttons_config[i] );

    buttons_config_save[i] = p_buttons[i]->isEnabled();
  }
}

void linboGUIImpl::executeAutostart() {
  
  // if there is "autopartition" set, execute the hidden button
  if( autopartition )
    autopartition->lclicked();

  // if there is "autoinitcache" set, execute the hidden button
  if( autoinitcache )
    autoinitcache->lclicked();

  // if there is a with "autostart" declared image, execute the hidden button
  if( autostart != 0 ) {
    if( autostarttimeout > 0 ) {

      myAutostartTimer = new QTimer(0);
      myAutostartTimer->stop();
      myAutostartTimer->start( 1000, FALSE ); 

      myCounter = new linboCounterImpl(this);
      myCounter->text->setText("Autostart in...");
      myCounter->logoutButton->setText("Autostart abbrechen");
      myCounter->counter->display( autostarttimeout );
      myCounter->timeoutCheck->hide();  

      // connect( myCounter->logoutButton, SIGNAL(pressed()), app, SLOT(resetButtons()) );
      connect( myCounter->logoutButton, SIGNAL(clicked()), myAutostartTimer, SLOT(stop()) );
      connect( myAutostartTimer, SIGNAL(timeout()), this, SLOT(autostartTimeoutSlot()) );
      
      myCounter->show();
      myCounter->raise();
      myCounter->move( QPoint( 5, 5 ) ); 
 
    } else {
      autostart->lclicked();
    }
  }
  
}

void linboGUIImpl::autostartTimeoutSlot() {
  if( !myCounter->timeoutCheck->isChecked() ) {
    // do nothing but dont stop timer
  } 
  else {
    if( autostarttimeout > 0 ) {
      autostarttimeout--;
      myCounter->counter->display( autostarttimeout );
    } else {
      myCounter->hide();
      myCounter->close();
      myAutostartTimer->stop();
      autostart->lclicked();
      this->resetButtons();
    }
  }


}

void linboGUIImpl::disableButtons() {
  for( unsigned int i = 0; i < p_buttons.size(); i++ ) {
    // save buttons state
    
    buttons_config_save[i] = p_buttons[i]->isEnabled();
    p_buttons[i]->setEnabled( false );
  }
}

void linboGUIImpl::restoreButtonsState() {
   for( unsigned int i = 0; i < p_buttons.size(); i++ ) {
     p_buttons[i]->setEnabled( buttons_config_save[i] );
   }
}

void linboGUIImpl::tabWatcher( QWidget* currentWidget) {
  
  if( !isRoot() ) {
    if( Tabs->tabLabel(currentWidget) == "Imaging" ) {
      // if our partition button is disabled, there is a linbo_cmd running
      if( p_buttons[ ( p_buttons.size() - 1 ) ]->isEnabled() ) {
        Tabs->setCurrentPage( preTab );      
        myQPasswordBox->show();
        myQPasswordBox->raise();
        myQPasswordBox->setActiveWindow();
        myQPasswordBox->setEnabled( true ); 
      }
      else {
        Tabs->setCurrentPage( preTab );
      }
    }
  }
  if( (Tabs->count() - 1) != Tabs->currentPageIndex()  )
    preTab = Tabs->currentPageIndex(); 
}

bool linboGUIImpl::isRoot() const {
  return root;
}

void linboGUIImpl::showImagingTab() {
  Tabs->setCurrentPage( (Tabs->count() - 1) );
}
