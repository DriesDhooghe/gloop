//// This module called `Gloop` introduces stack-safe, tall-call recursive `while` loops in Gleam.
//// The intent is to remove the additional mental burden recursion causes in Gleam.
////
//// For an example of how to use this library see gloop_test.gleam in the test folder.

/// This `while` function is stack-safe and checks the condition based on the communicated state
/// at the beginning of an iteration.
/// If the condition is true then the code handed to the `while` function is run and generates a
/// new state in preparation for the next iteration.
/// If the condition is false then the code returns the final state and stops.
/// As long as the condition is true, the while loop will continue without blowing up the stack.
pub fn while(
  state state: a,
  pre_run_condition pre_run_condition: fn(a) -> Bool,
  code_to_run code_to_run: fn(a) -> a,
) -> a {
  case pre_run_condition(state) {
    False -> state
    True -> {
      let new_state = code_to_run(state)
      while(new_state, pre_run_condition, code_to_run)
    }
  }
}

/// This `do while` function checks the condition using the communicated state at the end
/// of an iteration. It therefore runs the code given to the `do while` function AT LEAST once.
/// Just as the other while function, it is stack-safe.
pub fn do_while(
  state state: a,
  code_to_run code_to_run: fn(a) -> a,
  post_run_condition post_run_condition: fn(a) -> Bool,
) -> a {
  let new_state = code_to_run(state)
  case post_run_condition(new_state) {
    False -> new_state
    True -> do_while(new_state, code_to_run, post_run_condition)
  }
}
