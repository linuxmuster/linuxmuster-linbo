/* builds the class representing the LINBO configuration 

Copyright (C) 2007 Klaus Knopper <knopper@knopper.net>
Copyright (C) 2008 Martin Oehler <oehler@knopper.net>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

*/

#ifndef IMAGE_DESCRIPTION_HH
#define IMAGE_DESCRIPTION_HH

#include <qstring.h>
#include <vector>
#include <iostream>

using namespace std;

class globals {
private:
  QString server, cache, hostgroup, downloadtype, backgroundfontcolor, consolefontcolorstdout, consolefontcolorstderr;
  QString kerneloptions,systemtype;
  unsigned int roottimeout;
  bool autopartition, autoinitcache, autoformat;
  QString hd; /* save cache device hd calculated from cache separate for easier reference */

public:
  globals();
  ~globals();
  const QString& get_server() const;
  const QString& get_cache() const;
  const QString& get_hd() const;
  const QString& get_hostgroup() const;
  const QString& get_kerneloptions() const;
  const QString& get_systemtype() const;
  const unsigned int& get_roottimeout() const;
  const bool& get_autopartition();
  const bool& get_autoinitcache();
  const QString& get_backgroundfontcolor();
  const QString& get_consolefontcolorstdout();
  const QString& get_consolefontcolorstderr();
  const QString& get_downloadtype();
  const bool& get_autoformat();
  void set_server( const QString& new_server );
  void set_cache( const QString& new_cache );
  void set_hostgroup( const QString& new_hostgroup );
  void set_kerneloptions( const QString& new_kerneloptions );
  void set_systemtype( const QString& new_systemtype );
  void set_roottimeout( const unsigned int& new_roottimeout );
  void set_autopartition( const bool& new_autopartition );
  void set_autoinitcache( const bool& new_autoinitcache );
  void set_backgroundfontcolor( const QString& new_backgroundfontcolor );
  void set_consolefontcolorstdout( const QString& new_consolefontcolorstdout );
  void set_consolefontcolorstderr( const QString& new_consolefontcolorstderr );
  void set_downloadtype( const QString& new_downloadtype );
  void set_autoformat( const bool& new_autoformat );
};

class diskpartition {
private:
  QString dev, id, fstype, size, label;
  bool bootable;

public:
  diskpartition();
  ~diskpartition();
  const QString& get_dev() const;
  const QString& get_id() const;
  const QString& get_fstype() const;
  const QString& get_size() const;
  const QString& get_label() const;
  const bool& get_bootable() const;
  void set_dev( const QString& new_dev );
  void set_id( const QString& new_id );
  void set_fstype( const QString& new_fstype );
  void set_size( const QString& new_size );
  void set_label( const QString& new_label );
  void set_bootable( const bool& new_bootable );
};

class image_item {
private:
  QString version,
    description,
    image,
    kernel,
    initrd,
    append,
    defaultaction;
  int autostarttimeout;
  bool syncbutton, startbutton, newbutton, autostart,
    hidden; // show OS tab or not

public:
  image_item();
  ~image_item();
  void set_version( const QString& new_version );
  void set_description ( const QString& new_description );
  void set_image( const QString& new_imagename);
  void set_kernel( const QString& new_kernel );
  void set_initrd( const QString& new_initrd );
  void set_append( const QString& new_append );
  void set_syncbutton ( const bool& new_syncbutton );
  void set_startbutton( const bool& new_startbutton);
  void set_newbutton  ( const bool& new_newbutton );
  void set_autostart  ( const bool& new_autostart );
  void set_autostarttimeout ( const int& new_autostarttimeout );
  void set_defaultaction  ( const QString& new_defaultaction );
  void set_hidden  ( const bool& new_hidden );

  const QString& get_version() const;
  const QString& get_description() const;
  const QString& get_image() const;
  const QString& get_kernel() const;
  const QString& get_initrd() const;
  const QString& get_append() const;
  const bool& get_syncbutton() const;
  const bool& get_startbutton() const;
  const bool& get_newbutton() const;
  const bool& get_autostart() const;
  const int& get_autostarttimeout() const;
  const QString& get_defaultaction() const;
  const bool& get_hidden() const;
};

class os_item {
private:
  QString name, // OS Name
	  baseimage, // Base Image
	  iconname, // Thumbnail for Image
	  boot, // Boot partition
	  root; // Root partition

public:
  os_item();
  ~os_item();

  void set_name( const QString& new_name );
  void set_baseimage( const QString& new_baseimage );
  void set_iconname( const QString& new_iconname );
  void set_boot( const QString& new_boot );
  void set_root( const QString& new_root );

  const QString& get_name() const;
  const QString& get_baseimage() const;
  const QString& get_iconname() const;
  const QString& get_boot() const;
  const QString& get_root() const;

  unsigned int find_current_image() const;
  void add_history_entry( image_item& ie );
  vector< image_item > image_history; // One or more images
};

#endif
