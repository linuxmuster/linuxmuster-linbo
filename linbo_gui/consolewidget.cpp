#include <QScrollBar>
#include <QtCore/QDebug>
#include <qplaintextedit.h>
#include <qprocess.h>

#include "consolewidget.h"
#include "linboLogConsole.h"

ConsoleWidget::ConsoleWidget(QWidget *parent)
    : QPlainTextEdit(parent), command(""), process()
{
    document()->setMaximumBlockCount(100);
    QPalette p = palette();
    p.setColor(QPalette::Base, Qt::black);
    p.setColor(QPalette::Text, Qt::green);
    setPalette(p);

    process = new QProcess( this );
    connect(process, SIGNAL(readyReadStandardError()),this, SLOT(readStdError()));
    connect(process, SIGNAL(readyReadStandardOutput()),this, SLOT(readStdOut()));
    connect(process, SIGNAL(finished(int,QProcess::ExitStatus)),
            this, SLOT(finished(int,QProcess::ExitStatus)));
    process->start(QString("bash"));
}

ConsoleWidget::~ConsoleWidget()
{
    // nothing to do
}

void ConsoleWidget::insertPlainText(const QString &data)
{
    QPlainTextEdit::insertPlainText(data);

    QScrollBar *bar = verticalScrollBar();
    bar->setValue(bar->maximum());
}

void ConsoleWidget::keyPressEvent(QKeyEvent *e)
{
    switch (e->key()) {
    case Qt::Key_Backspace:
    case Qt::Key_Left:
    case Qt::Key_Right:
    case Qt::Key_Up:
    case Qt::Key_Down:
        break;
    case Qt::Key_Enter:
    case Qt::Key_Return:
        // execute command and show output
        insertPlainText(e->text());
        doCommand();
        break;
    default:
        insertPlainText(e->text());
        command += e->text().toLocal8Bit();
        break;
    }
}

void ConsoleWidget::mousePressEvent(QMouseEvent *e)
{
    Q_UNUSED(e)
    setFocus();
}

void ConsoleWidget::mouseDoubleClickEvent(QMouseEvent *e)
{
    Q_UNUSED(e)
}

void ConsoleWidget::contextMenuEvent(QContextMenuEvent *e)
{
    Q_UNUSED(e)
}

void ConsoleWidget::doCommand()
{
    command += "\n";
    process->write( command.toLocal8Bit() );
    command = "";
}

void ConsoleWidget::readStdError()
{
    if( process != NULL ) {
        insertPlainText( process->readAllStandardError() );
    }
}

void ConsoleWidget::readStdOut()
{
    if( process != NULL ) {
        insertPlainText( process->readAllStandardOutput() );
    }
}

void ConsoleWidget::finished(int exitCode, QProcess::ExitStatus exitStatus)
{
    qDebug()<<"process ended with " << exitCode << " and status " << exitStatus << "\n";
    process = NULL;
}
