//// To test and show how to use `while` and `for`, I have added 3 examples.
//// 1. Traditional implementation of the well-known factorial function to allow
//// you to focus on how to use while (see factorial_using_while).
//// 2. Factorial function but this time using a for loop (see factorial_using_for)
//// 3. For the third example, I used the still unproven Collatz conjecture
//// (https://science.howstuffworks.com/math-concepts/collatz-conjecture.htm)
//// to performance-test the while function and to show you how to use the while
//// function in a more complex realistic situation. On my computer this Collatz
//// sample code on a ridiculously large integer runs through 68140 loops in about 112 msecs.

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

pub fn factorial_using_while_with_termination(
  n: Int,
) -> Result(FactorialState, ErrorCheck) {
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
                //Note how in a while loop, the counter is updated in the code block.
                //This is in contrast to the for loop below.
              },
            ),
          )
      }
  }
}

/// This function calculates the factorial using iteration and a while loop (iterator i
/// and an accumulator to hold the calculated value in between iterations of the while loop).
/// In an imperative language like C, the function factiorial using a while loop would be
/// implemented as follows:
///
/// int factorial(int n) {
///    if (n < 0) { return -1; } //error check, return -1 if there is an error
///    int acc = 1;
///    while (n > 1) { acc = acc * n; n = n - 1;}
///    return acc;
/// }
///
///   - n > 1 is the condition to check prior to running the code block. If the condition is false
///   then the loop stops and the function moves to returning acc.
///   - { acc = acc * n; n = n - 1 } is the code to execute if the condition is true (in this case
///   multiply the value of acc with n, store the result in acc, decrement n and start the next
///   iteration of the loop.
///   NOTE: in a while loop, the counter n is updated in the code block in C.
///   This is in contrast to the for loop in C (see further down).
///
/// The state in this snippet is represented through the variable acc and the parameter n. In
/// functional programming languages, variables can't be changed so we create a FactorialState type
/// that contains both acc and n; we create a new state for each iteration of the while loop and pass
/// the state around.
/// The equivalent factorial function using gloop.while in Gleam would be:
///
pub fn factorial_using_while(n: Int) -> Result(FactorialState, ErrorCheck) {
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
                //Note how in a while loop, the counter i is updated in the code block.
                //This is in contrast to the for loop below.
              },
            ),
          )
      }
  }
}

/// The next function calculates the factorial using iteration and a for loop (iterator i
/// and an accumulator to hold the calculated value in between loops of for).
/// E.g. in an imperative language like C, the function factorial using a for loop would
/// be implemented like this:
///
/// int factorial(int n) {
///    if (n < 0) { return -1; } //error check, return -1 if there is an error
///    int acc = 1;
///    for (int i = 1; i <= n; i = i + 1) { acc = acc * i; }
///    return acc;
/// }
///
///   i = 1; is the initialization of i when starting the for loop
///   i <= n; is the condition to check prior to running the code block. If the condition is false then the loop stops.
///   { acc = acc * i; } is the code to execute if the condition is true (in this case multiply the value of acc with i and store in acc)
///   i = i + 1 is what needs to happen to the variable i after the code has executed (in this case increase i by 1 and store in i)
///
/// As before, the state in this snippet is represented through the variable acc and the parameter n.
/// And as before use use the FactorialState type to represent the state we want to pass from iteration
/// to iteration of the loop.
/// The equivalent factorial function using gloop.for in Gleam would be:
///
pub fn factorial_using_for(n: Int) -> Result(FactorialState, ErrorCheck) {
  //Error checking, don't run if intial value is negative
  let n_is_neg = n < 0
  let n_is_0 = n == 0
  let initial_state = FactorialState(accumulator: 1, i: 1)
  case n_is_neg {
    True -> Error(NegativeValue)
    False ->
      case n_is_0 {
        True -> Ok(initial_state)
        False ->
          Ok(gloop.for(
            state: initial_state,
            pre_run_condition: fn(state: FactorialState) -> Bool {
              state.i <= n
            },
            code_to_run: fn(state: FactorialState) -> FactorialState {
              let accumulator = state.accumulator
              let i = state.i
              let intermediate_state = FactorialState(accumulator * i, i)
              //Note how in a for loop, the counter is NOT updated in the code block like
              //it is in the while function although we easily could have done that here as well.
              //This follows how the for loop works in C.
            },
            post_run_state: fn(intermediate_state: FactorialState) -> FactorialState {
              let i = intermediate_state.i
              let accumulator = intermediate_state.accumulator
              let new_state = FactorialState(accumulator, i + 1)
              //We update the counter separately from the code block like in C.
            },
          ))
      }
  }
}

pub type CollatzState {
  CollatzState(n: Int, iterations: Int)
}

/// Returns the number of iterations necessary for the Collatz function starting at start_value
/// to reach 1. We create an initial_state that gets threaded through the iterations as a new
/// CollatzState in the while loop and is tested against the exit criterium (state.n != 1).
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
  //Example 1 factorial using while

  echo "FACTORIAL USING WHILE"
  echo factorial_using_while(100)
  echo factorial_using_while(-1)
  echo factorial_using_while(0)
  echo factorial_using_while(1)

  //Example 2 factorial using for

  echo "FACTORIAL USING FOR"
  echo factorial_using_for(100)
  echo factorial_using_for(-1)
  echo factorial_using_for(0)
  echo factorial_using_for(1)

  //Example 3 Collatz

  echo "COLLATZ"
  let large_integer =
    989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647_989_345_275_647

  let start_time = timestamps.new() |> timestamps.value_of
  echo collatz(large_integer)
  let end_time = timestamps.new() |> timestamps.value_of
  echo end_time - start_time
  echo collatz(-1)
  echo collatz(0)
  echo collatz(1)
}
