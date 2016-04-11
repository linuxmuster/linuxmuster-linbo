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

#ifndef LINBOLOGCONSOLE_H
#define LINBOLOGCONSOLE_H

#include <qstring.h>
#include <qwidget.h>
#include <QTextEdit>
#include <QByteArray>
#include <QColor>
#include <qstringlist.h>

#include "linbogui.h"

class linboLogConsole
{

private:
    static const QString STDLOGFILEPATH;

    QColor consolefontcolorstdout, consolefontcolorstderr;
    QTextEdit* Console;
    QString logfilepath;

    void log( const QString& data );

public:
    linboLogConsole(const QString& new_consolefontcolorstdout = NULL,
                    const QString& new_consolefontcolorstderr = NULL,
                    QTextEdit* new_console = NULL,
                    const QString& logfilepath = NULL);

    ~linboLogConsole();

    static const QColor& COLORSTDOUT;
    static const QColor& COLORSTDERR;

    // TODO: error handling
    void setLinboLogConsole( const QString& new_consolefontcolorstdout,
                             const QString& new_consolefontcolorstderr,
                             QTextEdit* new_console,
                             const QString& new_logfilepath = NULL);
    void setLinboLogConsole( const QColor& new_consolefontcolorstdout,
                             const QColor& new_consolefontcolorstderr,
                             QTextEdit* new_console,
                             const QString& new_logfilepath = NULL);

    void writeStdOut( const QByteArray& stdoutdata );
    void writeStdOut( const QString& stdoutdata );
    void writeStdErr( const QByteArray& stderrdata );
    void writeStdErr( const QString& stderrdata );
    void writeResult( const int& processRetval,
                      QProcess::ExitStatus status,
                      const int& errorstatus );
    const QColor& get_colorstdout();
    const QColor& get_colorstderr();

};
#endif
