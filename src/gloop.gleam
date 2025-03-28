//// This module called `Gloop` introduces stack-safe, tall-call recursive `while` and 'for' loops in Gleam.
//// The intent is to remove the additional mental burden recursion causes in Gleam.
////
//// For examples of how to use this library see gloop_test.gleam in the test folder.

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
      //in C break and continue checks happen within the code block
      let new_state = code_to_run(state)
      while(new_state, pre_run_condition, code_to_run)
    }
  }
}

/// This `do while` function checks the condition using the communicated state at the end
/// of an iteration. It therefore runs the code given to the `do while` function AT LEAST ONCE.
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

/// This `for` function checks the condition using the communicated state at the beginning
/// of an iteration.
/// If the condition is true then the code handed to the `for` function is run. At the end of a run,
/// a new state is generated that is used for the next iteration.
/// If the condition is false then the code returns the final state and stops.
/// Just as the other functions, this for loop is stack-safe.
/// NOTE: There should not be a great need for `for` loops in a functional language.
/// Use Map, reduce and folds instead.
pub fn for(
  state state: a,
  pre_run_condition pre_run_condition: fn(a) -> Bool,
  code_to_run code_to_run: fn(a) -> a,
  post_run_state post_run_state: fn(a) -> a,
) -> a {
  case pre_run_condition(state) {
    False -> state
    True -> {
      let intermediate_state = code_to_run(state)
      let new_state = post_run_state(intermediate_state)
      //add continue and break here before continuing
      for(new_state, pre_run_condition, code_to_run, post_run_state)
    }
  }
}
