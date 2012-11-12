TARGET = linbo_gui
DEPENDPATH += .
INCLUDEPATH += .
CFLAGS += -DQWS -static
QT += qt3support
QMAKE_POST_LINK=strip $(TARGET)
RESOURCES = linbo.qrc

# Input
HEADERS += image_description.hh \
           linboConsoleImpl.hh \
           linboCounterImpl.hh \
           linboGUIImpl.hh \
           linboImageSelectorImpl.hh \
           linboImageUploadImpl.hh \
           linboInfoBrowserImpl.hh \
           linboInputBoxImpl.hh \
           linboMsgImpl.hh \
           linboMulticastBoxImpl.hh \
           linboPasswordBoxImpl.hh \
           linboProgressImpl.hh \
           linboPushButton.hh \
	   linboLogConsole.hh \
           linboRegisterBoxImpl.hh \
           linboYesNoImpl.hh 

FORMS += linboConsole.ui \
         linboCounter.ui \
         linboGUI.ui \
         linboImageSelector.ui \
         linboImageUpload.ui \
         linboInfoBrowser.ui \
         linboInputBox.ui \
         linboMovie.ui \
         linboMsg.ui \
         linboMulticastBox.ui \
         linboPasswordBox.ui \
         linboProgress.ui \
         linboRegisterBox.ui \
         linboYesNo.ui 

SOURCES += image_description.cc \
           linboConsoleImpl.cc \
           linboCounterImpl.cc \
           linboGUIImpl.cc \
           linboImageSelectorImpl.cc \
           linboImageUploadImpl.cc \
           linboInfoBrowserImpl.cc \
           linboInputBoxImpl.cc \
           linboMsgImpl.cc \
           linboMulticastBoxImpl.cc \
           linboPasswordBoxImpl.cc \
           linboProgressImpl.cc \
           linboPushButton.cc \
	   linboLogConsole.cc \
           linboRegisterBoxImpl.cc \
           linboYesNoImpl.cc \
           main.cc
