module c3fm;
import std::io;
import std::io::path;

macro void typeof(thing) {
  io::printfn("Type: %s", $Typeof(thing)::name);
  return;
}

fn int main(String[] args) {

  (void)args;

  // arena allocator
  char[4096] arena_storage;
  ArenaAllocator arena;

  arena.init(&arena_storage);

  AppState state = c3fm_init(&arena)!!;

  Terminal terminal;
  terminal_init(&terminal)!!;
  defer terminal_deinit(&terminal);

  while (true) {
    render(&state);

    Key key = terminal_read_key()!!;
    if (c3fm_handle_key(&state, key)) break;
  }

  //
  arena.clear();
  return 0;
}
