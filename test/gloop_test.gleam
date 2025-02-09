//// I didn't want to use a boring Fibonacci sequence which is traditionally used to
//// explain recursion and looping. Instead I used the Collatz conjecture.
//// See https://science.howstuffworks.com/math-concepts/collatz-conjecture.htm
//// It is one of the still unproven conjectures in mathematics.
////
//// On my computer running this sample code (after starting the erlang VM) yields:
//// Non-blocking Collatz on a huge integer: 68140 loops in 118 msecs without blocking the UI
//// Blocking Collatz on the same huge integer: 68140 loops in 112 msecs while blocking the UI

import gleam/int
import gleam/io
import gloop
import timestamps

pub type CollatzState {
  CollatzState(n: Int, iterations: Int)
}

pub type CollatzError {
  NegativeValue
  ZeroValue
}

/// Returns the number of steps necessary for the Collatz function starting at start_value to reach 1.
/// We create an initial_state that gets threaded through the iterations as a new state
/// in the while loop and is tested against the exit criterium (state.n != 1).
pub fn blocking_collatz(start_value: Int) -> Result(CollatzState, CollatzError) {
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
            gloop.blocking_while(
              state: initial_state,
              pre_run_condition: fn(state: CollatzState) -> Bool {
                state.n != 1
              },
              code_to_run: fn(state: CollatzState) -> CollatzState {
                let n = state.n
                let iterations = state.iterations
                let is_even = int.is_even(n)
                //              io.debug(n)
                //              io.debug(iterations)
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

/// Returns the number of steps necessary for the Collatz function starting at start_value to reach 1.
/// We create an initial_state that gets threaded through the iterations as a new state
/// in the while loop and is tested against the exit criterium (state.n != 1).
pub fn non_blocking_collatz(
  start_value: Int,
) -> Result(CollatzState, CollatzError) {
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
              pre_run_condition: fn(state: CollatzState) -> Bool {
                state.n != 1
              },
              state: initial_state,
              code_to_run: fn(state: CollatzState) -> CollatzState {
                let n = state.n
                let iterations = state.iterations
                let is_even = int.is_even(n)
                // io.debug(n)
                // io.debug(iterations)
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
  let large_integer =
    989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647
  let start_time1 = timestamps.new() |> timestamps.value_of
  io.debug(non_blocking_collatz(large_integer))
  let end_time1 = timestamps.new() |> timestamps.value_of
  io.debug(end_time1 - start_time1)

  io.debug(non_blocking_collatz(-1))
  io.debug(non_blocking_collatz(0))
  io.debug(non_blocking_collatz(1))

  let start_time2 = timestamps.new() |> timestamps.value_of
  io.debug(blocking_collatz(large_integer))
  let end_time2 = timestamps.new() |> timestamps.value_of
  io.debug(end_time2 - start_time2)
}
