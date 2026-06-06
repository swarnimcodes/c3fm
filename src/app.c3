module c3fm;

import std::io::path;

struct AppState {
  Path cwd;
  PathList entries;
  sz highlighted;
  String log;
}

fn AppState? c3fm_init(ArenaAllocator* allocator) {
  Path cwd = path::cwd(allocator)!;
  path::chdir(cwd)!!;
  PathList entries = path::ls(allocator, cwd)!;

  return {
      .cwd = cwd,
      .entries = entries,
      .highlighted = 0,
      .log = "",
  };
}

fn bool c3fm_handle_key(ArenaAllocator *allocator, AppState *state, Key key) {
  switch (key) {
  case QUIT:
    return true;
  case DOWN:
    if (state.highlighted + 1 < state.entries.size) {
      state.highlighted++;
    }
  case UP:
    if (state.highlighted > 0) {
      state.highlighted--;
    }
  case ENTER:
    Path current_highlighted_abs_path = path::tnew(string::tformat("%s/%s", state.cwd, state.entries[state.highlighted]))!!;

    if (path::is_dir(current_highlighted_abs_path)) {
      state.log = "dir";
      state.highlighted = 0;
      state.cwd = current_highlighted_abs_path;
      path::chdir(state.cwd) !!;
      typeof(allocator);
      sz mark = allocator.mark();
      state.entries = path::ls(allocator, state.cwd) !!;
      allocator.reset(mark);
    } else if (path::is_file(current_highlighted_abs_path)) {
      state.log = "file";
    } else {
      state.log = "UNHANDLED CASE: highlighted entry is neither a file nor a directory?";
    }

  case BACK:
    path::chdir("..")!!;
    sz mark = allocator.mark();
    state.cwd = path::cwd(allocator)!!;
    state.entries = path::ls(allocator, state.cwd)!!;
    allocator.reset(mark);
  default:
  }
  return false;
}
