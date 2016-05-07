#-------------------------------------------------
#
# Project created by QtCreator 2016-02-17T17:53:31
#
#-------------------------------------------------

QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = linbo_gui
TEMPLATE = app

QMAKE_CXXFLAGS = $$(CXXFLAGS) -std=c++11
QMAKE_LFLAGS = $$(LDFLAGS)

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
    downloadtype.cpp \
    autostart.cpp \
    aktion.cpp

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
    downloadtype.h \
    autostart.h \
    aktion.h

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
    login.ui \
    autostart.ui

RESOURCES += \
    linbo_icons.qrc \
    linbooswidget_icons.qrc
