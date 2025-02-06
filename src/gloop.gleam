import gleam/otp/task

pub fn blocking_while(
  state state: a,
  pre_run_condition pre_run_condition: fn(a) -> Bool,
  code_to_run code_to_run: fn(a) -> a,
) -> a {
  case pre_run_condition(state) {
    False -> state
    True -> {
      let new_state = code_to_run(state)
      blocking_while(new_state, pre_run_condition, code_to_run)
    }
  }
}

pub fn while(
  state state: a,
  pre_run_condition pre_run_condition: fn(a) -> Bool,
  code_to_run code_to_run: fn(a) -> a,
) -> a {
  let task =
    task.async(fn() { blocking_while(state, pre_run_condition, code_to_run) })
  //  io.debug(task)
  task.await_forever(task)
}

pub fn blocking_do_while(
  state state: a,
  code_to_run code_to_run: fn(a) -> a,
  post_run_condition post_run_condition: fn(a) -> Bool,
) -> a {
  let new_state = code_to_run(state)
  case post_run_condition(new_state) {
    False -> new_state
    True -> blocking_do_while(new_state, code_to_run, post_run_condition)
  }
}

pub fn do_while(
  state state: a,
  code_to_run code_to_run: fn(a) -> a,
  post_run_condition post_run_condition: fn(a) -> Bool,
) -> a {
  let task =
    task.async(fn() {
      blocking_do_while(state, code_to_run, post_run_condition)
    })
  //  io.debug(task)
  task.await_forever(task)
}
