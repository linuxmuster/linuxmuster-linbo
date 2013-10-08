// STL-includes
#include <iostream>
#include <qwindowsystem_qws.h>
#include <QWSServer>
#include <qimage.h>
#include <qtimer.h>
// qt
#include <qapplication.h>
#include "linboGUIImpl.hh"
#include <QtGui>
#include <QPalette>
#include <QBrush> 
#include <QScreen>
#include <QLocale>


int main( int argc, char* argv[] )
{

  QApplication myapp( argc, argv );

  QWSServer* wsServer = QWSServer::instance();

  QImage bgimg( "/icons/linbo_wallpaper.png", "PNG" );
  int width = qt_screen->deviceWidth();
  int height = qt_screen->deviceHeight();

  if ( wsServer ) {
    wsServer->setBackground( QBrush( bgimg.scaled( width, height, Qt::IgnoreAspectRatio ) ) );
    wsServer->refresh();
  }

  linboGUIImpl* myGUI = new linboGUIImpl; 

  myGUI->show();
  // this paints a transparent main widget 
  myGUI->setStyleSheet( "QDialog#linboGUI{ background: transparent }");


  /*  myGUI->Console->viewport()->setAutoFillBackground(true);
  myGUI->Console->setTextColor( QColor("white") );

  QPalette palette; */
  // a grey transparent background
    // myGUI->Console->setStyleSheet("QTextEdit#Console{ background: transparent }");

  
  QTimer::singleShot( 100, myGUI, SLOT(executeAutostart()) );  

  return myapp.exec();
}
