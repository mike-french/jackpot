# Jackpot

## The Game

  Jackpot is a simple game of chance played by one person.

  The board has 9 cells labelled 1..9, 
  each covered by a wooden tile.
  The tile can lie down flat or be flipped up.
  [The game could also be played with 9 playing cards.]

  The same board is used for a game called Shut The Box,
  but the rules are different. 
  There are also variants of the rules for single-player Jackpot,
  but here we use simple Thai bar rules...

  At the beginning of the game, 
  every cell starts in the flat down position.

  For each move, the player rolls 2 six-sided dice, 
  then may flip up exactly one cell that is in the down position,
  but only if the cell number is one of the following:
   - individual value of the first die 
   - individual value of the second die
   - combined value of both dice

  For example: a roll of {3,4} provides a choice of cells 3, 4 or 7;
  a roll of {2,2} gives a choice of cells 2 or 4; 
  a roll of {6,6} only allows cell 6, because there is no cell 12.

  If all the cell choices offered by the dice roll 
  are already flipped up, then the game is lost. 
  The game is won if the player succeeds in 
  flipping up all 9 cells.

## Purpose

**This is not an interactive application to play the game.**

There are two areas of functionality:
- Monte Carlo simulation of random games to establish win/lose statistics.
- Analytic calculation of exact win/lose statistics based on game graph analysis. 

There are six implementations of player agents that decide the moves of the game:
- `AgentMin`; choose the lowest cell number. 
- `AgentMax`; choose the highest cell number. 
- `AgentFirst`; choose the first cell number. 
- `AgentLast`; choose the last cell number.
- HiLo: the simple optimal algorithm
  - `AgentHiLo`: using a priority sequence.
  - `AgentHiLo2`: using a max/min rule.

These are 1-line implementations. 
It is easy to add more agent strategies.

## Analysis

For a more detailed description of the game itself,
the HiLo algorithm, 
and the game graph used to analyze play, 
see the main Jackpot module documentation.

## Use

Run the test that generates analytic calculations and Monte Carlo simulation results.

`mix test`

Run dialyzer for type analysis.

`mix dialyzer`

Generate the documentation:

`mix docs`

## License

This repo is released under the MIT License.



