#ifndef IMAGE_DESCRIPTION_HH
#define IMAGE_DESCRIPTION_HH

#include <qstring.h>
#include <vector>
#include <iostream>

using namespace std;

class globals {
private:
  QString server, cache, hostgroup;
  unsigned int roottimeout;
  bool autopartition, autoinitcache, usemulticast, autoformat;
public:
  globals();
  ~globals();
  const QString& get_server() const;
  const QString& get_cache() const;
  const QString& get_hostgroup() const;
  const unsigned int get_roottimeout() const;
  const bool& get_autopartition();
  const bool& get_autoinitcache();
  const bool& get_usemulticast();
  const bool& get_autoformat();
  void set_server( const QString& new_server );
  void set_cache( const QString& new_cache );
  void set_hostgroup( const QString& new_hostgroup );
  void set_roottimeout( const unsigned int& new_roottimeout );
  void set_autopartition( const bool& new_autopartition );
  void set_autoinitcache( const bool& new_autoinitcache );
  void set_usemulticast( const bool& new_usemulticast );
  void set_autoformat( const bool& new_autoformat );
};

class diskpartition {
private:
  QString dev, id, fstype;
  unsigned int size;
  bool bootable;

public:
  diskpartition();
  ~diskpartition();
  const QString& get_dev() const;
  const QString& get_id() const;
  const QString& get_fstype() const;
  const unsigned int get_size() const;
  const bool& get_bootable() const;
  void set_dev( const QString& new_dev );
  void set_id( const QString& new_id );
  void set_fstype( const QString& new_fstype );
  void set_size( const unsigned int& new_size );
  void set_bootable( const bool& new_bootable );
};

class image_item {
private:
  QString version,
	  description,
	  image,
	  kernel,
	  initrd,
	  append;
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
  const bool& get_hidden() const;
};

class os_item {
private:
  QString name, // OS Name
	  baseimage, // Base Image
	  logopath, // Thumbnail for Image
	  boot, // Boot partition
	  root; // Root partition

public:
  os_item();
  ~os_item();

  void set_name( const QString& new_name );
  void set_baseimage( const QString& new_baseimage );
  void set_logopath( const QString& new_logopath );
  void set_boot( const QString& new_boot );
  void set_root( const QString& new_root );

  const QString& get_name() const;
  const QString& get_baseimage() const;
  const QString& get_logopath() const;
  const QString& get_boot() const;
  const QString& get_root() const;

  const unsigned int find_current_image() const;
  void add_history_entry( image_item& ie );
  vector< image_item > image_history; // One or more images
};

#endif
