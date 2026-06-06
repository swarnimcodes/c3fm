module c3fm;

import std::io;


fn void render(AppState* state)
{
  io::print("\x1b[2J");
  io::print("\x1b[H");

  io::printfn("\n%s%s%s\n", Ansi.CYAN, (String)state.cwd, Ansi.RESET);

  foreach (i, entry : state.entries) {
      if (i == state.highlighted) {
        io::printfn("> %s", (String)entry);
      } else {
        io::printfn("  %s", (String)entry);
      }
  }

  io::printfn("\n\n%sLast Log:%s %s", Ansi.RED, Ansi.RESET, state.log);
}
