//// This module called `Gloop` introduces stack-safe, tall-call recursive, non-UI blocking `while` loops in Gleam
//// The intent is to remove the additional mental burden recursion causes in Gleam.
////
//// For an example of how to use this library see gloop_test.gleam in the test folder.

import gleam/otp/task

/// This blocking `while` function is stack-safe and checks the condition based on the
/// communicated state.
/// If the condition is true then the code is run and a new state is generated for the next iteration.
/// If the condition is false then the code returns the final state and stops.
/// As long as the condition is true, the while loop will continue without blowing up the stack.
/// NOTE that this fuction blocks the UI from updating. It is slightly (a few msecs)
/// faster than the non-blocking while function so if pure speed is what you are after
/// AND you have a good idea of how many loops the function will execute then this function
/// might be what you are after. In most cases ( >95% ) this is NOT the function you should use.
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

/// This `while` function does the same thing as the blocking while function BUT does not block
/// the UI from updating and is stack-safe. This is the function to use in the overwhelming
/// majority of cases.
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

/// This blocking `do while` function checks the condition based on the communicated state at the end
/// of a iteration. It therefore runs the code AT LEAST once.
/// As the other blocking while function it is stack-safe and a few milliseconds faster than the
/// non-blocking do while function. As before, it should not be used in the majority of cases.
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

/// This non-blocking `do while` function does the same thing as the blocking do while function,
/// is stack-safe and does not block the UI.
/// Again this is the function to select in the overwhelming majority of cases.
pub fn do_while(
  state state: a,
  code_to_run code_to_run: fn(a) -> a,
  post_run_condition post_run_condition: fn(a) -> Bool,
) -> a {
  let task =
    task.async(fn() {
      blocking_do_while(state, code_to_run, post_run_condition)
    })
  task.await_forever(task)
}
