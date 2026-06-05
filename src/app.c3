module c3fm;

import std::io::path;

struct AppState {
       Path cwd;
       PathList entries;
       sz selected;
}

fn AppState? c3fm_init(Allocator allocator) {
   Path cwd = path::cwd(allocator)!;
   PathList entries = path::ls(allocator, cwd)!;

   return {
    .cwd = cwd,
    .entries = entries,
    .selected = 0,
  };
}


fn bool c3fm_handle_key(AppState* state, Key key) {
   switch (key) {
   case QUIT:
        return true;
   case DOWN:
        if (state.selected + 1 < state.entries.size) state.selected++;
   case UP:
        if (state.selected > 0) state.selected--;
   default:
  }
  return false;
}
