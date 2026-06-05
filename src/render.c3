module c3fm;

import std::io;

fn void render(AppState* state)
{
  io::print("\x1b[2J");
  io::print("\x1b[H");

  io::printfn("%s", (String)state.cwd);

  foreach (i, entry : state.entries) {
      if (i == state.selected) {
        io::printfn("> %s", (String)entry);
      }
      else {
        io::printfn("  %s", (String)entry);
      }
  }
}
