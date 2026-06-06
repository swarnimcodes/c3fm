module c3fm;

import std::io::path;

struct AppState {
  Path cwd;
  PathList entries;
  sz highlighted;
  String log;
}

// i am thinking something like
// this functions should be called when there is a change in the cwd
// since entries and log are dependent properties on cwd change,
// we ought to re-compute and reconcile the state
// the allocation, marking and reset stay in this function instead of
// 'n' number of places
// thats why i feel this function should exist
fn void? c3fm_recompute_state(ArenaAllocator* allocator, AppState* state) {
  sz mark = allocator.mark();
  path::chdir(state.cwd)!;
  state.entries = path::ls(allocator, state.cwd)!;
  state.highlighted = 0;
  allocator.reset(mark);
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
      state.cwd = current_highlighted_abs_path;
      c3fm_recompute_state(allocator, state)!!;
    } else if (path::is_file(current_highlighted_abs_path)) {
      state.log = "file";
    } else {
      state.log = "UNHANDLED CASE: highlighted entry is neither a file nor a directory?";
    }

  case BACK:
    state.cwd = state.cwd.parent()!!;
    c3fm_recompute_state(allocator, state)!!;
  default:
  }
  return false;
}
