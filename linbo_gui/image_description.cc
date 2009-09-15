#include "image_description.hh"

globals::globals():roottimeout(120) {
  autopartition = 0;
  autoinitcache = 0;
  usemulticast = 0;
  autoformat = 0;
}
globals::~globals() {}
const QString& globals::get_server() const { return server; }
const QString& globals::get_cache() const { return cache; }
const QString& globals::get_hostgroup() const { return hostgroup; }
const unsigned int globals::get_roottimeout() const { return roottimeout; }
const bool& globals::get_autopartition() { return autopartition; };
const bool& globals::get_autoinitcache() { return autoinitcache; };
const bool& globals::get_usemulticast() { return usemulticast; };
const bool& globals::get_autoformat() { return autoformat; };
void globals::set_server( const QString& new_server ) { server = new_server; }
void globals::set_cache( const QString& new_cache ) { cache = new_cache; }
void globals::set_hostgroup( const QString& new_hostgroup ) { hostgroup = new_hostgroup; }
void globals::set_roottimeout( const unsigned int& new_roottimeout ) { roottimeout = new_roottimeout; }
void globals::set_autopartition( const bool& new_autopartition ) { autopartition = new_autopartition; };
void globals::set_autoinitcache( const bool& new_autoinitcache ) { autoinitcache = new_autoinitcache; };
void globals::set_usemulticast( const bool& new_usemulticast ) { usemulticast = new_usemulticast; };
void globals::set_autoformat( const bool& new_autoformat ) { autoformat = new_autoformat; };



diskpartition::diskpartition() {}
diskpartition::~diskpartition() {}
const QString& diskpartition::get_dev() const { return dev; }
const QString& diskpartition::get_id() const { return id; }
const QString& diskpartition::get_fstype() const { return fstype; }
const unsigned int diskpartition::get_size() const { return size; }
const bool& diskpartition::get_bootable() const { return bootable; }
void diskpartition::set_dev( const QString& new_dev ) { dev = new_dev; }
void diskpartition::set_id( const QString& new_id ) { id = new_id; }
void diskpartition::set_fstype( const QString& new_fstype ) { fstype = new_fstype; }
void diskpartition::set_size( const unsigned int& new_size ) { size = new_size; }
void diskpartition::set_bootable( const bool& new_bootable ) { bootable = new_bootable; }

image_item::image_item() { autostart = false; hidden = false; }
image_item::~image_item() {}
const QString& image_item::get_version() const { return version; }
const QString& image_item::get_description() const { return description; }
const QString& image_item::get_image() const { return image; }
const QString& image_item::get_kernel() const { return kernel; }
const QString& image_item::get_initrd() const { return initrd; }
const QString& image_item::get_append() const { return append; }
const bool& image_item::get_syncbutton() const { return syncbutton; }
const bool& image_item::get_startbutton() const { return startbutton; }
const bool& image_item::get_newbutton() const { return newbutton; }
const bool& image_item::get_autostart() const { return autostart; }
const bool& image_item::get_hidden() const { return hidden; }

void image_item::set_version( const QString& new_version ) { version = new_version; }
void image_item::set_description( const QString& new_description ) { description = new_description; }
void image_item::set_image( const QString& new_image ) { image = new_image; }
void image_item::set_kernel( const QString& new_kernel ) { kernel = new_kernel; }
void image_item::set_initrd( const QString& new_initrd ) { initrd = new_initrd; }
void image_item::set_append( const QString& new_append ) { append = new_append; }
void image_item::set_syncbutton( const bool& new_syncbutton ) { syncbutton = new_syncbutton; }
void image_item::set_startbutton( const bool& new_startbutton ) { startbutton = new_startbutton; }
void image_item::set_newbutton( const bool& new_newbutton ) { newbutton = new_newbutton; }
void image_item::set_autostart( const bool& new_autostart ) { autostart = new_autostart; }
void image_item::set_hidden( const bool& new_hidden ) { hidden = new_hidden; }

os_item::os_item() { image_history.clear(); }
os_item::~os_item() { /* nothing to do */ }

const QString& os_item::get_name() const { return name; }
const QString& os_item::get_baseimage() const { return baseimage; }
const QString& os_item::get_boot() const { return boot; }
const QString& os_item::get_root() const { return root; }
const QString& os_item::get_logopath() const { return logopath; }


void os_item::set_name( const QString& new_name ) { name = new_name; }
void os_item::set_baseimage( const QString& new_baseimage ) { baseimage = new_baseimage; }
void os_item::set_boot( const QString& new_boot ) { boot = new_boot; }
void os_item::set_root( const QString& new_root ) { root = new_root; }
void os_item::set_logopath( const QString& new_logopath ) { logopath = new_logopath; }
void os_item::add_history_entry( image_item& ie ) { image_history.push_back( ie ); }


// Return the first image in image_history where "start" is enabled.
const unsigned int os_item::find_current_image() const {
 for(unsigned int i; i < image_history.size(); i++) {
  if(image_history[i].get_startbutton()) return i;
 }
 return 0;
}

