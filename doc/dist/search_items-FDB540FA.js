searchNodes=[{"doc":"The Game Jackpot is a simple game of chance played by one person. The board has 9 cells labelled 1..9, each covered by a wooden tile. The tile can lie down flat or be flipped up. The same board is used for a game called Shut The Box, but the rules are different. There are also variants of the rules for single-player Jackpot, but here we use simple Thai bar rules... At the beginning of the game, every cell starts in the flat down position. For each move, the player rolls 2 six-sided dice, then may flip up exactly one cell that is in the down position, but only if the cell number is one of the following: individual value of the first die individual value of the second die combined value of both dice For example: a roll of {3,4} provides a choice of cells 3, 4 or 7; a roll of {2,2} gives a choice of cells 2 or 4; a roll of {6,6} only allows cell 6, because there is no cell 12. If all the cell choices offered by the dice roll are already flipped up, then the game is lost. The game is won if the player succeeds in flipping up all 9 cells. Here are some simple initial observations: Cells 1..6 can be flipped by an individual die value. Cells 2..9 can be flipped by a combined score. Cell 1 can only be flipped by an individual die value. Cells 7, 8, 9 can only be flipped using a combined score. There are 36 possible rolls of 2 dice. There are 2 rolls that only enable 1 cell choice. These are the worst rolls: {5,5} {6,6}. There are 8 rolls that support only 2 cell choices: {1,1} {2,2} {3,3} {4,4} {6,4}{4,6} {6,5}{5,6}. The remaining 26 rolls support 3 cell choices. Cell Probabilities The total probability for having a choice of flipping a cell is the sum of probabilities for the first die value, the second die value, and the combined total of both dice. Here is the matrix of possibilities. All probabilities are expressed as units of 1/36. + -- -- -- - + -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- + | | cell | + + -- -- + -- -- + -- -- + -- -- + -- -- + -- -- + -- -- + -- -- + -- -- + | dice | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | + -- -- -- - + -- -- + -- -- + -- -- + -- -- + -- -- + -- -- + -- -- + -- -- + -- -- + -- -- -- -- -- + | A | 6 | 6 | 6 | 6 | 6 | 6 | | | | P ( cell ) | | B | 6 | 6 | 6 | 6 | 6 | 6 | | | | unit of | | A + B | | 1 | 2 | 3 | 4 | 5 | 6 | 5 | 4 | 1 / 36 | + -- -- -- - + -- -- + -- -- + -- -- + -- -- + -- -- + -- -- + -- -- + -- -- + -- -- + -- -- -- -- -- + | | 12 | 13 | 14 | 15 | 16 | 17 | 6 | 5 | 4 | Total | + -- -- -- - + -- -- + -- -- + -- -- + -- -- + -- -- + -- -- + -- -- + -- -- + -- -- + -- -- -- -- -- + HiLo Strategy The HiLo strategy is based on probabilities of getting a dice roll that can flip the cell. The HiLo strategy chooses the cell with the lowest probability of being allowed by a roll of 2 dice. The priority sequence of cells with increasing probability is: (lowest) 9, 8, 7, 1, 2, 3, 4, 5, 6 (highest) Another way to think about the sequence is to choose the high combined dice values (9,8,7) if possible, otherwise choose the lowest number cell allowed. Note the lowest probability cell is 9, so these are the best rolls: {5,4}{4,5} {6,3}{3,6}. Game Graph A game graph is a directed graph containing board positions as nodes and moves as edges. The set of nodes contains all 512 possible board positions. The board position nodes are labelled with the integer index calculated from treating the cells as binary digits, from 1 (least significant) to 9 (most significant). Each node has up to 36 outgoing edges corresponding to the allowed legal moves chosen by a player. The graph is layered by how many moves have been made from 0 (start) to 9 (win). So the layer number, n, is equal to how many cells are flipped up, and hence the number of 1s in the binary index. The number of nodes in layer n is the binomial coefficient 9Cn, so the layer populations are [1,9,36,84,126,126,84,36,9,1]. There are no edges within a layer. Each layer only has edges going out to members of the next highest layer. The root (source) node is the starting position (index 0), which does not have any incoming edges. The final (sink) node is the winning position (index 511), which does not have any outgoing edges. + -- - + START | 0 | Layer 0 + -- - + // / | \\\\ \\\\ \\ first moves | flip 4 : : : | : : : : + -- - + + -- - + + -- - + + -- - + + -- -- + + -- -- + + -- -- + + -- -- - + | 1 | | 2 | | 4 | | 8 | | 16 | | 32 | | 64 | | 128 | Layer 1 + -- - + + -- - + + -- - + + -- - + + -- -- + + -- -- + + -- -- + + -- -- - + | / : : : : : : | / flip 2 | / flip 1 | / | / : : : + -- - + + -- - + + -- - + + -- -- + | 3 | | 5 | | 9 | | 17 | ... .. 36 nodes ... . Layer 2 + -- - + + -- - + + -- - + + -- -- + : : : : : : : : \\ | / winning moves : + -- -- - + : WIN | 511 | Layer 9 + -- -- - + The outgoing edges from a board position node go the next position node in the game Graph. The edge corresponds to the flipping of exactly one cell in the board. Each edge is weighted with the count of the number of rolls of the dice that would lead to that move being chosen by a specific player. For example, the 15 rolls {1,3} {3,1} {2,2} {4, } { ,4} might all result in flipping cell 4 and moving to the same next position node, so the edge count would be 15. Each node also stores the probability of reaching that position, which is the sum of probabilites along each path of edges leading to the position. To calculate the full set of probabilities for every node in the graph: Initialize the probability of the start node (index 0) to 1.0. For each position node, in order of layers: For each edge going out from the source node: Calculate the edge contribution as the source node probability multiplied by the edge weight, which is edge count/36. Increment the destination node probability with the edge contribution. At the last node (index 511, layer 9), there are no outgoing edges, and the final value is the winning probability. HiLo Success Rate Just in case you want the answer without running the code: game graph analysis calculates the success rate of HiLo as 7.9855 %, so about 2 wins in every 25 games.","ref":"Jackpot.html","title":"Jackpot","type":"module"},{"doc":"A trivial strategy that always chooses the first cell in the list of choices.","ref":"Jackpot.AgentFirst.html","title":"Jackpot.AgentFirst","type":"module"},{"doc":"","ref":"Jackpot.AgentFirst.html#move/1","title":"Jackpot.AgentFirst.move/1","type":"function"},{"doc":"HiLo implementation using an explicit priority sequence, but is quadratic in the worst case.","ref":"Jackpot.AgentHiLo.html","title":"Jackpot.AgentHiLo","type":"module"},{"doc":"","ref":"Jackpot.AgentHiLo.html#move/1","title":"Jackpot.AgentHiLo.move/1","type":"function"},{"doc":"HiLo implementation uses a maximum threshold then minimum. Initial chance of performing both scans on starting board is about 50%, but this goes up to 100% as 7, 8 and 9 are flipped.","ref":"Jackpot.AgentHiLo2.html","title":"Jackpot.AgentHiLo2","type":"module"},{"doc":"","ref":"Jackpot.AgentHiLo2.html#move/1","title":"Jackpot.AgentHiLo2.move/1","type":"function"},{"doc":"A trivial strategy that always chooses the last cell in the list of choices.","ref":"Jackpot.AgentLast.html","title":"Jackpot.AgentLast","type":"module"},{"doc":"","ref":"Jackpot.AgentLast.html#move/1","title":"Jackpot.AgentLast.move/1","type":"function"},{"doc":"A trivial strategy that always chooses the highest value cell.","ref":"Jackpot.AgentMax.html","title":"Jackpot.AgentMax","type":"module"},{"doc":"","ref":"Jackpot.AgentMax.html#move/1","title":"Jackpot.AgentMax.move/1","type":"function"},{"doc":"A trivial strategy that always chooses the lowest value cell.","ref":"Jackpot.AgentMin.html","title":"Jackpot.AgentMin","type":"module"},{"doc":"","ref":"Jackpot.AgentMin.html#move/1","title":"Jackpot.AgentMin.move/1","type":"function"},{"doc":"The Jackpot board of 9 cells that can be flipped.","ref":"Jackpot.Board.html","title":"Jackpot.Board","type":"module"},{"doc":"Generate all 512 possible boards from start (index 0) to winning (index 511).","ref":"Jackpot.Board.html#all_boards/0","title":"Jackpot.Board.all_boards/0","type":"function"},{"doc":"Find if the cell is flipped up (true) or not (false).","ref":"Jackpot.Board.html#cell?/2","title":"Jackpot.Board.cell?/2","type":"function"},{"doc":"Make a move by flipping a cell from false to true. It is an error if the cell has already been flipped.","ref":"Jackpot.Board.html#flip/2","title":"Jackpot.Board.flip/2","type":"function"},{"doc":"Calculate the index for a board, by interpreting the cells as binary digits, starting at cell 1 (least significant) to cell 9 (most significant).","ref":"Jackpot.Board.html#index/1","title":"Jackpot.Board.index/1","type":"function"},{"doc":"Let a player make a move for a specific roll in a given position. The set of possible cell choices has been calculated from the roll. This function wraps the player move by enforcing pre-conditions and checking post-conditions. The cells are filtered to only those allowed by the current position. If there are no allowed cell choices, the game is lost. If there is exactly one cell choice, that move is forced. If there is more than one cell choice, then the player makes the decision. The player's move must be an allowed cell choice. The function returns :no_move with the losing board position, or the chosen cell move with the new board position.","ref":"Jackpot.Board.html#move/3","title":"Jackpot.Board.move/3","type":"function"},{"doc":"A new board in the starting position (index 0).","ref":"Jackpot.Board.html#new/0","title":"Jackpot.Board.new/0","type":"function"},{"doc":"A board position for a specific index, interpreted as a sequence of binary digits.","ref":"Jackpot.Board.html#new/1","title":"Jackpot.Board.new/1","type":"function"},{"doc":"Test if a board is the winning position with all cells flipped (index 511).","ref":"Jackpot.Board.html#win?/1","title":"Jackpot.Board.win?/1","type":"function"},{"doc":"Simulate random die and roll of 2 dice. Implement the Jackpot logic of converting a roll of 2 dice into a set of cells that can be flipped. Generate all possible rolls of 2 dice, hence generate the set of all possible cell choices.","ref":"Jackpot.Dice.html","title":"Jackpot.Dice","type":"module"},{"doc":"The list of all allowed cell choices from roll of 2 dice.","ref":"Jackpot.Dice.html#all_cells/0","title":"Jackpot.Dice.all_cells/0","type":"function"},{"doc":"The list of all possible rolls of 2 dice.","ref":"Jackpot.Dice.html#all_rolls/0","title":"Jackpot.Dice.all_rolls/0","type":"function"},{"doc":"Convert a roll of 2 dice into a list of allowed cell choices.","ref":"Jackpot.Dice.html#cells/1","title":"Jackpot.Dice.cells/1","type":"function"},{"doc":"Simulated random roll of 2 dice.","ref":"Jackpot.Dice.html#roll/0","title":"Jackpot.Dice.roll/0","type":"function"},{"doc":"Play a game of Jackpot with a player agent. Run Monte Carlo simulation of many games to generate win/loss statistics.","ref":"Jackpot.Game.html","title":"Jackpot.Game","type":"module"},{"doc":"Run many games for a player agent. Return statistics of winning and losing. The larger the number of games, the more accurate the statistics.","ref":"Jackpot.Game.html#monte_carlo/2","title":"Jackpot.Game.monte_carlo/2","type":"function"},{"doc":"Play a new game for a player agent.","ref":"Jackpot.Game.html#play/1","title":"Jackpot.Game.play/1","type":"function"},{"doc":"Analyze the play of a player agent across all possible games. The algorithm uses two passes. The first builds a game graph using board positions as nodes, and player moves as edges between nodes. The second pass traverses the graph from the start position node, propagating probability between layers of the graph, which correspond to successive moves in the games. Finally the win probabillity is read out from the win position node.","ref":"Jackpot.Graph.html","title":"Jackpot.Graph","type":"module"},{"doc":"Get the analytic probability of win/lose for a player.","ref":"Jackpot.Graph.html#calculate_outcomes/1","title":"Jackpot.Graph.calculate_outcomes/1","type":"function"},{"doc":"Types for the Jackpot application.","ref":"Jackpot.T.html","title":"Jackpot.T","type":"module"},{"doc":"","ref":"Jackpot.T.html#is_cell/1","title":"Jackpot.T.is_cell/1","type":"macro"},{"doc":"","ref":"Jackpot.T.html#is_count/1","title":"Jackpot.T.is_count/1","type":"macro"},{"doc":"","ref":"Jackpot.T.html#is_die/1","title":"Jackpot.T.is_die/1","type":"macro"},{"doc":"","ref":"Jackpot.T.html#is_index/1","title":"Jackpot.T.is_index/1","type":"macro"},{"doc":"","ref":"Jackpot.T.html#is_move/1","title":"Jackpot.T.is_move/1","type":"macro"},{"doc":"","ref":"Jackpot.T.html#is_non_empty_cells/1","title":"Jackpot.T.is_non_empty_cells/1","type":"macro"},{"doc":"","ref":"Jackpot.T.html#is_pc/1","title":"Jackpot.T.is_pc/1","type":"macro"},{"doc":"","ref":"Jackpot.T.html#is_prob/1","title":"Jackpot.T.is_prob/1","type":"macro"},{"doc":"","ref":"Jackpot.T.html#is_roll/1","title":"Jackpot.T.is_roll/1","type":"macro"},{"doc":"The board is a row of 9 cells. The cells are held in a map for fast lookup.","ref":"Jackpot.T.html#t:board/0","title":"Jackpot.T.board/0","type":"type"},{"doc":"The set of all possible boards, accessed by integer index.","ref":"Jackpot.T.html#t:boards/0","title":"Jackpot.T.boards/0","type":"type"},{"doc":"A single cell on the board, which can be down (false) or flipped up (true). Cells are ordered and numbered from left (1) to right (9).","ref":"Jackpot.T.html#t:cell/0","title":"Jackpot.T.cell/0","type":"type"},{"doc":"A set of cells that can be played from a roll of 2 dice. The list calculated from the roll will have 1, 2 or 3 elements. The set may be filtered by removing cells that are already flipped (true). The result is a set of possible moves in the game, which may be empty if all the cells are already flipped up.","ref":"Jackpot.T.html#t:cells/0","title":"Jackpot.T.cells/0","type":"type"},{"doc":"A count of the number of rolls of 2 dice that lead to the same cell choice.","ref":"Jackpot.T.html#t:count/0","title":"Jackpot.T.count/0","type":"type"},{"doc":"A single die with numbers 1..6","ref":"Jackpot.T.html#t:die/0","title":"Jackpot.T.die/0","type":"type"},{"doc":"The outgoing edges from a board position node to the next position node in the game Graph. The edge corresponds to the flipping of exactly one cell in the board. The edges are stored as the destination node (board position index) with the number of dice rolls for which the player would choose that move. For example, the 15 rolls {1,3} {3,1} {2,2} {4, } { ,4} might all result in flipping cell 4 and moving to the same next position node.","ref":"Jackpot.T.html#t:edges/0","title":"Jackpot.T.edges/0","type":"type"},{"doc":"A game is the current board position, a player, and the historical sequence of moves already played. A game is complete if it is won or lost. A winning game has a board with all cells flipped (index 511) and 9 moves containing all cells exactly once, without any :no_move blocked position. A losing game has a board with at least one cell not flipped, and the last move is a blocked position with :no_move .","ref":"Jackpot.T.html#t:game/0","title":"Jackpot.T.game/0","type":"type"},{"doc":"A game graph is a directed graph containing board positions as nodes, and moves as edges. The set of nodes contains all 512 possible board positions. Each node has up to 36 outgoing edges corresponding to the allowed legal moves chosen by a player agent. The graph is layered by how many moves have been made (i.e. how many cells are flipped) from 0 (start) to 9 (win). There are no edges within a layer. Each layer only has edges going out to members of the next highest layer. The root (source) node is the starting position (index 0), which does not have any incoming edges. The final (sink) node is the winning position (index 511), which does not have any outgoing edges. Each node also stores the probability of reaching that position, which is the sum of probabilites along each path of edges leading to the position.","ref":"Jackpot.T.html#t:graph/0","title":"Jackpot.T.graph/0","type":"type"},{"doc":"The index of a board position is the integer represented by treating cells as binary digits. The bits are shifted by cell number, so the binary number is read from left (1st - least significant) to right (9th - most signiificant). The start position with all cells off (0, false) has index 0. The winning position with all cells on (1, true) has index 511 which is 2^9 - 1.","ref":"Jackpot.T.html#t:index/0","title":"Jackpot.T.index/0","type":"type"},{"doc":"A move in the game is a roll of 2 dice, with a choice of which cell to flip, or :no_move if there is no valid move and the game is lost.","ref":"Jackpot.T.html#t:move/0","title":"Jackpot.T.move/0","type":"type"},{"doc":"A game history is a sequence of moves.","ref":"Jackpot.T.html#t:moves/0","title":"Jackpot.T.moves/0","type":"type"},{"doc":"The outcome of a game is always win or lose.","ref":"Jackpot.T.html#t:outcome/0","title":"Jackpot.T.outcome/0","type":"type"},{"doc":"Probability of winning or losing as a percentage.","ref":"Jackpot.T.html#t:percent/0","title":"Jackpot.T.percent/0","type":"type"},{"doc":"A player is implemented as a module with a move function.&quot;&quot;","ref":"Jackpot.T.html#t:player/0","title":"Jackpot.T.player/0","type":"type"},{"doc":"Probability of some event in the game.","ref":"Jackpot.T.html#t:probability/0","title":"Jackpot.T.probability/0","type":"type"},{"doc":"The result of a game is an outcome, the final board position, and the sequence of moves that were played.","ref":"Jackpot.T.html#t:result/0","title":"Jackpot.T.result/0","type":"type"},{"doc":"A roll of 2 dice with numbers 1..6","ref":"Jackpot.T.html#t:roll/0","title":"Jackpot.T.roll/0","type":"type"},{"doc":"Statistics for winning or losing.","ref":"Jackpot.T.html#t:statistics/0","title":"Jackpot.T.statistics/0","type":"type"},{"doc":"Utilities for the Jackpot application.","ref":"Jackpot.Util.html","title":"Jackpot.Util","type":"module"},{"doc":"Increment an integer value in a map. If the key is missing, use a default initial value of 0.","ref":"Jackpot.Util.html#inc/2","title":"Jackpot.Util.inc/2","type":"function"},{"doc":"Calculate percentage to 2 decimal places.","ref":"Jackpot.Util.html#pc/1","title":"Jackpot.Util.pc/1","type":"function"}]