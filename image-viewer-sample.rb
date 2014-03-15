#!/usr/bin/env ruby

require "gtk2"

window = Gtk::Window.new
window.title = "Image Viewer sample"
window.set_default_size(640, 480)
window.signal_connect("destroy") do
  Gtk.main_quit
end

scrolled_window = Gtk::ScrolledWindow.new
scrolled_window.set_policy(:automatic, :automatic)
window.add(scrolled_window)

hbox = Gtk::HBox.new(false, 8)
hbox.border_width = 8
scrolled_window.add_with_viewport(hbox)

menu = Gtk::Menu.new
menu_item = Gtk::ImageMenuItem.new(Gtk::Stock::DELETE)
menu_item.signal_connect("activate") do
  hbox.remove(menu.attach_widget)
end
menu.append(menu_item)
menu.show_all

ARGV.each do |path_or_wildcard|
  Dir.glob(File.expand_path(path_or_wildcard)) do |path|
    begin
      pixbuf = Gdk::Pixbuf.new(path)
    rescue GLib::FileError, Gdk::PixbufError
      $stderr.puts($!.message)
      next
    end

    event_box = Gtk::EventBox.new
    event_box.signal_connect("button-press-event") do |widget, event|
      if event.kind_of?(Gdk::EventButton) and event.button == 3
        menu.attach_widget = widget
        menu.popup(nil, nil, event.button, event.time)
      end
    end
    hbox.add(event_box)

    image = Gtk::Image.new
    image.pixbuf = pixbuf
    event_box.add(image)
  end
end

window.show_all

Gtk.main
