TARGET  = linbo_gui

CFLAGS += -DQWS -static

FORMS =   linboCounter.ui \
          linboImageUpload.ui \
          linboMulticastBox.ui \
          linboInfoBrowser.ui \
          linboPasswordBox.ui \
          linboGUI.ui \
          linboInputBox.ui \
          linboProgress.ui \
          linboImageSelector.ui \
          linboMsg.ui \
          linboRegisterBox.ui \
          linboConsole.ui \
          linboYesNo.ui

HEADERS = image_description.hh \
          linboImageUploadImpl.hh \
          linboMulticastBoxImpl.hh \ 
          linboInfoBrowserImpl.hh \
          linboPasswordBoxImpl.hh \
          linboRegisterBoxImpl.hh \
          linboGUIImpl.hh \
          linboConsoleImpl.hh \
          linboInputBoxImpl.hh \
          linboProgressImpl.hh \
          linboImageSelectorImpl.hh \
          linboPushButton.hh \
          linboMsgImpl.hh \
          linboYesNoImpl.hh 
          

SOURCES = image_description.cc \
          linboImageUploadImpl.cc \
          moc_linboImageUploadImpl.cc \
          linboMulticastBoxImpl.cc \
          moc_linboMulticastBoxImpl.cc \
          linboRegisterBoxImpl.cc \
          moc_linboRegisterBoxImpl.cc \
          linboInfoBrowserImpl.cc \
          moc_linboInfoBrowserImpl.cc \
          linboPasswordBoxImpl.cc \
          moc_linboPasswordBoxImpl.cc \
          linboGUIImpl.cc \
          moc_linboGUIImpl.cc \
          linboConsoleImpl.cc \
          moc_linboConsoleImpl.cc \
          linboInputBoxImpl.cc \
          moc_linboInputBoxImpl.cc \
          linboProgressImpl.cc \
          moc_linboProgressImpl.cc \
          linboImageSelectorImpl.cc \
          moc_linboImageSelectorImpl.cc \
          linboPushButton.cc \
          moc_linboPushButton.cc \
          linboMsgImpl.cc \
          moc_linboMsgImpl.cc \
          linboYesNoImpl.cc \
          moc_linboYesNoImpl.cc \
          moc_linboProgress.cc \
          moc_linboYesNo.cc \
          moc_linboPasswordBox.cc \
          moc_linboMulticastBox.cc \
          moc_linboMsg.cc \
          moc_linboInputBox.cc \
          moc_linboRegisterBox.cc \
          moc_linboInfoBrowser.cc \
          moc_linboImageUpload.cc \
          moc_linboImageSelector.cc \
          moc_linboGUI.cc \
          moc_linboCounter.cc \
          moc_linboConsole.cc \
          main.cc