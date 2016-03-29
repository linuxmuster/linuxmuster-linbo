#ifndef CONSOLEWIDGET_H
#define CONSOLEWIDGET_H

#include <qplaintextedit.h>
#include <qstring.h>
#include <qprocess.h>
#include <QScrollBar>
#include <QtCore/QDebug>

class ConsoleWidget: public QPlainTextEdit
{

    Q_OBJECT

private:
    QString command;
    QProcess *process;

public:
    void insertPlainText(const QString &data);
    void setLocalEchoEnabled(bool set);

    ConsoleWidget(QWidget* parent);
    ~ConsoleWidget();

private:
    void keyPressEvent(QKeyEvent *e);
    void mousePressEvent(QMouseEvent *e);
    void mouseDoubleClickEvent(QMouseEvent *e);
    void contextMenuEvent(QContextMenuEvent *e);
    void doCommand();

private slots:
    void readStdError();
    void readStdOut();
    void finished(int exitCode, QProcess::ExitStatus exitStatus);

};
#endif // CONSOLEWIDGET_H

