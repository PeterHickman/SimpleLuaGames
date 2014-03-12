#!/usr/bin/env lua

require('strict')

board = {
  {0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0},
}

all_lines_of_four = {
  -- Horizontal lines
  {{1,1},{1,2},{1,3},{1,4}},{{1,2},{1,3},{1,4},{1,5}},{{1,3},{1,4},{1,5},{1,6}},{{1,4},{1,5},{1,6},{1,7}},
  {{2,1},{2,2},{2,3},{2,4}},{{2,2},{2,3},{2,4},{2,5}},{{2,3},{2,4},{2,5},{2,6}},{{2,4},{2,5},{2,6},{2,7}},
  {{3,1},{3,2},{3,3},{3,4}},{{3,2},{3,3},{3,4},{3,5}},{{3,3},{3,4},{3,5},{3,6}},{{3,4},{3,5},{3,6},{3,7}},
  {{4,1},{4,2},{4,3},{4,4}},{{4,2},{4,3},{4,4},{4,5}},{{4,3},{4,4},{4,5},{4,6}},{{4,4},{4,5},{4,6},{4,7}},
  {{5,1},{5,2},{5,3},{5,4}},{{5,2},{5,3},{5,4},{5,5}},{{5,3},{5,4},{5,5},{5,6}},{{5,4},{5,5},{5,6},{5,7}},
  {{6,1},{6,2},{6,3},{6,4}},{{6,2},{6,3},{6,4},{6,5}},{{6,3},{6,4},{6,5},{6,6}},{{6,4},{6,5},{6,6},{6,7}},

  -- Vertical lines
  {{1,1},{2,1},{3,1},{4,1}},{{2,1},{3,1},{4,1},{5,1}},{{3,1},{4,1},{5,1},{6,1}},
  {{1,2},{2,2},{3,2},{4,2}},{{2,2},{3,2},{4,2},{5,2}},{{3,2},{4,2},{5,2},{6,2}},
  {{1,3},{2,3},{3,3},{4,3}},{{2,3},{3,3},{4,3},{5,3}},{{3,3},{4,3},{5,3},{6,3}},
  {{1,4},{2,4},{3,4},{4,4}},{{2,4},{3,4},{4,4},{5,4}},{{3,4},{4,4},{5,4},{6,4}},
  {{1,5},{2,5},{3,5},{4,5}},{{2,5},{3,5},{4,5},{5,5}},{{3,5},{4,5},{5,5},{6,5}},
  {{1,6},{2,6},{3,6},{4,6}},{{2,6},{3,6},{4,6},{5,6}},{{3,6},{4,6},{5,6},{6,6}},
  {{1,7},{2,7},{3,7},{4,7}},{{2,7},{3,7},{4,7},{5,7}},{{3,7},{4,7},{5,7},{6,7}},

  -- Diagonal lines /
  {{6,1},{5,2},{4,3},{3,4}},{{6,2},{5,3},{4,4},{3,5}},{{6,3},{5,4},{4,5},{3,6}},{{6,4},{5,5},{4,6},{3,7}},
  {{5,1},{4,2},{3,3},{2,4}},{{5,2},{4,3},{3,4},{2,5}},{{5,3},{4,4},{3,5},{2,6}},{{5,4},{4,5},{3,6},{2,7}},
  {{4,1},{3,2},{2,3},{1,4}},{{4,2},{3,3},{2,4},{1,5}},{{4,3},{3,4},{2,5},{1,6}},{{4,4},{3,5},{2,6},{1,7}},

  -- Diagonal lines \

  {{6,7},{5,6},{4,5},{3,4}},{{6,6},{5,5},{4,4},{3,3}},{{6,5},{5,4},{4,3},{3,2}},{{6,4},{5,3},{4,2},{3,1}},
  {{5,7},{4,6},{3,5},{2,4}},{{5,6},{4,5},{3,4},{2,3}},{{5,5},{4,4},{3,3},{2,2}},{{5,4},{4,3},{3,2},{2,1}},
  {{4,7},{3,6},{2,5},{1,4}},{{4,6},{3,5},{2,4},{1,3}},{{4,5},{3,4},{2,3},{1,2}},{{4,4},{3,3},{2,2},{1,1}}
}

function show_board(board)
  local r, c

  for r=1,6 do
    for c=1,7 do
      if board[r][c] == 0 then
        io.write('.')
      else
        io.write(board[r][c])
      end
    end
    print()
  end

  print("-------")
  print("1234567")
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
  local function free_space_in_column(board, column)
    local row

    for row=6,1,-1 do
      if board[row][column] == 0 then
        return row
      end
    end
    
    return false
  end

  local got_input, row, column

  print("Ok " .. name .. ". Make your move!")

  got_input = false

  while got_input == false do
    print("Enter the column (1 to 7)")
    column = tonumber(io.read())

    row = free_space_in_column(board, column)
    if row then
      board[row][column] = symbol
      got_input = true
    else
        print("You can't go there")
    end
  end
end

function the_computer_makes_a_move(board, symbol)
  local function place_a_fourth(board, check, symbol)
    local v
    local ours = 0
    local free = 0
    local free_at = nil
    local theirs = 0

    for _,v in pairs(check) do
      if board[v[1]][v[2]] == symbol then
        ours = ours + 1
      elseif board[v[1]][v[2]] == 0 then
        free = free + 1
        free_at = v
      else
        theirs = theirs + 1
       end
    end

    if ours == 3 and free == 1 then
      -- Is the row below filled or not
      if free_at[1] ~= 6 then
        if board[free_at[1]+1][free_at[2]] == 0 then
          return nil
        else
          return free_at
        end
      else
        return free_at
      end
    else
      return nil
    end
  end

  local r, c, v, pos, other_symbol

  -- We need to check that the move is valid. i.e. that there are 
  -- no cells with a 0 in them below the line being created

  -- Can we create a line
  for _,v in pairs(all_lines_of_four) do
    pos = place_a_fourth(board, v, symbol)
    if pos then
      board[pos[1]][pos[2]] = symbol
      return
    end
  end

  -- Can we stop our opponent making a line
  other_symbol = get_other_symbol(symbol)

  for _,v in pairs(all_lines_of_four) do
    pos = place_a_fourth(board, v, other_symbol)
    if pos then
      board[pos[1]][pos[2]] = symbol
      return
    end
  end

  -- Perhaps do something intelligent

  -- Now what?
  for r=6,1,-1 do
    for c=1,7 do
      if board[r][c] == 0 then
        board[r][c] = symbol
        return
      end
    end
  end
end

function this_player_has_won(board, symbol)
  local function line_of_four(board, check)
    local v

    for _,v in pairs(check) do
    if board[v[1]][v[2]] ~= symbol then
      return false
    end
   end

    return true
  end
  
  local v

  for _,v in pairs(all_lines_of_four) do
    if line_of_four(board, v) then
      return true
    end
  end

  -- Nope
  return false
end

function no_moves_left(board)
  local row, column

  for row=1,6 do
    for column=1,7 do
      if board[row][column] == 0 then
        return false
      end
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
