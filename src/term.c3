module c3fm;

import std::io;
import libc;
import libc::termios;

faultdef TERMINAL_ERROR;

enum Key {
  UNKNOWN,
  QUIT,
  UP,
  DOWN,
  ENTER,
}

struct Terminal {
  termios::Termios original;
}

fn void? terminal_init(Terminal* terminal) {
  enable_raw_mode(terminal)!;
  show_alt_screen();
  hide_cursor();
  return;
}

fn void terminal_deinit(Terminal* terminal) {
  show_cursor();
  leave_alt_screen();
  restore_terminal(terminal);
}


fn Key? terminal_read_key() {
  char c;
  sz n = libc::read(libc::STDIN_FD, &c, 1);

  if (n <= 0) {
    return TERMINAL_ERROR~;
  }

  switch (c) {
  case 'q':
    return QUIT;

  case 'j':
    return DOWN;

  case 'k':
    return UP;

  case '\n':
  case '\r':
    return ENTER;

  default:
    return UNKNOWN;
  }
}

fn void? enable_raw_mode(Terminal* terminal) {
  if (terminal.original.get_attr(libc::STDIN_FD) != 0) {
    return TERMINAL_ERROR~;
  }

  termios::Termios raw = terminal.original;

  raw.c_lflag.icanon = false; // no line buffering
  raw.c_lflag.echo = false; // dont echo typed keys

  raw.c_cc[(int)termios::Cc.VMIN] = (termios::Cc)1;
  raw.c_cc[(int)termios::Cc.VTIME] = (termios::Cc)0;

  if (raw.set_attr(libc::STDIN_FD, termios::Tcactions.TCSANOW) != 0) {
    return TERMINAL_ERROR~;
  }
}

fn void show_alt_screen() {
  io::print("\x1b[?1049h");
}

fn void hide_cursor() {
  io::print("\x1b[?251");
}

fn void show_cursor() {
  io::print("\x1b[?25h");
}

fn void leave_alt_screen() {
  io::print("\x1b[?1049l");
}

fn void restore_terminal(Terminal* terminal) {
  terminal.original.set_attr(libc::STDIN_FD, termios::Tcactions.TCSANOW);
}
