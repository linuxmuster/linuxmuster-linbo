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
        linbogui.cpp \
    registrierungsdialog.cpp \
    fortschrittdialog.cpp \
    configuration.cpp \
    command.cpp \
    image_description.cpp \
    linboImageSelector.cpp \
    linboImageUpload.cpp \
    linboInfoBrowser.cpp \
    linboLogConsole.cpp \
    linboMulticastBox.cpp \
    linboConsole.cpp \
    linbooswidget.cpp \
    linboimagewidget.cpp \
    login.cpp \
    consolewidget.cpp \
    downloadtype.cpp

HEADERS  += linbogui.h\
    registrierungsdialog.h \
    fortschrittdialog.h \
    configuration.h \
    command.h \
    image_description.h \
    linboConsole.h \
    linboImageSelector.h \
    linboImageUpload.h \
    linboInfoBrowser.h \
    linboLogConsole.h \
    linboMulticastBox.h \
    linbooswidget.h \
    linboimagewidget.h \
    login.h \
    consolewidget.h \
    folgeaktion.h \
    downloadtype.h

FORMS    += linbogui.ui\
    registrierungsdialog.ui \
    fortschrittdialog.ui \
    linboConsole.ui \
    linboImageSelector.ui \
    linboImageUpload.ui \
    linboInfoBrowser.ui \
    linboMulticastBox.ui \
    linbooswidget.ui \
    linboimagewidget.ui \
    login.ui

RESOURCES += \
    linbo_icons.qrc \
    linbooswidget_icons.qrc
