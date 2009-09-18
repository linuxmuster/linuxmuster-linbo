/****************************************************************************
** Meta object code from reading C++ file 'linboGUIImpl.hh'
**
** Created: Fri Sep 18 10:36:55 2009
**      by: The Qt Meta Object Compiler version 61 (Qt 4.5.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "linboGUIImpl.hh"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'linboGUIImpl.hh' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 61
#error "This file was generated using the moc from 4.5.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_linboGUIImpl[] = {

 // content:
       2,       // revision
       0,       // classname
       0,    0, // classinfo
      11,   12, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors

 // slots: signature, parameters, type, tag, flags
      14,   13,   13,   13, 0x0a,
      31,   13,   13,   13, 0x0a,
      48,   13,   13,   13, 0x0a,
      64,   13,   13,   13, 0x0a,
      79,   13,   13,   13, 0x0a,
      96,   13,   13,   13, 0x0a,
     118,   13,   13,   13, 0x0a,
     139,   13,   13,   13, 0x0a,
     156,   13,   13,   13, 0x0a,
     175,   13,   13,   13, 0x0a,
     186,   13,   13,   13, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_linboGUIImpl[] = {
    "linboGUIImpl\0\0readFromStdout()\0"
    "readFromStderr()\0enableButtons()\0"
    "resetButtons()\0disableButtons()\0"
    "restoreButtonsState()\0tabWatcher(QWidget*)\0"
    "processTimeout()\0executeAutostart()\0"
    "shutdown()\0reboot()\0"
};

const QMetaObject linboGUIImpl::staticMetaObject = {
    { &QDialog::staticMetaObject, qt_meta_stringdata_linboGUIImpl,
      qt_meta_data_linboGUIImpl, 0 }
};

const QMetaObject *linboGUIImpl::metaObject() const
{
    return &staticMetaObject;
}

void *linboGUIImpl::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_linboGUIImpl))
        return static_cast<void*>(const_cast< linboGUIImpl*>(this));
    if (!strcmp(_clname, "Ui::linboGUI"))
        return static_cast< Ui::linboGUI*>(const_cast< linboGUIImpl*>(this));
    return QDialog::qt_metacast(_clname);
}

int linboGUIImpl::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QDialog::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: readFromStdout(); break;
        case 1: readFromStderr(); break;
        case 2: enableButtons(); break;
        case 3: resetButtons(); break;
        case 4: disableButtons(); break;
        case 5: restoreButtonsState(); break;
        case 6: tabWatcher((*reinterpret_cast< QWidget*(*)>(_a[1]))); break;
        case 7: processTimeout(); break;
        case 8: executeAutostart(); break;
        case 9: shutdown(); break;
        case 10: reboot(); break;
        default: ;
        }
        _id -= 11;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
