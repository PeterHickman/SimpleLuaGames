#!/usr/bin/env lua

require('strict')

board = {0,0,0,0,0,0,0,0,0}

three_in_a_row = {
  -- rows
  {1,2,3},{4,5,6},{7,8,9},
  -- columns
  {1,4,7},{2,5,8},{3,6,9},
  -- diagonals
  {1,5,9},{3,5,7}
}

function show_board(board)
  local pos, r
  
  print("  | 1 2 3")
  print("--+------")
  for r=1,3 do
    pos = ((r - 1) * 3) + 1
    print(r .. " | " .. board[pos] .. " " .. board[pos+1] .. " " .. board[pos+2])
  end
  print()
end

function get_other_symbol(symbol)
  if symbol == 1 then
    return 2
  else
    return 1
  end
end

function the_player_makes_a_move(board, name, symbol)
  local got_input, pos, row, column

  print("Ok " .. name .. ". Make your move!")

  got_input = false

  while got_input == false do
    print("Enter the row (1, 2 or 3)")
    row = tonumber(io.read())
    print("Enter the column (1, 2 or 3)")
    column = tonumber(io.read())

    pos = ((row - 1) * 3) + column
 
    if board[pos] == 0 then
      board[pos] = symbol
      got_input = true
    else
      print("You can't go there")
    end
  end
end

function the_computer_makes_a_move(board, symbol)
  local function complete_a_line(positions, symbol)
    local ours = 0
    local theirs = 0
    local free = 0
    local free_at = 0
    local pos                               

    for _,pos in pairs(positions) do
      if board[pos] == symbol then
        ours = ours + 1
      elseif board[pos] == 0 then
        free = free + 1
        free_at = pos
      else
        theirs = theirs + 1
      end
    end

    if ours == 2 and free == 1 then
      return free_at
    else
      return nil
    end  
  end
  
  local pos, positions
  local other_symbol = get_other_symbol(symbol)

  -- Can we complete something
  for _,positions in pairs(three_in_a_row) do
    pos = complete_a_line(positions, symbol)
    if pos then
      board[pos] = symbol
      return
    end
  end

  -- Can we stop our opponent completing something
  for _,positions in pairs(three_in_a_row) do
    pos = complete_a_line(positions, other_symbol)
    if pos then
      board[pos] = symbol
      return
    end
  end

  -- Is the center free
  if board[5] == 0 then
    board[5] = symbol
    return
  end

  -- Anywhere will do
  for pos=1,9 do
    if board[pos] == 0 then
      board[pos] = symbol
      return
    end
  end
end

function this_player_has_won(board, symbol)
  local function all_the_same(positions, symbol)
    local v
    for _,v in pairs(positions) do
      if board[v] ~= symbol then
        return false
      end
    end
    return true
  end
  
  local positions

  for _,positions in pairs(three_in_a_row) do
    if all_the_same(positions, symbol) then
      return true
    end
  end

  -- Nope
  return false
end

function no_moves_left(board)
  local i
  
  for i=1,#board do
    if board[i] == 0 then
      return false
    end
  end

  return true
end

player_symbol = 1
game_in_play = true

while game_in_play do
  show_board(board)

  if player_symbol == 1 then
    the_player_makes_a_move(board, 'Human', player_symbol)
    if this_player_has_won(board, player_symbol) then
      print("The Human has won")
      game_in_play = false
    end
  else
    print("The Computer will have it's turn")
    the_computer_makes_a_move(board, player_symbol)
    if this_player_has_won(board, player_symbol) then
      print("The Computer has won")
      game_in_play = false
    end
  end

  if game_in_play and no_moves_left(board) then
    print("Well it seems that is a draw")
    game_in_play = false
  else
    player_symbol = get_other_symbol(player_symbol)
  end
end

show_board(board)
