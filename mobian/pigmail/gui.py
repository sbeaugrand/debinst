# ---------------------------------------------------------------------------- #
## \file gui.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Python Imap Gtk Mail
# ---------------------------------------------------------------------------- #
import html
from os import path
from time import sleep

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gio
while not Gtk.init_check():
    sleep(60)

from mail import *
from mlog import *
from plog import *

exec(open('user-pr-config.py').read())


# ---------------------------------------------------------------------------- #
## \fn on_button_kill
# ---------------------------------------------------------------------------- #
def on_button_kill(widget, window, plog):
    plog.kill()
    plog.unlink()
    window.close()


# ---------------------------------------------------------------------------- #
## \fn gui_status_box
# ---------------------------------------------------------------------------- #
def gui_status_box(plog=None):
    window = Gtk.Window()
    window.set_title('Python Imap Gtk Mail')
    window.set_default_size(WIDTH, HEIGHT)
    window.connect('delete-event', Gtk.main_quit)
    scrolled = Gtk.ScrolledWindow()
    textview = Gtk.TextView()
    textview.set_editable(False)
    textview.set_cursor_visible(False)
    buff = textview.get_buffer()
    scrolled.add(textview)
    buff.set_text(ELog.read())
    vbox = Gtk.Box.new(Gtk.Orientation.VERTICAL, 5)
    vbox.pack_start(scrolled, True, True, 0)
    window.add(vbox)
    hbox = Gtk.Box.new(Gtk.Orientation.HORIZONTAL, 5)
    buttonClose = Gtk.Button(label='Fermer')
    buttonClose.connect('clicked', lambda x: window.close())
    hbox.pack_start(buttonClose, True, True, 0)
    if plog is not None:
        buttonKill = Gtk.Button(label='Quitter')
        buttonKill.connect('clicked', on_button_kill, window, plog)
        hbox.pack_start(buttonKill, True, True, 0)
    vbox.pack_start(hbox, True, True, 0)
    Gtk.Widget.set_size_request(scrolled, WIDTH, HEIGHT - 80)
    window.show_all()
    textview.scroll_to_mark(buff.get_insert(), 0.0, True, 0.0, 1.0)
    Gtk.main()


# ---------------------------------------------------------------------------- #
## \fn gui_buffer_set_text
# ---------------------------------------------------------------------------- #
def gui_buffer_set_text(buff, text, mail):
    buff.set_text(mail.headerDate)
    buff.insert_markup(
        buff.get_end_iter(),
        '\n<span color="green">{}</span>\n<span color="yellow">{}</span>\n'.
        format(html.escape(mail.headerFrom),
               html.escape(mail.headerSubject)), -1)
    if mail.err is not None:
        buff.insert_markup(
            buff.get_end_iter(),
            '<span color="red">{}</span>\n'.format(html.escape(mail.err)), -1)
        mail.err = None
    while True:
        i = text.find('http')
        if i < 0:
            break
        buff.insert(buff.get_end_iter(),
                    html.unescape(text[:i].replace('=\x0D', '')) + '(lien)')
        while i < len(text):
            if text[i].isspace():
                break
            i += 1
        text = text[i:]
    buff.insert(buff.get_end_iter(), html.unescape(text.replace('=\x0D', '')))
    buff.insert_markup(
        buff.get_end_iter(), '''
            <span font="monospace" color="pink">
             ^..^
            ( oo )  )~
              ,,  ,,     pigmail</span>
            ''', -1)


# ---------------------------------------------------------------------------- #
## \fn on_button_cont
# ---------------------------------------------------------------------------- #
def on_button_cont(widget, textview, mail):
    if mail.offset >= 0:
        vadj = textview.get_parent().get_vadjustment()
        vval = vadj.get_value()
        buff = textview.get_buffer()
        gui_buffer_set_text(buff, mail.fetch_part(), mail)
        if vval > 0:
            while Gtk.events_pending():
                Gtk.main_iteration()
            vadj.set_value(vval)
        if mail.eof:
            widget.set_sensitive(False)


# ---------------------------------------------------------------------------- #
## \fn on_button_seen
# ---------------------------------------------------------------------------- #
def on_button_seen(widget, window, mail):
    mail.map.noop()
    mail.mlog.append()
    window.get_application().withdraw_notification('new-message')
    window.close()


# ---------------------------------------------------------------------------- #
## \fn on_button_trash
# ---------------------------------------------------------------------------- #
def on_button_trash(widget, window, mail):
    mail.imap.move(mail.num, BOX_TRASH)
    window.get_application().withdraw_notification('new-message')
    window.close()


# ---------------------------------------------------------------------------- #
## \fn on_button_archive
# ---------------------------------------------------------------------------- #
def on_button_archive(widget, window, mail):
    mail.imap.move(mail.num, BOX_ARCHIVE)
    window.get_application().withdraw_notification('new-message')
    window.close()


# ---------------------------------------------------------------------------- #
## \fn on_activate
# ---------------------------------------------------------------------------- #
def on_activate(app, text, mail):
    while True:
        try:
            window = Gtk.ApplicationWindow.new(app)
            break
        except Exception as e:
            perror(e, 'window new')
            sleep(60)
    window.set_title('Python Imap Gtk Mail')
    window.set_default_size(WIDTH, HEIGHT)
    scrolled = Gtk.ScrolledWindow()
    textview = Gtk.TextView()
    textview.set_wrap_mode(Gtk.WrapMode.WORD)
    textview.set_editable(False)
    textview.set_cursor_visible(False)
    buff = textview.get_buffer()
    scrolled.add(textview)
    gui_buffer_set_text(buff, text, mail)
    vbox = Gtk.Box.new(Gtk.Orientation.VERTICAL, 5)
    vbox.pack_start(scrolled, True, True, 0)
    window.add(vbox)
    hbox = Gtk.Box.new(Gtk.Orientation.HORIZONTAL, 5)
    buttonCont = Gtk.Button(label=BTN_CONT)
    buttonCont.connect('clicked', on_button_cont, textview, mail)
    if mail.eof:
        buttonCont.set_sensitive(False)
    hbox.pack_start(buttonCont, True, True, 0)
    buttonSeen = Gtk.Button(label=BTN_SEEN)
    buttonSeen.connect('clicked', on_button_seen, window, mail)
    hbox.pack_start(buttonSeen, True, True, 0)
    buttonArchive = Gtk.Button(label=BTN_ARCHIVE)
    buttonArchive.connect('clicked', on_button_archive, window, mail)
    hbox.pack_start(buttonArchive, True, True, 0)
    buttonTrash = Gtk.Button(label=BTN_TRASH)
    buttonTrash.connect('clicked', on_button_trash, window, mail)
    hbox.pack_start(buttonTrash, True, True, 0)
    vbox.pack_start(hbox, True, True, 0)
    Gtk.Widget.set_size_request(scrolled, WIDTH, HEIGHT - 80)
    window.show_all()
    action = Gio.SimpleAction.new('raise')
    action.connect('activate', lambda a, p, w: w.present(), window)
    app.add_action(action)
    notification = Gio.Notification()
    notification.set_title('Nouveau message de {}'.format(mail.headerFrom))
    notification.set_default_action('app.raise')
    app.send_notification('new-message', notification)


# ---------------------------------------------------------------------------- #
## \fn gui_mail_rx
# ---------------------------------------------------------------------------- #
def gui_mail_rx(text, mail):
    app = Gtk.Application(application_id=APP_ID)
    app.connect('activate', on_activate, text, mail)
    app.run()


# ---------------------------------------------------------------------------- #
## \fn on_activate_notification
# ---------------------------------------------------------------------------- #
def on_activate_notification(app):
    notification = Gio.Notification.new('Exception')
    app.send_notification(None, notification)


# ---------------------------------------------------------------------------- #
## \fn gui_notify_exception
# ---------------------------------------------------------------------------- #
def gui_notify_exception(app):
    app = Gtk.Application(application_id=APP_ID)
    app.connect('activate', on_activate_notification)
    app.run()
