defmodule Jackpot do
  @moduledoc """
  ## The Game

  Jackpot is a simple game of chance played by one person.

  The board has 9 cells labelled 1..9, 
  each covered by a wooden tile.
  The tile can lie down flat or be flipped up.

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

  Here are some simple initial observations:

    - Cells 1..6 can be flipped by an individual die value.
    - Cells 2..9 can be flipped by a combined score.
    - Cell 1 can only be flipped by an individual die value.
    - Cells 7, 8, 9 can only be flipped using a combined score.

    - There are 36 possible rolls of 2 dice.
    - There are 2 rolls that only enable 1 cell choice. 
      These are the worst rolls: {5,5} {6,6}.
    - There are 8 rolls that support only 2 cell choices:
      {1,1} {2,2} {3,3} {4,4} {6,4}{4,6} {6,5}{5,6}.
    - The remaining 26 rolls support 3 cell choices.

  ## Cell Probabilities

  The total probability for having a choice of flipping a cell 
  is the sum of probabilities for the first die value, 
  the second die value, and the combined total of both dice.

  Here is the matrix of possibilities.
  All probabilities are expressed as units of 1/36.

  ```
  +-------+--------------------------------------------+
  |       |                    cell                    |
  +       +----+----+----+----+----+----+----+----+----+
  |  dice |  1 |  2 |  3 |  4 |  5 |  6 |  7 |  8 |  9 |
  +-------+----+----+----+----+----+----+----+----+----+----------+
  |   A   |  6 |  6 |  6 |  6 |  6 |  6 |    |    |    |  P(cell) |
  |   B   |  6 |  6 |  6 |  6 |  6 |  6 |    |    |    |  unit of |
  |  A+B  |    |  1 |  2 |  3 |  4 |  5 |  6 |  5 |  4 |   1/36   |
  +-------+----+----+----+----+----+----+----+----+----+----------+
  |       | 12 | 13 | 14 | 15 | 16 | 17 |  6 |  5 |  4 |   Total  |
  +-------+----+----+----+----+----+----+----+----+----+----------+
  ```

  ## HiLo Strategy

  The HiLo strategy is based on probabilities of 
  getting a dice roll that can flip the cell.

  The HiLo strategy chooses the cell with the lowest probability 
  of being allowed by a roll of 2 dice.
  The priority sequence of cells with increasing probability is:

     (lowest) `9, 8, 7, 1, 2, 3, 4, 5, 6` (highest)

  Another way to think about the sequence is to 
  choose the high combined dice values (9,8,7) if possible,
  otherwise choose the lowest number cell allowed.

    Note the lowest probability cell is 9, so these are the best rolls:
  {5,4}{4,5} {6,3}{3,6}.

  ## Game Graph

  A game graph is a directed graph
  containing board positions as nodes and moves as edges.
  The set of nodes contains all 512 possible board positions.
  The board position nodes are labelled with the integer index
  calculated from treating the cells as binary digits,
  from 1 (least significant) to 9 (most significant).

  Each node has up to 36 outgoing edges corresponding to the 
  allowed legal moves chosen by a player.
  The graph is layered by how many moves have been made
  from 0 (start) to 9 (win). 
  So the layer number, n, is equal to how many cells are flipped up,
  and hence the number of 1s in the binary index.
  The number of nodes in layer n is the binomial coefficient 9Cn,
  so the layer populations are [1,9,36,84,126,126,84,36,9,1].

  There are no edges within a layer. 
  Each layer only has edges going out to members of the next highest layer.
  The root (source) node is the starting position (index 0), 
  which does not have any incoming edges.
  The final (sink) node is the winning position (index 511),
  which does not have any outgoing edges.  

  ```
                        +---+
                 START  | 0 |                               Layer 0
                        +---+
                       ///|\\\\\\\\\\ first moves
                          |flip 4
        :     :     :     |      :      :     :       :
      +---+ +---+ +---+ +---+ +----+ +----+ +----+ +-----+ 
      | 1 | | 2 | | 4 | | 8 | | 16 | | 32 | | 64 | | 128 |  Layer 1
      +---+ +---+ +---+ +---+ +----+ +----+ +----+ +-----+
        |     /     :     :      :      :      :      :
        |    /
  flip 2|   /flip 1
        |  /
        | /   :     :      :  
      +---+ +---+ +---+ +----+ 
      | 3 | | 5 | | 9 | | 17 | ..... 36 nodes ....          Layer 2
      +---+ +---+ +---+ +----+                                :
        :      :    :      :                                  :
                                                              :
                                                              :
                          \\|/ winning moves                   :
                        +-----+                               :
                   WIN  | 511 |                             Layer 9
                        +-----+               
  ```

  The outgoing edges from a board position node
  go the next position node in the game Graph.
  The edge corresponds to the flipping of exactly one cell in the board.
  Each edge is weighted with the count of the number of rolls of the dice
  that would lead to that move being chosen by a specific player.

  For example, the 15 rolls {1,3} {3,1} {2,2} {4,\*} {\*,4} might all 
  result in flipping cell 4 and moving to the same next position node,
  so the edge count would be 15.

  Each node also stores the probability of reaching that position,
  which is the sum of probabilites along each path of edges 
  leading to the position. 

  To calculate the full set of probabilities for every node in the graph:
  - Initialize the probability of the start node (index 0) to 1.0.
  - For each position node, in order of layers:
    - For each edge going out from the source node:
      - Calculate the edge contribution as the source node probability
        multiplied by the edge weight, which is edge count/36.
      - Increment the destination node probability with the edge contribution.
  - At the last node (index 511, layer 9), there are no outgoing edges,
    and the final value is the winning probability.

  ## HiLo Success Rate

  Just in case you want the answer without running the code:
  game graph analysis calculates the success rate of HiLo as 7.9855 %,
  so about 2 wins in every 25 games.
  """

  defmodule T do
    @moduledoc "Types for the Jackpot application."

    @typedoc "A single die with numbers 1..6"
    @type die() :: 1..6
    defguard is_die(i) when is_integer(i) and 1 <= i and i <= 6

    @typedoc "A roll of 2 dice with numbers 1..6"
    @type roll() :: {die(), die()}
    defguard is_roll(r) when is_die(elem(r, 0)) and is_die(elem(r, 1))

    @typedoc "Probability of some event in the game."
    @type probability() :: float()
    defguard is_prob(p) when is_float(p) and 0.0 <= p and p <= 1.0

    @typedoc "Probability of winning or losing as a percentage."
    @type percent() :: float()
    defguard is_pc(p) when is_float(p) and 0.0 <= p and p <= 100.0

    @typedoc """
    A single cell on the board, which can be down (false) or flipped up (true).
    Cells are ordered and numbered from left (1) to right (9).
    """
    @type cell() :: 1..9
    defguard is_cell(c) when is_integer(c) and 1 <= c and c <= 9

    @typedoc """
    A set of cells that can be played from a roll of 2 dice.
    The list calculated from the roll will have 1, 2 or 3 elements.

    The set may be filtered by removing cells that are already flipped (true).
    The result is a set of possible moves in the game,
    which may be empty if all the cells are already flipped up.

    """
    @type cells() :: [cell()]
    defguard is_non_empty_cells(cs) when is_list(cs) and length(cs) > 1

    @typedoc """
    The board is a row of 9 cells.
    The cells are held in a map for fast lookup.
    """
    @type board() :: %{cell() => boolean()}

    @typedoc """
    The index of a board position is the integer 
    represented by treating cells as binary digits.
    The bits are shifted by cell number, 
    so the binary number is read from left (1st - least significant)
    to right (9th - most signiificant).
    The start position with all cells off (0, false) has index 0.
    The winning position with all cells on (1, true) has index 511
    which is 2^9 - 1.
    """
    @type index() :: 0..511
    defguard is_index(ix) when is_integer(ix) and 0 <= ix and ix < 512

    @typedoc "The set of all possible boards, accessed by integer index."
    @type boards() :: %{index() => board()}

    @typedoc """
    A player is implemented as a module with a `move` function.""
    """
    @type player() :: module()

    @typedoc """
    A move in the game is a roll of 2 dice,
    with a choice of which cell to flip,
    or `:no_move` if there is no valid move
    and the game is lost.
    """
    @type move() :: {roll(), :no_move | cell()}
    defguard is_move(m)
             when is_roll(elem(m, 0)) and
                    (elem(m, 1) == :no_move or is_cell(elem(m, 1)))

    @typedoc "A game history is a sequence of moves."
    @type moves() :: [move()]

    @typedoc """
    A game is the current board position, a player, 
    and the historical sequence of moves already played.
    A game is complete if it is won or lost.

    A winning game has a board with all cells flipped (index 511)
    and 9 moves containing all cells exactly once,
    without any `:no_move` blocked position.

    A losing game has a board with at least one cell not flipped,
    and the last move is a blocked position with `:no_move`.
    """
    @type game() :: {board(), player(), moves()}

    @typedoc "The outcome of a game is always win or lose."
    @type outcome() :: :win | :lose

    @typedoc """
    The result of a game is an outcome, 
    the final board position, and the sequence of moves that were played.
    """
    @type result() :: {outcome(), board(), [move()]}

    @typedoc "Statistics for winning or losing."
    @type statistics() :: %{outcome() => percent()}

    @typedoc """
    A game graph is a directed graph
    containing board positions as nodes, and moves as edges.
    The set of nodes contains all 512 possible board positions.
    Each node has up to 36 outgoing edges corresponding to the 
    allowed legal moves chosen by a player agent.

    The graph is layered by how many moves have been made
    (i.e. how many cells are flipped) from 0 (start) to 9 (win).
    There are no edges within a layer. 
    Each layer only has edges going out to members of the next highest layer.
    The root (source) node is the starting position (index 0), 
    which does not have any incoming edges.
    The final (sink) node is the winning position (index 511),
    which does not have any outgoing edges.  

    Each node also stores the probability of reaching that position,
    which is the sum of probabilites along each path of edges 
    leading to the position.
    """
    @type graph() :: %{T.index() => {edges(), probability()}}

    @typedoc """
    The outgoing edges from a board position node
    to the next position node in the game Graph.
    The edge corresponds to the flipping of exactly one cell in the board.
    The edges are stored as the destination node (board position index)
    with the number of dice rolls for which the player would choose that move.

    For example, the 15 rolls {1,3} {3,1} {2,2} {4,*} {*,4} might all 
    result in flipping cell 4 and moving to the same next position node.
    """
    @type edges() :: %{index() => T.count()}

    @typedoc "A count of the number of rolls of 2 dice that lead to the same cell choice."
    @type count() :: 1..36
    defguard is_count(n) when is_integer(n) and 1 <= n and n <= 36
  end

  # ------------------------------------------------------------------------
  # player agents with different strategies
  # (would be a behaviour, but cannot define that in one file)

  defmodule AgentMin do
    @moduledoc "A trivial strategy that always chooses the lowest value cell."
    def move(cells), do: Enum.min(cells)
  end

  defmodule AgentMax do
    @moduledoc "A trivial strategy that always chooses the highest value cell."
    def move(cells), do: Enum.max(cells)
  end

  defmodule AgentFirst do
    @moduledoc "A trivial strategy that always chooses the first cell in the list of choices."
    def move(cells), do: hd(cells)
  end

  defmodule AgentLast do
    @moduledoc "A trivial strategy that always chooses the last cell in the list of choices."
    def move(cells), do: List.last(cells)
  end

  defmodule AgentHiLo do
    @moduledoc """
    HiLo implementation using an explicit priority sequence,
    but is quadratic in the worst case.
    """
    def move(cells) when is_list(cells) and length(cells) > 1 do
      priority([9, 8, 7, 1, 2, 3, 4, 5, 6], cells)
    end

    defp priority([i | t], cells) do
      if Enum.member?(cells, i), do: i, else: priority(t, cells)
    end
  end

  defmodule AgentHiLo2 do
    @moduledoc """
    HiLo implementation uses a maximum threshold then minimum.
    Initial chance of performing both scans on starting board is about 50%,
    but this goes up to 100% as 7, 8 and 9 are flipped.
    """
    def move(cells) when is_list(cells) and length(cells) > 1 do
      max = Enum.max(cells)
      if max > 6, do: max, else: Enum.min(cells)
    end
  end

  # ---------------------------------------------------------------------------

  defmodule Util do
    @moduledoc "Utilities for the Jackpot application."
    require Jackpot.T

    @doc "Calculate percentage to 2 decimal places."
    @spec pc(T.probability()) :: T.percent()
    def pc(x) when is_float(x), do: Float.round(100.0 * x, 4)

    @doc """
    Increment an integer value in a map.
    If the key is missing, use a default initial value of 0.
    """
    @spec inc(%{any() => integer()}, any()) :: %{any() => integer()}
    def inc(map, key) when is_map(map) do
      n = Map.get(map, key, 0)
      Map.put(map, key, n + 1)
    end
  end

  defmodule Dice do
    @moduledoc """
    Simulate random die and roll of 2 dice.

    Implement the Jackpot logic of converting a roll of 2 dice
    into a set of cells that can be flipped.

    Generate all possible rolls of 2 dice,
    hence generate the set of all possible cell choices.
    """
    require Jackpot.T

    @doc "The list of all allowed cell choices from roll of 2 dice."
    @spec all_cells() :: [T.cells()]
    def all_cells(), do: all_rolls() |> Enum.map(&cells/1)

    @doc "The list of all possible rolls of 2 dice."
    @spec all_rolls() :: [T.roll()]
    def all_rolls() do
      for i <- 1..6 do
        for j <- 1..6, do: {i, j}
      end
      |> List.flatten()
    end

    @doc "Convert a roll of 2 dice into a list of allowed cell choices."
    @spec cells(roll :: T.roll()) :: T.cells()
    def cells({i, j}) when T.is_cell(i + j), do: [i, j, i + j]
    def cells({i, j}), do: [i, j]

    @doc "Simulated random roll of 2 dice."
    @spec roll() :: T.roll()
    def roll, do: {die(), die()}

    # Simulated random roll of 1 die.
    @spec die() :: T.die()
    defp die, do: Enum.random(1..6)
  end

  defmodule Board do
    @moduledoc """
    The Jackpot board of 9 cells that can be flipped.
    """

    use Bitwise
    require Jackpot.T

    @doc "A new board in the starting position (index 0)."
    @spec new() :: T.board()
    def new do
      Enum.reduce(1..9, %{}, fn i, board -> Map.put(board, i, false) end)
    end

    @doc """
    A board position for a specific index, 
    interpreted as a sequence of binary digits.
    """
    @spec new(T.index()) :: T.board()
    def new(index) when T.is_index(index) do
      Enum.reduce(1..9, Board.new(), fn i, board ->
        if (index &&& 1 <<< (i - 1)) > 0, do: Board.flip(board, i), else: board
      end)
    end

    @doc """
    Generate all 512 possible boards from start (index 0) to winning (index 511). 
    """
    @spec all_boards() :: T.boards()
    def all_boards do
      Enum.reduce(0..511, %{}, fn i, boards ->
        Map.put(boards, i, new(i))
      end)
    end

    @doc "Find if the cell is flipped up (true) or not (false)."
    @spec cell?(T.board(), T.cell()) :: boolean()
    def cell?(board, c) when T.is_cell(c), do: Map.fetch!(board, c)

    @doc "Test if a board is the winning position with all cells flipped (index 511)."
    @spec win?(T.board()) :: boolean()
    def win?(board) do
      # also index == 511
      # also board |> Map.values() |> Enum.all?()
      # also single pass logic op with short circuit...
      # Enum.reduce_while(board, true, fn {_i, flip}, win ->
      #   result = flip and win
      #   flag = if result, do: :cont, else: :halt
      #   {flag, result}
      # end)
      # simple scan folding AND over the binary cells
      Enum.reduce(board, true, fn {_i, flip}, win -> flip and win end)
    end

    @doc """
    Make a move by flipping a cell from false to true.

    It is an error if the cell has already been flipped.
    """
    @spec flip(T.board(), T.cell()) :: T.board()
    def flip(board, c) when T.is_cell(c) do
      if cell?(board, c), do: raise("Cell #{c} is already flipped")
      %{board | c => true}
    end

    @doc """
    Calculate the index for a board,
    by interpreting the cells as binary digits,
    starting at cell 1 (least significant)
    to cell 9 (most significant).
    """
    @spec index(T.board()) :: T.index()
    def index(board) do
      Enum.reduce(board, 0, fn
        {i, true}, total -> total + (1 <<< (i - 1))
        {_, false}, total -> total
      end)
    end

    @doc """
    Let a player make a move for a specific roll in a given position.

    The set of possible cell choices has been calculated from the roll.
    This function wraps the player move by enforcing pre-conditions and checking post-conditions. 
    The cells are filtered to only those allowed by the current position.
    If there are no allowed cell choices, the game is lost.
    If there is exactly one cell choice, that move is forced.
    If there is more than one cell choice, then the player makes the decision.
    The player's move must be an allowed cell choice.

    The function returns `:no_move` with the losing board position, 
    or the chosen cell move with the new board position.
    """
    @spec move(T.board(), T.cells(), T.player()) :: {:no_move | T.cell(), T.board()}
    def move(board, cells, player) do
      choices = Enum.filter(cells, fn c -> not cell?(board, c) end)
      do_move(board, choices, player)
    end

    @spec do_move(T.board(), T.cells(), T.player()) :: {:no_move | T.cell(), T.board()}

    defp do_move(board, [], _player), do: {:no_move, board}

    defp do_move(board, [choice], _player), do: {choice, Board.flip(board, choice)}

    defp do_move(board, choices, player) do
      choice = player.move(choices)
      if choice not in choices, do: raise("Illegal move #{choice} not in #{choices}")
      {choice, Board.flip(board, choice)}
    end
  end

  defmodule Game do
    @moduledoc """
    Play a game of Jackpot with a player agent.
    Run Monte Carlo simulation of many games to generate win/loss statistics.
    """
    require Jackpot.T

    @doc """
    Run many games for a player agent.
    Return statistics of winning and losing.
    The larger the number of games, 
    the more accurate the statistics.
    """
    @spec monte_carlo(T.player(), pos_integer()) :: T.statistics()
    def monte_carlo(player, n) when is_integer(n) and n > 0 do
      results =
        1..n
        |> Enum.map(fn _i -> play(player) end)
        |> Enum.group_by(&elem(&1, 0))

      wins = Map.get(results, :win, [])
      losses = Map.get(results, :lose, [])
      %{win: Util.pc(length(wins) / n), lose: Util.pc(length(losses) / n)}
    end

    @doc "Play a new game for a player agent."
    @spec play(T.game() | T.player()) :: T.result()
    def play(player) do
      do_play({Board.new(), player, []})
    end

    @spec do_play(T.game()) :: T.result()
    defp do_play(game) do
      case next(game) do
        {:continue, game} -> do_play(game)
        finished -> finished
      end
    end

    @spec next(T.game()) :: T.result() | {:continue, T.game()}
    defp next({board, player, moves}) do
      if Board.win?(board), do: raise("Game is already won")

      roll = Dice.roll()
      choices = Dice.cells(roll)

      case Board.move(board, choices, player) do
        {:no_move, _board} ->
          new_moves = [{roll, :no_move} | moves]
          {:lose, board, Enum.reverse(new_moves)}

        {choice, new_board} ->
          new_moves = [{roll, choice} | moves]

          if Board.win?(new_board) do
            {:win, new_board, Enum.reverse(new_moves)}
          else
            {:continue, {new_board, player, new_moves}}
          end
      end
    end
  end

  defmodule Graph do
    @moduledoc """
    Analyze the play of a player agent across all possible games.

    The algorithm uses two passes. 
    The first builds a game graph using board positions as nodes, 
    and player moves as edges between nodes.
    The second pass traverses the graph from the start position node,
    propagating probability between layers of the graph,
    which correspond to successive moves in the games.
    Finally the win probabillity is read out from the win position node.
    """
    use Bitwise

    @doc "Get the analytic probability of win/lose for a player."
    @spec calculate_outcomes(T.player()) :: T.statistics()
    def calculate_outcomes(player) when is_atom(player) do
      player
      |> build()
      |> propagate()
      |> statistics()
    end

    @spec statistics(T.graph()) :: T.statistics()
    defp statistics(graph) when is_map(graph) do
      # find the winning board node
      {%{}, pwin} = Map.fetch!(graph, 511)
      %{win: Util.pc(pwin), lose: Util.pc(1.0 - pwin)}
    end

    @spec build(T.player()) :: T.graph()
    defp build(player) do
      all_cells = Dice.all_cells()
      # loop over all boards, each board will be a node
      Enum.reduce(0..511, %{}, fn i, graph ->
        board = Board.new(i)

        # loop over all cells choices 
        # let the player choose a move for each set of cell choices (roll)
        # and accumulate count of outgoing edges
        edges =
          Enum.reduce(all_cells, %{}, fn cells, edges ->
            case Board.move(board, cells, player) do
              {:no_move, _board} ->
                # losing position for this roll
                edges

              {_choice, new_board} ->
                # increment destination node index for the new board position
                Util.inc(edges, Board.index(new_board))
            end
          end)

        # initialize start position as 100%
        # and all later board positions at 0%
        init_prob = if i == 0, do: 1.0, else: 0.0
        Map.put(graph, i, {edges, init_prob})
      end)
    end

    @spec propagate(T.graph()) :: T.graph()
    defp propagate(graph) do
      # sortng by nbits ensures the order of moves in the game
      # so probability always propagates forwards across layers
      # processed nodes can be removed, except for winning position
      index_sequence = Enum.sort_by(0..511, &nbits/1)

      Enum.reduce(index_sequence, graph, fn i, graph ->
        {iedges, iprob} = Map.fetch!(graph, i)

        new_graph =
          Enum.reduce(iedges, graph, fn {j, count}, graph ->
            # find the destination node 
            {jedges, jprob} = Map.fetch!(graph, j)
            # add probability contribution from i to j
            new_jprob = jprob + iprob * count / 36.0
            # replace destination node with updated probability
            Map.put(graph, j, {jedges, new_jprob})
          end)

        # optionally delete node i here
        if i < 511, do: Map.delete(new_graph, i), else: new_graph
      end)
    end

    @spec nbits(T.index()) :: 0..9
    defp nbits(index) do
      Enum.reduce(0..9, 0, fn i, n ->
        if (index &&& 1 <<< i) > 0, do: n + 1, else: n
      end)
    end
  end
end
