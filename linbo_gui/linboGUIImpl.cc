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
// #include <qicon.h>
#include <qpixmap.h>
#include <qimage.h>
#include <qregexp.h>
#include <stdlib.h>

// #include "image_description.hh"
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
const bool read_pair(ifstream* input, QString& key, QString& value) {
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

const bool toBool(const QString& value) {
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
    else if(key.compare("logopath") == 0)     tmp_os.set_logopath(value);
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
    else if(key.compare("autostart") == 0)   tmp_image.set_autostart(toBool(value));
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
    else if(key.compare("usemulticast") == 0) g.set_usemulticast(toBool(value));
    else if(key.compare("autoformat") == 0) g.set_autoformat(toBool(value));
  }
}

// Sync+start image
QStringList mksyncstartcommand(globals& config, os_item& os, image_item& im) {
  QStringList command = LINBO_CMD("syncstart");
  command.append(config.get_server());
  command.append(config.get_cache());
  command.append(os.get_baseimage());
  command.append(im.get_image());
  command.append(os.get_boot());
  command.append(os.get_root());
  command.append(im.get_kernel());
  command.append(im.get_initrd());
  command.append(im.get_append());
  return command;
}

// Sync image from cache
QStringList mksynccommand(globals& config, os_item& os, image_item& im) {
  QStringList command = LINBO_CMD("sync");
  command.append(config.get_cache());
  command.append(os.get_baseimage());
  command.append(im.get_image());
  command.append(os.get_boot());
  command.append(os.get_root());
  command.append(im.get_kernel());
  command.append(im.get_initrd());
  command.append(im.get_append());
  return command;
}

// Sync image from server
QStringList mksyncrcommand(globals& config, os_item& os, image_item& im) {
  QStringList command = LINBO_CMD("syncr");
  command.append(config.get_server());
  command.append(config.get_cache());
  command.append(os.get_baseimage());
  command.append(im.get_image());
  command.append(os.get_boot());
  command.append(os.get_root());
  command.append(im.get_kernel());
  command.append(im.get_initrd());
  command.append(im.get_append());
  command.append("force");
  return command;
}

QStringList mkpartitioncommand(vector <diskpartition> &p) {
  QStringList command = LINBO_CMD("partition");
  for(unsigned int i=0; i<p.size(); i++) {
    command.append(p[i].get_dev());
    command.append(QString::number(p[i].get_size()));
    command.append(p[i].get_id());
    command.append(QString((p[i].get_bootable())?"bootable":""));
    command.append(p[i].get_fstype());
  }
  return command;
}

QStringList mkpartitioncommand_noformat(vector <diskpartition> &p) {
  QStringList command = LINBO_CMD("partition_noformat");
  for(unsigned int i=0; i<p.size(); i++) {
    command.append(p[i].get_dev());
    command.append(QString::number(p[i].get_size()));
    command.append(p[i].get_id());
    command.append(QString((p[i].get_bootable())?"bootable":""));
    command.append(p[i].get_fstype());
  }
  return command;
}


QStringList mkcacheinitcommand(globals& config, vector<os_item> &os, bool multicast) {
  QStringList command = LINBO_CMD("initcache");
  command.append(config.get_server());
  command.append(config.get_cache());
  command.append(multicast?"multicast":"rsync");
  for(unsigned int i = 0; i < os.size(); i++) {
    command.append(os[i].get_baseimage());
    for(unsigned int j = 0; j < os[i].image_history.size(); j++) {
      command.append(os[i].image_history[j].get_image());
    }
  }
  return command;
}

QStringList mklinboupdatecommand(globals& config) {
  QStringList command = LINBO_CMD("update");
  command.append(config.get_server());
  command.append(config.get_cache());
  return command;
}



linboGUIImpl::linboGUIImpl( QWidget* parent,
                            const char* name,
                            bool modal,
                            Qt::WFlags fl )

{ 
 
  Ui_linboGUI::setupUi((QDialog*)this);
 
  QImage tmpImage;

  Qt::WindowFlags flags;
  flags = Qt::FramelessWindowHint;
  // flags = Qt::CustomizeWindowHint;
  setWindowFlags( flags );

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

  // first "last visited" tab is start tab
  preTab = 0;

  // logfilepath
  logfilepath = QString("/tmp/linbo.log");

  // connect our shutdown and reboot buttons
  connect( shutdownButton, SIGNAL(clicked()), this, SLOT(shutdown()) );
  connect( rebootButton, SIGNAL(clicked()), this, SLOT(reboot()) );

  // clear buttons array
  p_buttons.clear();
  buttons_config.clear();
  // hide the main GUI
  this->hide();

  linboMsgImpl *waiting = new linboMsgImpl(0);// this); //, "foo",0,Qt::WStyle_Customize | Qt::WStyle_NoBorder );
  waiting->message->setText("LINBO 2.00<br>Netzwerk Check");

  QStringList waitCommand = LINBO_CMD("ready");

  waiting->setWindowFlags( flags );
  waiting->setCommand( waitCommand );
  waiting->move(qRect.width()/2-waiting->width()/2,
             qRect.height()/2-waiting->height()/2 );


  waiting->show();
  waiting->raise();
  waiting->setActiveWindow();
  waiting->execute();

 
  
  //  this->setActiveWindow();

  ifstream input;
  input.open( "start.conf", ios_base::in );

  QString tmp_qstring;
  Console->setMaxLogLines (1000);

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

  int height = 5;
  QStringList command;

  startView->setHScrollBarMode(Q3ScrollView::AlwaysOff);
  startView->setGeometry( QRect( 10, 10, 600, 250 ) );
  startView->viewport()->setBackgroundColor( "white" );

  imagingView->setHScrollBarMode(Q3ScrollView::AlwaysOff);
  imagingView->setGeometry( QRect( 10, 10, 600, 250 ) );
  imagingView->viewport()->setBackgroundColor( "white" );

  // since some tabs can be hidden, we have to maintain this counter
  int nextPosForTabInsert = 0;
 
  for( unsigned int i = 0; i < elements.size(); i++ ) {
    
    int n = elements[i].find_current_image();
    if ( i == 0 ) {
      height = 14;
    }
    // Start View
    QLabel *startlabel = new QLabel( startView->viewport() );
    startlabel->setGeometry( QRect( 15, height, 260, 30 ) );
    startlabel->setText( elements[i].get_name() + " " + elements[i].image_history[n].get_version() );
    startView->addChild( startlabel, 15, height );

    // Imaging View
    QLabel *imaginglabel = new QLabel( imagingView->viewport() );
    imaginglabel->setGeometry( QRect( 15, (height+32), 260, 30 ) );
    imaginglabel->setText( elements[i].get_name() );
    imagingView->addChild( imaginglabel, 15, (height+32) );


    if( i == 0 ) {
      height = 5;
    }
    // Start Tab
    linbopushbutton *syncbutton = new linbopushbutton( startView->viewport() );
    syncbutton->setGeometry( QRect( 180, height, 100, 30 ) );
    syncbutton->setText( QString("Sync+Start") );
    syncbutton->setTextBrowser( Console );

    // add tooltip and icon
    QToolTip::add( syncbutton, QString("Startet " + elements[i].get_name() + " " +
                                       elements[i].image_history[n].get_version() +
                                       " synchronisiert") );
    // tmpImage.loadFromData( syncstarticon22x22, sizeof( syncstarticon22x22 ), "PNG" );
    if( withicons )
      syncbutton->setIconSet( QIcon(":/icons/sync+start-22x22.png" ) );

    // assign command
    command = mksyncstartcommand(config, elements[i],elements[i].image_history[n]);
    syncbutton->setCommand( command );
    syncbutton->setMainApp( this );
    syncbutton->setEnabled( elements[i].image_history[n].get_syncbutton() );
    
    // assign button to button list
    p_buttons.push_back( syncbutton );
    buttons_config.push_back( elements[i].image_history[n].get_syncbutton() );
    startView->addChild( syncbutton, 180, height );

    // Start Tab
    linbopushbutton *startbutton = new linbopushbutton( startView->viewport() );
    startbutton->setGeometry( QRect( 280, height, 100, 30 ) );
    startbutton->setText( QString("Start") );
    startbutton->setTextBrowser( Console );
         
    // add tooltip and icon
    QToolTip::add( startbutton, QString("Startet " + elements[i].get_name() + " " +
                                        elements[i].image_history[n].get_version() +
                                        " unsynchronisiert") );
    // tmpImage.loadFromData( starticon22x22, sizeof( starticon22x22 ), "PNG" );
    if( withicons )
      startbutton->setIconSet( QIcon(":/icons/start-22x22.png" ) );


    // build "start" command
    command = LINBO_CMD("start");
    command.append(elements[i].get_boot());
    command.append(elements[i].get_root());
    command.append(elements[i].image_history[n].get_kernel());
    command.append(elements[i].image_history[n].get_initrd());
    command.append(elements[i].image_history[n].get_append());
    command.append(config.get_cache());
     
    startbutton->setCommand( command );
    startbutton->setMainApp( this );
    startbutton->setEnabled( elements[i].image_history[n].get_startbutton() );

    // assign button to button list
    p_buttons.push_back( startbutton );
    buttons_config.push_back( elements[i].image_history[n].get_startbutton() );
    startView->addChild( startbutton, 280, height );

    // Imaging Tab
    linbopushbutton *createbutton = new linbopushbutton( imagingView->viewport() ); 
    createbutton->setGeometry( QRect( 320, (height + 32), 130, 30 ) );
    createbutton->setText( QString("Image erstellen") );
    createbutton->setTextBrowser( Console );

    linboImageSelectorImpl *buildImageSelector = new linboImageSelectorImpl( createbutton );
    // clear list
    buildImageSelector->listBox->clear();

    // entry for creating a new image
    buildImageSelector->listBox->insertItem( QString("[Neuer Dateiname]") );

    // fill list with images
    // base image
    buildImageSelector->listBox->insertItem(elements[i].get_baseimage());

    // incremental image - when assigned
    if( !(elements[i].image_history[n].get_image().stripWhiteSpace()).isEmpty() ) 
      buildImageSelector->listBox->insertItem(elements[i].image_history[n].get_image());

    // special image

    buildImageSelector->listBox->setSelected(0,true);
    
    buildImageSelector->setTextBrowser( Console );
    buildImageSelector->setCache( config.get_cache() );
    buildImageSelector->setBaseImage( elements[i].get_baseimage()  );
    buildImageSelector->setMainApp( this ); 

    command = LINBO_CMD("readfile");
    command.append( config.get_cache() );
    command.append( elements[i].get_baseimage() + QString(".desc") );
    command.append( QString("/tmp/") + elements[i].get_baseimage() + QString(".desc") );
    buildImageSelector->setLoadCommand( command );

    command = LINBO_CMD("writefile");
    command.append( config.get_cache() );
    command.append( elements[i].get_baseimage() + QString(".desc") );
    command.append( QString("/tmp/") + elements[i].get_baseimage() + QString(".desc") );
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
    // tmpImage.loadFromData( imageicon22x22, sizeof( imageicon22x22 ), "PNG" );
    if( withicons )
      createbutton->setIconSet( QIcon( ":/icons/image-22x22.png" ) );
    

    // build "create" command
    command = LINBO_CMD("create");
    command.append(config.get_cache());
    // Will be changed later!
    command.append(elements[i].image_history[n].get_image());
    command.append(elements[i].get_baseimage());
    command.append(elements[i].get_boot());
    command.append(elements[i].get_root());
    command.append(elements[i].image_history[n].get_kernel());
    command.append(elements[i].image_history[n].get_initrd());
    buildImageSelector->setCommand( command );


    // assign button to button list
    p_buttons.push_back( createbutton );
    buttons_config.push_back( 1 );
    imagingView->addChild( createbutton, 320, (height + 32) );

    // Start Tab
    linbopushbutton *newbutton = new linbopushbutton( startView->viewport() );
    newbutton->setGeometry( QRect( 380, height, 100, 30 ) );
    newbutton->setText( QString("Neu+Start") );
    newbutton->setTextBrowser( Console );

    // add tooltip and icon
    QToolTip::add( newbutton, QString("Installiert " + elements[i].get_name() + " " +
                                      elements[i].image_history[n].get_version() +
                                      " neu und startet es") );
    // tmpImage.loadFromData( newstarticon22x22, sizeof( newstarticon22x22 ), "PNG" );
    if( withicons )
      newbutton->setIconSet( QIcon( ":/icons/new+start-22x22.png" ) );
   


    
    // assign command
    command = mksyncrcommand(config, elements[i],elements[i].image_history[n]);
    newbutton->setCommand( command );
    newbutton->setMainApp((QDialog*)this );
    newbutton->setEnabled( elements[i].image_history[n].get_newbutton() );

    // assign button to button list
    p_buttons.push_back( newbutton );
    buttons_config.push_back( elements[i].image_history[n].get_newbutton() );
    startView->addChild( newbutton, 380, height );

    linbopushbutton *infobuttonstart = new linbopushbutton( startView->viewport() );
    infobuttonstart->setGeometry( QRect( 480, height, 100, 30 ) );
    infobuttonstart->setText( QString("Info") );
    infobuttonstart->setEnabled( true );
    infobuttonstart->setTextBrowser( Console );    

    // add tooltip and icon
    QToolTip::add( infobuttonstart, QString("Informationen zu " + elements[i].get_name() + " " +
                                       elements[i].image_history[n].get_version()) );
    // tmpImage.loadFromData( informationicon22x22, sizeof( informationicon22x22 ), "PNG" );
    if( withicons )
      infobuttonstart->setIconSet( QIcon( ":/icons/information-22x22.png" ) );

    linboInfoBrowserImpl *infoBrowser = new linboInfoBrowserImpl( infobuttonstart );
    infoBrowser->setTextBrowser( Console );
    infoBrowser->setMainApp( this );
    infoBrowser->setFilePath( QString("/tmp/") + elements[i].get_baseimage() + QString(".desc") );

    command = LINBO_CMD("readfile");
    command.append( config.get_cache() );
    command.append( elements[i].get_baseimage() + QString(".desc") );
    command.append( QString("/tmp/") + elements[i].get_baseimage() + QString(".desc") );
    infoBrowser->setLoadCommand( command );
   
    command = LINBO_CMD("writefile");
    command.append( config.get_cache() );
    command.append( elements[i].get_baseimage() + QString(".desc") );
    command.append( QString("/tmp/") + elements[i].get_baseimage() + QString(".desc") );
    infoBrowser->setSaveCommand( command );
    
    command = LINBO_CMD("upload");
    command.append( config.get_server() );
    command.append("linbo");
    command.append("password");
    command.append( config.get_cache() );
    command.append( elements[i].get_baseimage() + QString(".desc") );
    infoBrowser->setUploadCommand( command );
    
    infobuttonstart->setProgress( false );
    infobuttonstart->setMainApp((QDialog*)this );
    infobuttonstart->setLinboDialog( (linboDialog*)(infoBrowser) );
    infobuttonstart->setQDialog( (QDialog*)(infoBrowser) );

    // assign button to button list
    p_buttons.push_back( infobuttonstart );
    buttons_config.push_back( 1 );
    startView->addChild( infobuttonstart, 480, height );

    // Imaging Tab
    linbopushbutton *uploadbutton = new linbopushbutton( imagingView->viewport() );
    uploadbutton->setGeometry( QRect( 450, (height + 32), 130, 30 ) );
    uploadbutton->setText( QString("Image hochladen") );
    uploadbutton->setEnabled( true );
    uploadbutton->setTextBrowser( Console );

    // add tooltip and icon
    QToolTip::add( uploadbutton, QString("Ein Image für " + elements[i].get_name() + " " +
                                       elements[i].image_history[n].get_version() + 
                                         " auf den Server hochladen" ) );
    // tmpImage.loadFromData( uploadicon22x22, sizeof( uploadicon22x22 ), "PNG" );

    if( withicons )
      uploadbutton->setIconSet( QIcon( ":/icons/upload-22x22.png" ) );

    linboImageUploadImpl *imageUpload = new linboImageUploadImpl( uploadbutton);
    imageUpload->setTextBrowser( Console );
    imageUpload->setMainApp( this );

    // clear list
    imageUpload->listBox->clear();
    // fill list with images

    // base image
    imageUpload->listBox->insertItem(elements[i].get_baseimage());

    // incremental image - when assigned
    if( !(elements[i].image_history[n].get_image().stripWhiteSpace()).isEmpty() ) 
      imageUpload->listBox->insertItem(elements[i].image_history[n].get_image());

    command = LINBO_CMD("upload");
    command.append(config.get_server());
    command.append("linbo");
    command.append("password");
    command.append(config.get_cache());
    if( (elements[i].image_history[n].get_image().stripWhiteSpace()).isEmpty() ) {
      command.append( elements[i].get_baseimage() );
    } else {
      command.append( elements[i].image_history[n].get_image() );
    }
    imageUpload->setCommand( command );

    uploadbutton->setMainApp((QDialog*)this );
    uploadbutton->setLinboDialog( (linboDialog*)(imageUpload) );
    uploadbutton->setQDialog( (QDialog*)(imageUpload) );
    uploadbutton->setProgress( false );

    // assign button to button list
    p_buttons.push_back( uploadbutton );
    buttons_config.push_back( 1 );
    imagingView->addChild( uploadbutton, 450, (height + 32) );

    // where is my homie?
    createbutton->setNeighbour( uploadbutton );
    uploadbutton->setNeighbour( createbutton );

    startView->resizeContents( 600, height);  
    height += 32;

    int height2 = 5;

    // check: if one of the histiry entries is declared hidden,
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
      view->viewport()->setBackgroundColor( "white" );
      view->setGeometry( QRect( 10, 10, 600, 250 ) );

      for( unsigned int n = 0; n < elements[i].image_history.size(); n++ ) {

        // QT BUG!
        if ( n == 0 ) {
          height2 = 14;
        }

        QLabel *imagename = new QLabel( view->viewport() );
        imagename->setGeometry( QRect( 15, height2, 100, 30 ) );
        imagename->setText( "Version: " + elements[i].image_history[n].get_version() );
        view->addChild( imagename, 15, height2 );
        if ( n == 0 ) {
          height2 = 5;
        }
        QLabel *imagetext = new QLabel( view->viewport() );
        imagetext->setGeometry( QRect( 120, height2, 260, 30 ) );
        imagetext->setText( elements[i].image_history[n].get_description() );
        view->addChild( imagetext, 120, height2 );
      
        linbopushbutton *isyncbutton = new linbopushbutton( view->viewport() );
        isyncbutton->setGeometry( QRect( 280, height2, 100, 30 ) );
        isyncbutton->setText( QString("Sync+Start") );
        isyncbutton->setTextBrowser( Console );    
        isyncbutton->setEnabled( true );

        // add tooltip and icon
        QToolTip::add( isyncbutton, QString("Startet " + elements[i].get_name() + " " +
                                            elements[i].image_history[n].get_version() +
                                            " synchronisiert") );
        // tmpImage.loadFromData( syncstarticon22x22, sizeof( syncstarticon22x22 ), "PNG" );
        if( withicons )
          isyncbutton->setIconSet( QIcon( ":/icons/sync+start-22x22.png" ) );


        command = mksyncstartcommand(config, elements[i],elements[i].image_history[n]);
        isyncbutton->setCommand( command );
        isyncbutton->setMainApp((QDialog*)this );

        if( elements[i].image_history[n].get_autostart() &&
            !autostart ) {
          Console->append( QString("Autostart selected for OS Nr. ")
                                   + QString::number(i) 
                                   + QString(", Image History Nr. ") 
                                   + QString::number( n ) );

          autostart = isyncbutton;
        }

        // assign button to button list
        p_buttons.push_back( isyncbutton );
        buttons_config.push_back( 1 );
        view->addChild( isyncbutton, 280, height2 );

        linbopushbutton *irecreatebutton = new linbopushbutton( view->viewport() );
        irecreatebutton->setGeometry( QRect( 380, height2, 100, 30 ) );
        irecreatebutton->setText( QString("Neu+Start") );
        irecreatebutton->setTextBrowser( Console );
      
        command = mksyncrcommand(config, elements[i],elements[i].image_history[n]);
        irecreatebutton->setCommand( command );
        irecreatebutton->setEnabled( true );
      
        // add tooltip and icon
        QToolTip::add( irecreatebutton, QString("Installiert " + elements[i].get_name() + " " +
                                                elements[i].image_history[n].get_version() +
                                                " neu und startet es") );
        // tmpImage.loadFromData( newstarticon22x22, sizeof( newstarticon22x22 ), "PNG" );

        if( withicons )
          irecreatebutton->setIconSet( QIcon( ":/icons/new+start-22x22.png" ) );


        irecreatebutton->setMainApp(this );
        // assign button to button list
        p_buttons.push_back( irecreatebutton );
        buttons_config.push_back( 1 );
        view->addChild( irecreatebutton, 380, height2 );

        linbopushbutton *iinfobuttonstart = new linbopushbutton( view->viewport() );
        iinfobuttonstart->setGeometry( QRect( 480, height2, 100, 30 ) );
        iinfobuttonstart->setText( QString("Info") );
        iinfobuttonstart->setEnabled( true );
        iinfobuttonstart->setTextBrowser( Console );    

        linboInfoBrowserImpl *iinfoBrowser = new linboInfoBrowserImpl( iinfobuttonstart );
        iinfoBrowser->setTextBrowser( Console );
        iinfoBrowser->setMainApp(this);
        iinfoBrowser->setFilePath( QString("/tmp/") + elements[i].get_baseimage() + QString(".desc") );
        iinfobuttonstart->setProgress( false );
        iinfobuttonstart->setMainApp(this );

        command = LINBO_CMD("readfile");
        command.append( config.get_cache() );
        command.append( elements[i].get_baseimage() + QString(".desc") );
        command.append( QString("/tmp/") + elements[i].get_baseimage() + QString(".desc") );
        iinfoBrowser->setLoadCommand( command );

        command = LINBO_CMD("writefile");
        command.append( config.get_cache() );
        command.append( elements[i].get_baseimage() + QString(".desc") );
        command.append( QString("/tmp/") + elements[i].get_baseimage() + QString(".desc") );
        iinfoBrowser->setSaveCommand( command );
    
        command = LINBO_CMD("upload");
        command.append( config.get_server() );
        command.append("linbo");
        command.append("password");
        command.append( config.get_cache() );
        command.append( QString("/tmp/") + elements[i].get_baseimage() + QString(".desc") );
        iinfoBrowser->setUploadCommand( command );

        iinfobuttonstart->setLinboDialog( (linboDialog*)(infoBrowser) );
        iinfobuttonstart->setQDialog( (QDialog*)(infoBrowser) );

        // add tooltip and icon
        QToolTip::add( iinfobuttonstart, QString("Informationen zu " + elements[i].get_name() + " " +
                                                 elements[i].image_history[n].get_version()) );
        // tmpImage.loadFromData( informationicon22x22, sizeof( informationicon22x22 ), "PNG" );

        if( withicons )
          iinfobuttonstart->setIconSet( QIcon( ":/icons/information-22x22.png" ) );

 
        // assign button to button list
        p_buttons.push_back( iinfobuttonstart );
        buttons_config.push_back( 1 );
        view->addChild( iinfobuttonstart, 480, height2 );

        view->resizeContents( 600, height2);
        height2 += 32;
      }
      Tabs->insertTab( newtab, elements[i].get_name(), (nextPosForTabInsert+1) );
      nextPosForTabInsert++;
    } else {
      // in case one of the elements is marked as "Autostart", we have to create the
      // matching, invisible sync+start button
    
      for( unsigned int n = 0; n < elements[i].image_history.size(); n++ ) {

        if( elements[i].image_history[n].get_autostart() &&
            !autostart ) {

          Console->append( QString("Autostart selected for OS Nr. ") 
                                   + QString::number(i) 
                                   + QString(", Image History Nr. ") 
                                   + QString::number( n ) );
          
          linbopushbutton *isyncbutton = new linbopushbutton( this );
          isyncbutton->setGeometry( QRect( 280, height2, 100, 30 ) );
          isyncbutton->setText( QString("Sync+Start") );
          isyncbutton->setTextBrowser( Console );    
          isyncbutton->setEnabled( true );
          isyncbutton->hide();
          
          command = mksyncstartcommand(config, elements[i],elements[i].image_history[n]);
          isyncbutton->setCommand( command );
          isyncbutton->setMainApp(this );
          
          // assign button to button list
          p_buttons.push_back( isyncbutton );
          buttons_config.push_back( 1 );
          
          autostart = isyncbutton; 
        }
      }
    }

  }  
  imagingView->resizeContents( 600, (height+32));

  linbopushbutton *consolebuttonimaging = new linbopushbutton( imagingView->viewport() );
  consolebuttonimaging->setGeometry( QRect( 150, 5, 100, 30 ) );
  consolebuttonimaging->setText( QString("Console") );
  consolebuttonimaging->setTextBrowser( Console );

  linboConsoleImpl *linboconsole = new linboConsoleImpl( consolebuttonimaging );
  linboconsole->setMainApp(this );
  linboconsole->setTextBrowser( Console );

  consolebuttonimaging->setProgress( false );
  consolebuttonimaging->setMainApp(this );
  consolebuttonimaging->setLinboDialog( (linboDialog*)(linboconsole) );
  consolebuttonimaging->setQDialog( (QDialog*)(linboconsole) );

  // add tooltip and icon
  QToolTip::add( consolebuttonimaging, QString("Öffnet das Konsolenfenster") );
  // tmpImage.loadFromData( consoleicon22x22, sizeof( consoleicon22x22 ), "PNG" );

  if( withicons )
    consolebuttonimaging->setIconSet( QIcon( ":/icons/console-22x22.png" ) );

  // assign button to button list
  p_buttons.push_back( consolebuttonimaging );
  buttons_config.push_back( 1 );
  imagingView->addChild( consolebuttonimaging, 150, 5 );


  linbopushbutton *multicastbuttonimaging = new linbopushbutton( imagingView->viewport() );
  multicastbuttonimaging->setGeometry( QRect( 250, 5, 130, 30 ) );
  multicastbuttonimaging->setText( QString("Cache aktualisieren") );
  multicastbuttonimaging->setTextBrowser( Console );

  // add tooltip and icon
  QToolTip::add( multicastbuttonimaging, QString("Aktualisiert den lokalen Cache") );
  // tmpImage.loadFromData( cacheicon22x22, sizeof( cacheicon22x22 ), "PNG" );

  if( withicons )
    multicastbuttonimaging->setIconSet( QIcon( ":/icons/cache-22x22.png" ) );

  linboMulticastBoxImpl *multicastbox = new linboMulticastBoxImpl( multicastbuttonimaging ); 
  multicastbox->setMainApp(this );
  multicastbox->setTextBrowser( Console );
  multicastbox->setRsyncCommand( mkcacheinitcommand( config, elements, false) );
  multicastbox->setMulticastCommand( mkcacheinitcommand( config, elements, true ) );

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
    autoinitcachebutton->setTextBrowser( Console );
    autoinitcachebutton->setMainApp(this );
    autoinitcachebutton->setProgress( true );
    autoinitcachebutton->setCommand( mkcacheinitcommand( config, elements, config.get_usemulticast() ) );
    autoinitcache = autoinitcachebutton;
    autoinitcachebutton->hide();
  }

  // assign button to button list
  p_buttons.push_back( multicastbuttonimaging );
  buttons_config.push_back( 1 );
  imagingView->addChild( multicastbuttonimaging, 250, 5 );

  // Partition button - Imaging tab
  linbopushbutton *partitionbutton = new linbopushbutton( imagingView->viewport() );
  partitionbutton->setGeometry( QRect( 380, 5, 100, 30 ) );
  partitionbutton->setText( QString("Partitionieren") );
  partitionbutton->setTextBrowser( Console );
  partitionbutton->setMainApp(this );
  partitionbutton->setEnabled( true );

  // add tooltip and icon
  QToolTip::add( partitionbutton, QString("Partitioniert die Festplatte neu") );
  // tmpImage.loadFromData( partitionicon22x22, sizeof( partitionicon22x22 ), "PNG" );

  if( withicons )
    partitionbutton->setIconSet( QIcon( ":/icons/partition-22x22.png" ) );

  linboYesNoImpl *yesNoPartition = new linboYesNoImpl( partitionbutton);
  yesNoPartition->question->setText("Alle Daten auf der Festplatte löschen?");
  yesNoPartition->setTextBrowser( Console );
  yesNoPartition->setMainApp(this );
  yesNoPartition->setCommand(mkpartitioncommand(partitions));

  autopartition = 0;
  linbopushbutton *autopartitionbutton = new linbopushbutton();
  // this invisible button is needed für autopartition
  if( config.get_autopartition() ) {
    autopartitionbutton->setTextBrowser( Console );
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
  
  
  imagingView->addChild( partitionbutton, 380, 5 );

  // assign button to button list
  p_buttons.push_back( partitionbutton );
  buttons_config.push_back( 1 );

  // RegisterBox button - Imaging tab
  linbopushbutton *registerbutton = new linbopushbutton( imagingView->viewport() );
  registerbutton->setGeometry( QRect( 480, 5, 100, 30 ) );
  registerbutton->setText( QString("Registrieren") );
  registerbutton->setTextBrowser( Console );
  registerbutton->setMainApp(this );
  registerbutton->setEnabled( true );

  // add tooltip and icon
  QToolTip::add( registerbutton, QString("Öffnet den Registrierungsdialog zur Aufnahme neuer Rechner") );
  // tmpImage.loadFromData( registericon22x22, sizeof( registericon22x22 ), "PNG" );

  if( withicons )
    registerbutton->setIconSet( QIcon(  ":/icons/register-22x22.png") );

  
  linboRegisterBoxImpl *registerBox = new linboRegisterBoxImpl( registerbutton );
  registerBox->setTextBrowser( Console );
  registerBox->setMainApp(this );

  command = LINBO_CMD("register");
  command.append( config.get_server() );
  command.append("linbo");
  command.append("password");
  command.append("clientRoom");
  command.append("clientName");
  command.append("clientIP");
  command.append("clientGroup");

  registerBox->setCommand( command );

  registerbutton->setProgress( false );

  registerbutton->setLinboDialog( (linboDialog*)(registerBox) );
  registerbutton->setQDialog( (QDialog*)(registerBox) );

  imagingView->addChild( registerbutton, 480, 5 );

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
  myLPasswordBox->setTextBrowser( Console );


  // Code for detecting tab changes
  connect( Tabs, SIGNAL(currentChanged( QWidget* )), 
           this, SLOT(tabWatcher( QWidget* )) );

  // create process for our status bar

  myprocess = new Q3Process( this );
  connect( myprocess, SIGNAL(readyReadStdout()),
           this, SLOT(readFromStdout()) );
  connect( myprocess, SIGNAL(readyReadStderr()),
           this, SLOT(readFromStderr()) );

  // we don't want to see this on the LINBO Console
  outputvisible = false;

  //  client ip

  command = LINBO_CMD("ip");
  myprocess->setArguments( command );
  myprocess->start();
  while( myprocess->isRunning() ) {
    usleep( 1000 );
  }
  clientIPLabel->setText( QString(" Client IP: ") + linestdout ); 

  //  server ip

  serverIPLabel->setText( QString("   Server IP: ") + config.get_server() ); 

  // mac address

  command = LINBO_CMD("mac");
  myprocess->setArguments( command );
  myprocess->start();
  while( myprocess->isRunning() ) {
    usleep( 1000 );
  }
  macLabel->setText( QString(" MAC: ") + linestdout ); 
  
  // hostname and hostgroup 

  command = LINBO_CMD("hostname");
  myprocess->setArguments( command );
  myprocess->start();
  while( myprocess->isRunning() ) {
    usleep( 1000 );
  }
  nameandgroup->setText( QString(" Host: ") + linestdout + QString(", Gruppe: ") + config.get_hostgroup() );
  
  // our clock displaying the system time
  myTimer = new QTimer(this);
  connect( myTimer, SIGNAL(timeout()), this, SLOT(processTimeout()) );
  myTimer->start( 1000, FALSE );

  // CPU 
  command = LINBO_CMD("cpu");
  myprocess->setArguments( command );
  myprocess->start();
  while( myprocess->isRunning() ) {
    usleep( 1000 );
  }
  cpuLabel->setText( QString("   CPU: ") + linestdout ); 

  // Memory
  command = LINBO_CMD("memory");
  myprocess->setArguments( command );
  myprocess->start();
  while( myprocess->isRunning() ) {
    usleep( 1000 );
  }
  memLabel->setText( QString(" RAM: ") + linestdout ); 

  // Cache Size
  command = LINBO_CMD("size");
  command.append( config.get_cache() );
  myprocess->setArguments( command );
  myprocess->start();
  while( myprocess->isRunning() ) {
    usleep( 1000 );
  }
  cacheLabel->setText( QString(" Cache: ") + linestdout );

  // Harddisk Size
  QRegExp *removePartition = new QRegExp("[0-9]{1,2}");
  QString hd = config.get_cache();
  hd.remove( *removePartition );

  command = LINBO_CMD("size");
  command.append( hd );
  myprocess->setArguments( command );
  myprocess->start();
  while( myprocess->isRunning() ) {
    usleep( 1000 );
  }
  hdLabel->setText( QString(" HD: ") + linestdout );

  // enable console output again
  outputvisible = true;

}



void linboGUIImpl::processTimeout() {
  timeLabel->setText( QTime::currentTime().toString() );
}


void linboGUIImpl::shutdown() {
  QStringList command;
  command.clear();
  command = QStringList("busybox");
  command.append("poweroff");
  Console->append( QString("shutdown entered") );
  myprocess->setArguments( command );
  myprocess->start();
}

void linboGUIImpl::reboot() {
  QStringList command;
  command.clear();
  command = QStringList("busybox");
  command.append("reboot");
  Console->append( QString("reboot entered") );
  myprocess->setArguments( command );
  myprocess->start();
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
  while( myprocess->canReadLineStdout() )
    {
      linestdout = myprocess->readLineStdout();
      log( linestdout );

      if( outputvisible )
        Console->append( linestdout );
    } 
}

void linboGUIImpl::readFromStderr()
{
  while( myprocess->canReadLineStderr() )
    {
      linestderr = myprocess->readLineStderr();
      log( linestderr );

      if( outputvisible ) {
        linestderr.prepend( "<FONT COLOR=red>" );
        linestderr.append( "</FONT>" );
        Console->append( linestderr );
      }
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
  if( autostart ) 
    autostart->lclicked();
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
