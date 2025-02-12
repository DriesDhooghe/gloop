//// To test and show how to use while, I have added 2 examples.
//// The first one is the traditional implementation of the well-known factorial function to
//// allow you to focus on how to use while (see factorial_using_iterations).
//// For The second example, I used the still unproven Collatz conjecture
//// (https://science.howstuffworks.com/math-concepts/collatz-conjecture.htm)
//// to performance test the while function and to show you how to use the while function
//// in a more realistic situation. On my computer this Collatz sample code on a ridiculously
//// large integer runs through 68140 loops in about 112 msecs.

import gleam/int
import gleam/io
import gloop
import timestamps

pub type ErrorCheck {
  NegativeValue
  ZeroValue
}

pub type FactorialState {
  FactorialState(accumulator: Int, i: Int)
}

/// This function calculates the factorial using iteration (iterator i and an accumulator to
/// hold the calculated value in between loops of while).
pub fn factorial_using_iteration(n: Int) -> Result(FactorialState, ErrorCheck) {
  //Error checking, don't run if intial value is negative
  let n_is_neg = n < 0
  let n_is_0 = n == 0
  let initial_state = FactorialState(accumulator: 1, i: n)
  case n_is_neg {
    True -> Error(NegativeValue)
    False ->
      case n_is_0 {
        True -> Ok(initial_state)
        False ->
          Ok(
            gloop.while(
              state: initial_state,
              pre_run_condition: fn(state: FactorialState) -> Bool {
                state.i != 1
              },
              code_to_run: fn(state: FactorialState) -> FactorialState {
                let accumulator = state.accumulator
                let i = state.i
                FactorialState(accumulator * i, i - 1)
              },
            ),
          )
      }
  }
}

pub type CollatzState {
  CollatzState(n: Int, iterations: Int)
}

/// Returns the number of iterations necessary for the Collatz function starting at start_value
/// to reach 1. We create an initial_state that gets threaded through the iterations as a new state
/// in the while loop and is tested against the exit criterium (state.n != 1).
pub fn collatz(start_value: Int) -> Result(CollatzState, ErrorCheck) {
  //Error checking, don't run if intial value is negative or zero
  let n_is_neg = start_value < 0
  let n_is_0 = start_value == 0
  let initial_state = CollatzState(n: start_value, iterations: 0)
  case n_is_0 {
    True -> Error(ZeroValue)
    False ->
      case n_is_neg {
        True -> Error(NegativeValue)
        False ->
          Ok(
            gloop.while(
              state: initial_state,
              pre_run_condition: fn(state: CollatzState) -> Bool {
                state.n != 1
              },
              code_to_run: fn(state: CollatzState) -> CollatzState {
                let n = state.n
                let iterations = state.iterations
                let is_even = int.is_even(n)
                case is_even {
                  True -> CollatzState(n / 2, iterations + 1)
                  False -> CollatzState({ 3 * n } + 1, iterations + 1)
                }
              },
            ),
          )
      }
  }
}

pub fn main() {
  io.debug(factorial_using_iteration(100))
  io.debug(factorial_using_iteration(-1))
  io.debug(factorial_using_iteration(0))
  io.debug(factorial_using_iteration(1))

  let large_integer =
    989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647

  let start_time = timestamps.new() |> timestamps.value_of
  io.debug(collatz(large_integer))
  let end_time = timestamps.new() |> timestamps.value_of
  io.debug(end_time - start_time)
  io.debug(collatz(-1))
  io.debug(collatz(0))
  io.debug(collatz(1))
}
