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

#include "linboLogConsole.h"

const QColor& linboLogConsole::COLORSTDOUT = QColor( QString("white") );
const QColor& linboLogConsole::COLORSTDERR = QColor( QString("red") );
#ifdef TESTCOMMAND
const QString STDLOGFILEPATH = QString("./linbo.log");
#else
const QString STDLOGFILEPATH = QString("/tmp/linbo.log");
#endif

linboLogConsole::linboLogConsole(const QString &new_consolefontcolorstdout,
                                 const QString &new_consolefontcolorstderr,
                                 QTextEdit *new_console, const QString& new_logfilepath):
    consolefontcolorstdout(),consolefontcolorstderr(),Console(new_console),
    logfilepath(new_logfilepath)
{
    consolefontcolorstdout =  new_consolefontcolorstdout == NULL ? COLORSTDOUT
                                                                 : QColor( new_consolefontcolorstdout );
    consolefontcolorstderr =  new_consolefontcolorstderr == NULL ? COLORSTDERR
                                                                 : QColor( new_consolefontcolorstderr );
}

linboLogConsole::~linboLogConsole() {

}


void linboLogConsole::setLinboLogConsole( const QString& new_consolefontcolorstdout,
                                          const QString& new_consolefontcolorstderr,
                                          QTextEdit* new_console, const QString& new_logfilepath ) {

    consolefontcolorstdout =  QColor( new_consolefontcolorstdout );
    consolefontcolorstderr =  QColor( new_consolefontcolorstderr );

    if ( new_console != 0 )
        Console = new_console;

    if( new_logfilepath != NULL)
        logfilepath = new_logfilepath;
}

void linboLogConsole::setLinboLogConsole( const QColor& new_consolefontcolorstdout,
                                          const QColor& new_consolefontcolorstderr,
                                          QTextEdit* new_console, const QString& new_logfilepath ) {

    consolefontcolorstdout =  new_consolefontcolorstdout;
    consolefontcolorstderr =  new_consolefontcolorstderr;

    if ( new_console != 0 )
        Console = new_console;

    if( new_logfilepath != NULL)
        logfilepath = new_logfilepath;
}

void linboLogConsole::writeStdOut( const QByteArray& stdoutdata ) {

    if ( Console != 0 ) {
        Console->setTextColor( consolefontcolorstdout );
        Console->append( stdoutdata );
        Console->moveCursor(QTextCursor::End);
        Console->ensureCursorVisible();
    }
    log(QString(stdoutdata));
}

void linboLogConsole::writeStdOut( const QString& stdoutdata ) {

    if ( Console != 0 ) {
        Console->setTextColor( consolefontcolorstdout );
        Console->append( stdoutdata );
        Console->append(QString(QChar::LineSeparator));
        Console->moveCursor(QTextCursor::End);
        Console->ensureCursorVisible();
    }
    log(stdoutdata);
}

void linboLogConsole::writeStdErr( const QByteArray& stderrdata ) {
    if ( Console != 0 ) {

        Console->setTextColor( consolefontcolorstderr  );
        Console->append( stderrdata );
        Console->setTextColor( consolefontcolorstdout );
        Console->moveCursor(QTextCursor::End);
        Console->ensureCursorVisible();
    }
    log(QString(stderrdata));
}

void linboLogConsole::writeStdErr( const QString& stderrdata ) {
    if ( Console != 0 ) {

        Console->setTextColor( consolefontcolorstderr  );
        Console->append( stderrdata );
        Console->append(QString(QChar::LineSeparator));
        Console->setTextColor( consolefontcolorstdout );
        Console->moveCursor(QTextCursor::End);
        Console->ensureCursorVisible();
    }
    log(stderrdata);
}


void linboLogConsole::writeResult( const int& processRetval,
                                   QProcess::ExitStatus status,
                                   const int& errorstatus ) {
    QString out = QString("");
    if ( Console != 0 ) {
        Console->setTextColor( consolefontcolorstderr );
        out = QString("Command executed with exit value ") + QString::number( processRetval ) + "\n";

        if( status == 0)
            out += QString("Exit status: ") + QString("The process exited normally.") +"\n";
        else
            out += QString("Exit status: ") + QString("The process crashed.") +"\n";

        if( status == 1 ) {
            switch ( errorstatus ) {
            case 0: out += QString("The process failed to start. Either the invoked program is missing, or you may have insufficient permissions to invoke the program.") +"\n"; break;
            case 1: out += QString("The process crashed some time after starting successfully.") +"\n"; break;
            case 2: out += QString("The last waitFor...() function timed out.") +"\n"; break;
            case 3: out += QString("An error occurred when attempting to write to the process. For example, the process may not be running, or it may have closed its input channel.") +"\n"; break;
            case 4: out += QString("An error occurred when attempting to read from the process. For example, the process may not be running.") +"\n"; break;
            case 5: out += QString("An unknown error occurred.") +"\n"; break;
            }

        }
        out +=QString(QChar::LineSeparator);
        Console->append(out);
        Console->setTextColor( consolefontcolorstdout );
        Console->moveCursor(QTextCursor::End);
        Console->ensureCursorVisible();
    }
    log(out);
}

void linboLogConsole::log( const QString& data ) {
    if(logfilepath == NULL)
        return;
    // write to our logfile
    QFile logfile( logfilepath  );
    logfile.open( QIODevice::WriteOnly | QIODevice::Append );
    QTextStream logstream( &logfile );
    logstream << data << "\n";
    logfile.flush();
    logfile.close();
}


const QColor& linboLogConsole::get_colorstdout()
{
    return consolefontcolorstdout;
}

const QColor& linboLogConsole::get_colorstderr()
{
    return consolefontcolorstderr;
}

