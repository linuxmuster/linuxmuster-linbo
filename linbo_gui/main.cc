// STL-includes
#include <iostream>
#include <qwindowsystem_qws.h>
#include <qimage.h>
#include <qtimer.h>
#include <qgfx_qws.h>

// qt
#include <qapplication.h>
#include "linboGUIImpl.hh"

#include <qkbdpc101_qws.h>
void GermanKeyboard()
{
  QWSKeyboardHandler *kh=QWSServer::keyboardHandler();
  if(!kh) return;

  QWSKeyMap germanpc102[] = {
    { Qt::Key_unknown,    Qt::Key_unknown,    Qt::Key_unknown,     Qt::Key_unknown },
    { Qt::Key_Escape,     27,                 27,                  Qt::Key_unknown },
    { Qt::Key_1,          '1',                '!',                 Qt::Key_onesuperior },
    { Qt::Key_2,          '2',                '"',                 Qt::Key_twosuperior },
    { Qt::Key_3,          '3',                Qt::Key_section,     Qt::Key_threesuperior },
    { Qt::Key_4,          '4',                '$',                 Qt::Key_onequarter },
    { Qt::Key_5,          '5',                '%',                 Qt::Key_onehalf },
    { Qt::Key_6,          '6',                '&',                 Qt::Key_threequarters },
    { Qt::Key_7,          '7',                '/',                 '{' },
    { Qt::Key_8,          '8',                '(',                 '[' },
    { Qt::Key_9,          '9',                ')',                 ']' }, // 10
    { Qt::Key_0,          '0',                '=',                 '}' },
    { Qt::Key_Minus,      Qt::Key_ssharp,     '?',                 '\\' },
    { Qt::Key_Equal,      '`',                '`',                 Qt::Key_questiondown },
    { Qt::Key_Backspace,  8,                  8,                   Qt::Key_exclamdown },
    { Qt::Key_Tab,        9,                  9,                   Qt::Key_yen },
    { Qt::Key_Q,          'q',                'Q',                 '@' },
    { Qt::Key_W,          'w',                'W',                 Qt::Key_registered },
    { Qt::Key_E,          'e',                'E',                 Qt::Key_notsign },
    { Qt::Key_R,          'r',                'R',                 Qt::Key_paragraph },
    { Qt::Key_T,          't',                'T',                 Qt::Key_THORN }, // 20
    { Qt::Key_Y,          'z',                'Z',                 Qt::Key_ydiaeresis },
    { Qt::Key_U,          'u',                'U',                 Qt::Key_ucircumflex },
    { Qt::Key_I,          'i',                'I',                 Qt::Key_idiaeresis },
    { Qt::Key_O,          'o',                'O',                 Qt::Key_oslash },
    { Qt::Key_P,          'p',                'P',                 Qt::Key_thorn },
    { Qt::Key_BraceLeft,  Qt::Key_udiaeresis, Qt::Key_Udiaeresis,  Qt::Key_ucircumflex },
    { Qt::Key_BraceRight, '+',                '*',                 '~' },
    { Qt::Key_Return,     13,                 13 ,                 Qt::Key_unknown },
    { Qt::Key_Control,    Qt::Key_unknown,    Qt::Key_unknown,     Qt::Key_unknown },
    { Qt::Key_A,          'a',                'A',                 Qt::Key_ae }, // 30
    { Qt::Key_S,          's',                'S',                 Qt::Key_ssharp },
    { Qt::Key_D,          'd',                'D',                 Qt::Key_eth },
    { Qt::Key_F,          'f',                'F',                 Qt::Key_ediaeresis },
    { Qt::Key_G,          'g',                'G',                 'G'-64 },
    { Qt::Key_H,          'h',                'H',                 Qt::Key_ETH },
    { Qt::Key_J,          'j',                'J',                 Qt::Key_notsign },
    { Qt::Key_K,          'k',                'K',                 Qt::Key_ordfeminine },
    { Qt::Key_L,          'l',                'L',                 Qt::Key_copyright },
    { Qt::Key_Semicolon,  Qt::Key_odiaeresis, Qt::Key_Odiaeresis,  Qt::Key_ocircumflex },
    { Qt::Key_Apostrophe, Qt::Key_adiaeresis, Qt::Key_Adiaeresis,  Qt::Key_acircumflex }, // 40
    { Qt::Key_QuoteLeft,  '^',                Qt::Key_degree,      Qt::Key_sterling },
    { Qt::Key_Shift,      Qt::Key_unknown,    Qt::Key_unknown,     Qt::Key_unknown },
    { Qt::Key_Backslash,  '#',                '\'',                Qt::Key_brokenbar },
    { Qt::Key_Z,          'y',                'Y',                 Qt::Key_guillemotleft },
    { Qt::Key_X,          'x',                'X',                 Qt::Key_guillemotright },
    { Qt::Key_C,          'c',                'C',                 Qt::Key_cent },
    { Qt::Key_V,          'v',                'V',                 Qt::Key_section },
    { Qt::Key_B,          'b',                'B',                 Qt::Key_cedilla },
    { Qt::Key_N,          'n',                'N',                 Qt::Key_masculine },
    { Qt::Key_M,          'm',                'M',                 Qt::Key_mu    }, // 50
    { Qt::Key_Comma,      ',',                ';',                 Qt::Key_macron },
    { Qt::Key_Period,     '.',                ':',                 Qt::Key_periodcentered },
    { Qt::Key_Slash,      '-',                '_',                 Qt::Key_hyphen },
    { Qt::Key_Shift,      Qt::Key_unknown,    Qt::Key_unknown,     Qt::Key_unknown },
    { Qt::Key_Asterisk,   '*',                '*',                 Qt::Key_multiply },
    { Qt::Key_Alt,        Qt::Key_unknown,    Qt::Key_unknown,     Qt::Key_unknown },
    { Qt::Key_Space,      ' ',                ' ',                 Qt::Key_unknown },
    { Qt::Key_CapsLock,   Qt::Key_unknown,    Qt::Key_unknown,     Qt::Key_unknown },
    { Qt::Key_F1,         Qt::Key_F1,         Qt::Key_Agrave,      Qt::Key_agrave },
    { Qt::Key_F2,         Qt::Key_F2,         Qt::Key_Aacute,      Qt::Key_aacute }, // 60
    { Qt::Key_F3,         Qt::Key_F3,         Qt::Key_Acircumflex, Qt::Key_acircumflex },
    { Qt::Key_F4,         Qt::Key_F4,         Qt::Key_Atilde,      Qt::Key_atilde },
    { Qt::Key_F5,         Qt::Key_F5,         Qt::Key_AE,          Qt::Key_ae },
    { Qt::Key_F6,         Qt::Key_F6,         Qt::Key_Aring,       Qt::Key_aring },
    { Qt::Key_F7,         Qt::Key_F7,         Qt::Key_Yacute,      Qt::Key_yacute },
    { Qt::Key_F8,         Qt::Key_F8,         Qt::Key_Ccedilla,    Qt::Key_ccedilla },
    { Qt::Key_F9,         Qt::Key_F9,         Qt::Key_Egrave,      Qt::Key_egrave },
    { Qt::Key_F10,        Qt::Key_F10,        Qt::Key_Eacute,      Qt::Key_eacute },
    { Qt::Key_NumLock,    Qt::Key_unknown,    Qt::Key_Ecircumflex, Qt::Key_ecircumflex },
    { Qt::Key_ScrollLock, Qt::Key_unknown,    Qt::Key_Ediaeresis,  Qt::Key_ediaeresis }, // 70
    { Qt::Key_7,          '7',                Qt::Key_Igrave,      Qt::Key_igrave },
    { Qt::Key_8,          '8',                Qt::Key_Iacute,      Qt::Key_iacute },
    { Qt::Key_9,          '9',                Qt::Key_Icircumflex, Qt::Key_icircumflex },
    { Qt::Key_Minus,      '-',                '-',                 Qt::Key_plusminus },
    { Qt::Key_4,          '4',                Qt::Key_Idiaeresis,  Qt::Key_idiaeresis },
    { Qt::Key_5,          '5',                Qt::Key_Ograve,      Qt::Key_ograve },
    { Qt::Key_6,          '6',                Qt::Key_Oacute,      Qt::Key_oacute },
    { Qt::Key_Plus,       '+',                '+',                 Qt::Key_plusminus },
    { Qt::Key_1,          '1',                Qt::Key_Ocircumflex, Qt::Key_ocircumflex },
    { Qt::Key_2,          '2',                Qt::Key_Otilde,      Qt::Key_Otilde }, // 80
    { Qt::Key_3,          '3',                Qt::Key_Ooblique,    'o' },
    { Qt::Key_0,          '0',                Qt::Key_Ugrave,      Qt::Key_ugrave },
    { Qt::Key_Period,     '.',                Qt::Key_Ntilde,      Qt::Key_ntilde },
    { Qt::Key_unknown,    Qt::Key_unknown,    Qt::Key_unknown,     Qt::Key_unknown },
    { Qt::Key_unknown,    Qt::Key_unknown,    Qt::Key_unknown,     Qt::Key_unknown },
    { Qt::Key_Bar,        '<',                '>',                 '|'    },
    { Qt::Key_F11,        Qt::Key_unknown,    Qt::Key_Uacute,      Qt::Key_uacute },
    { Qt::Key_F12,        Qt::Key_unknown,    Qt::Key_Ucircumflex, Qt::Key_ucircumflex },
    { Qt::Key_unknown,    Qt::Key_unknown,    Qt::Key_unknown,     Qt::Key_unknown },
    { Qt::Key_unknown,    Qt::Key_unknown,    Qt::Key_unknown,     Qt::Key_unknown }, // 90
    { 0,                  Qt::Key_unknown,    Qt::Key_unknown,     Qt::Key_unknown }
  };
  kh->setKeyMap(germanpc102);
}


int main( int argc, char* argv[] )
{
  QColor black(0,0,0);

  QApplication myapp( argc, argv );
  bool backgroundpicture = true;

  if ( backgroundpicture ) {
    QImage myImage;

    myImage.load( "/usr/lib/linbo_wallpaper.png", "PNG" );

    int width = qt_screen->deviceWidth();
    int height = qt_screen->deviceHeight();

    qwsServer->setDesktopBackground( myImage.smoothScale ( width, height ) );
  }
 
  linboGUIImpl* w = new linboGUIImpl(0,"LINBO", 0, Qt::WStyle_Customize | Qt::WStyle_NoBorder );
  // linboGUIImpl* w = new linboGUIImpl(0,"LINBO", 0, Qt::WStyle_Customize | Qt::WStyle_Title  | Qt::WStyle_SysMenu | Qt::WStyle_MinMax | Qt::WStyle_Tool );
  // 
  // linboGUIImpl* w = new linboGUIImpl(0,"LINBO", 0, Qt::WStyle_Customize | Qt::WStyle_Tool );
  // linboGUIImpl* w = new linboGUIImpl(0,"LINBO", 0, Qt::WStyle_Tool );
  GermanKeyboard();
  w->show();
  w->setActiveWindow();

  myapp.setMainWidget( w );

  QTimer::singleShot( 100, w, SLOT(executeAutostart()) );
  

  return myapp.exec();
}
