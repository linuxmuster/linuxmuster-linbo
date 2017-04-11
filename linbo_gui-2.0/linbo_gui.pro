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
    linboLogConsole.cpp \
    linboMulticastBox.cpp \
    linboConsole.cpp \
    linbooswidget.cpp \
    linboimagewidget.cpp \
    login.cpp \
    consolewidget.cpp \
    downloadtype.cpp \
    autostart.cpp \
    aktion.cpp \
    commandline.cpp \
    ip4validator.cpp \
    linboremote.cpp \
    filtertime.cpp \
    filterregex.cpp \
    filter.cpp \
    linboDescBrowser.cpp

HEADERS  += linbogui.h\
    registrierungsdialog.h \
    fortschrittdialog.h \
    configuration.h \
    command.h \
    image_description.h \
    linboConsole.h \
    linboImageSelector.h \
    linboImageUpload.h \
    linboLogConsole.h \
    linboMulticastBox.h \
    linbooswidget.h \
    linboimagewidget.h \
    login.h \
    consolewidget.h \
    downloadtype.h \
    autostart.h \
    aktion.h \
    commandline.h \
    ip4validator.h \
    linboremote.h \
    filtertime.h \
    filterregex.h \
    filter.h \
    linboDescBrowser.h

FORMS    += linbogui.ui\
    registrierungsdialog.ui \
    fortschrittdialog.ui \
    linboConsole.ui \
    linboImageSelector.ui \
    linboImageUpload.ui \
    linboMulticastBox.ui \
    linbooswidget.ui \
    linboimagewidget.ui \
    login.ui \
    autostart.ui \
    linboDescBrowser.ui

RESOURCES += \
    linbo_icons.qrc \
    linbooswidget_icons.qrc

DISTFILES += \
    test/fake_cmd_create.sh \
    test/fake_cmd_functions.sh \
    test/fake_cmd.sh \
    test/linbo_cmd \
    test/start.conf \
    test/fake_cmd_upload.sh \
    test/fake_cmd_initcache.sh
