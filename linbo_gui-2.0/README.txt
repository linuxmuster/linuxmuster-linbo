linbo_gui
=========

Test/Debug
----------
Falls nicht die Systeminstallation von Qt5 verwendet wird, muss der Pfad zu den Platform-Plugins
zu QtCreators Run-Umgebung hinzugefügt werden, also
QT_QPA_PLATFORM_PLUGIN_PATH=<Pfad zum Qt-Verzeichnis>/5.8/plugins/platforms

Damit das GUI die Testversion von "linbo_cmd" findet, muss das test-Verzeichnis zum Pfad hinzugefügt
werden, also
PATH=<Pfad zum oss-linbo-Verzeichnis/linbo_gui/test:...
