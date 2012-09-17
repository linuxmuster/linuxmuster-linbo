/* holds the environmental configuration of our console

Copyright (C) 2010 Martin Oehler <oehler@knopper.net>

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

#include <QtGui>
#include <QTextCursor>

#include "linboLogConsole.hh"

linboLogConsole::linboLogConsole(  QWidget* parent,  
				   const char* name )
{
  consolefontcolorstdout =  QColor( QString("white") );
  consolefontcolorstderr =  QColor( QString("red") );
  Console = 0;
}

linboLogConsole::~linboLogConsole() {

}


void linboLogConsole::setLinboLogConsole( const QString& new_consolefontcolorstdout,
					  const QString& new_consolefontcolorstderr,
					  QTextEdit* new_console ) {

  consolefontcolorstdout =  QColor( new_consolefontcolorstdout );
  consolefontcolorstderr =  QColor( new_consolefontcolorstderr );

  if ( new_console != 0 )
    Console = new_console;

}

void linboLogConsole::writeStdOut( const QByteArray& stdoutdata ) {

  if ( Console != 0 ) {
    Console->setColor( consolefontcolorstdout );
    Console->insert( stdoutdata );
    Console->moveCursor(QTextCursor::End);
    Console->ensureCursorVisible(); 
  }

}

void linboLogConsole::writeStdOut( const QString& stdoutdata ) {

  if ( Console != 0 ) {
    Console->setColor( consolefontcolorstdout );
    Console->insert( stdoutdata );
    Console->insert(QString(QChar::LineSeparator));
    Console->moveCursor(QTextCursor::End);
    Console->ensureCursorVisible(); 
  }

}

void linboLogConsole::writeStdErr( const QByteArray& stderrdata ) {
  if ( Console != 0 ) {

    Console->setColor( consolefontcolorstderr  );
    Console->insert( stderrdata );
    Console->setColor( consolefontcolorstdout );
    Console->moveCursor(QTextCursor::End);
    Console->ensureCursorVisible(); 
  }
}

void linboLogConsole::writeStdErr( const QString& stderrdata ) {
  if ( Console != 0 ) {

    Console->setColor( consolefontcolorstderr  );
    Console->insert( stderrdata );
    Console->insert(QString(QChar::LineSeparator));
    Console->setColor( consolefontcolorstdout );
    Console->moveCursor(QTextCursor::End);
    Console->ensureCursorVisible(); 
  }
}


void linboLogConsole::writeResult( const int& processRetval,
				   QProcess::ExitStatus status,
				   const int& errorstatus ) {

  if ( Console != 0 ) {
    Console->setColor( consolefontcolorstderr );
    Console->insert( QString("Command executed with exit value ") + QString::number( processRetval ) );

    if( status == 0)
      Console->insert( QString("Exit status: ") + QString("The process exited normally.") );
    else
      Console->insert( QString("Exit status: ") + QString("The process crashed.") );

    if( status == 1 ) {
      switch ( errorstatus ) {
        case 0: Console->insert( QString("The process failed to start. Either the invoked program is missing, or you may have insufficient permissions to invoke the program.") ); break;
        case 1: Console->insert( QString("The process crashed some time after starting successfully.") ); break;
        case 2: Console->insert( QString("The last waitFor...() function timed out.") ); break;
        case 3: Console->insert( QString("An error occurred when attempting to write to the process. For example, the process may not be running, or it may have closed its input channel.") ); break;
        case 4: Console->insert( QString("An error occurred when attempting to read from the process. For example, the process may not be running.") ); break;
        case 5: Console->insert( QString("An unknown error occurred.") ); break;
      }

    }
    Console->insert(QString(QChar::LineSeparator));  
    
    Console->setColor( consolefontcolorstdout );
    Console->moveCursor(QTextCursor::End);
    Console->ensureCursorVisible(); 
  }

}
