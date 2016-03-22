#-------------------------------------------------
#
# Project created by QtCreator 2016-02-17T17:53:31
#
#-------------------------------------------------
CONFIG(release, debug|release) {
    #This is a release build
} else {
    #This is a debug build
    DEFINES += TESTCOMMAND=echo
}

QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = linbo_gui
TEMPLATE = app


SOURCES += main.cpp\
        anmeldefenster.cpp\
        linbogui.cpp \
    registrierungsdialog.cpp \
    fortschrittdialog.cpp \
    configuration.cpp \
    command.cpp \
    image_description.cpp \
    linboCounter.cpp \
    linboImageSelector.cpp \
    linboImageUpload.cpp \
    linboInfoBrowser.cpp \
    linboInputBox.cpp \
    linboLogConsole.cpp \
    linboMsg.cpp \
    linboPushButton.cpp \
    linboProgress.cpp \
    linboMulticastBox.cpp \
    linboPasswordBox.cpp \
    linboRegisterBox.cpp \
    linboYesNo.cpp \
    linboConsole.cpp \
    linbooswidget.cpp

HEADERS  += linbogui.h\
        anmeldefenster.h \
    registrierungsdialog.h \
    fortschrittdialog.h \
    configuration.h \
    command.h \
    image_description.h \
    linboConsole.h \
    linboCounter.h \
    linboImageSelector.h \
    linboImageUpload.h \
    linboInfoBrowser.h \
    linboInputBox.h \
    linboLogConsole.h \
    linboMsg.h \
    linboPushButton.h \
    linboDialog.h \
    linboMulticastBox.h \
    linboPasswordBox.h \
    linboProgress.h \
    linboRegisterBox.h \
    linboYesNo.h \
    linbooswidget.h

FORMS    += linbogui.ui\
        anmeldefenster.ui \
    registrierungsdialog.ui \
    fortschrittdialog.ui \
    linboConsole.ui \
    linboCounter.ui \
    linboImageSelector.ui \
    linboImageUpload.ui \
    linboInfoBrowser.ui \
    linboInputBox.ui \
    linboMsg.ui \
    linboMulticastBox.ui \
    linboPasswordBox.ui \
    linboProgress.ui \
    linboRegisterBox.ui \
    linboYesNo.ui \
    linbooswidget.ui

RESOURCES += \
    linbo_icons.qrc \
    linbooswidget_icons.qrc
