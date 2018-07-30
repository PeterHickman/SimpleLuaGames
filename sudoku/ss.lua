local ss = { board = {} }

-- Functions that work with the cell

--- Calculate the minigrid a cell belongs in.
-- @param r the row
-- @param c the column
-- @returns an integer from 1 .. 9
local function minigrid(r, c)
  if r <= 3 then
    if c <= 3 then
      return 1
    elseif c <= 6 then
      return 2
    else
      return 3
    end
  elseif r <= 6 then
    if c <= 3 then
      return 4
    elseif c <= 6 then
      return 5
    else
      return 6
    end
  else
    if c <= 3 then
      return 7
    elseif c <= 6 then
      return 8
    else
      return 9
   end
  end
end

--- Create the basic cell structure.
-- @param r the row
-- @param c the column
-- @returns teh new cell
local function make_cell(r, c)
  local t = {}

  t.r = r
  t.c = c
  t.m = minigrid(r, c)
  t.candidates = { true, true, true, true, true, true, true, true, true }
  t.count = 9
  t.display = '#'
  t.locked = false

  return t
end

--- Set a cell to value.
-- Set the cell to value providing that value is a
-- viable candidate and that the cell's value has not
-- already been set
-- @param cell the cell
-- @param value the value to set
local function set(cell, value)
  if cell.candidates[value] == true then
    if cell.count == 1 then
      print("ERROR: This cell has already been set")
    else
      for i = 1,9 do
        cell.candidates[i] = false
      end
      cell.candidates[value] = true
      cell.count = 1
      cell.display = value
    end
  else
    print("ERROR: " .. value .. " is not available to be set")
  end
end

--- Remove value as a candidate.
-- Remove value as a candidate providing that it is
-- and candidate and not the last remaining value
-- @param cell the cell
-- @param value the value to eliminate
local function eliminate(cell, value)
  local any_changes = false

  if cell.candidates[value] == true then
    if cell.count == 1 then
      print("ERROR: Cannot eliminate final value")
    else
      cell.candidates[value] = false
      cell.count = cell.count - 1
      any_changes = true
    end
  end

  return any_changes
end

--- Patch the cell to display the correct value.
-- Makes sure that the display value is correct
-- @param cell the cell
local function actual(cell)
  if cell.count == 1 then
    for v = 1,9 do
      if cell.candidates[v] == true then
        cell.display = v
        break
      end
    end
  end
end

--- Show the available candidates.
-- @param cell the cell
-- @returns a string
local function debug_values(cell)
  local s = ''
  for c = 1,9 do
    if cell.candidates[c] == true then
      s = s .. c
    else
      s = s .. '.'
    end
  end
  return s
end
            
-- Functions that work with the board

--- Return the cell identified by r and c from the board.
-- @param r the row the cell is in
-- @param c the column the cell is in
-- @returns the cell
local function get_cell(r, c)
  for _, cell in pairs(ss.board) do
    if cell.r == r and cell.c == c then
      return cell
    end
  end
end

-- The public functions

--- Make a board filled with cells in their initial state.
-- Populate the board global ss.board with cells
function ss.make()
  ss.board = {}

  for r = 1,9 do
    for c = 1,9 do
      table.insert(ss.board, make_cell(r, c))
    end
  end
end

--- Set a cell to value.
-- @param r the row the cell is in
-- @param c the column the cell is in
-- @param value the value to set the cell to
function ss.set_cell(r, c, value)
  local cell = get_cell(r, c)
  set(cell, value)
end

--- Display the current state of the board.
function ss.show()
  local s = ''

  print('|---+---+---|')

  for r = 1,9 do
    for c = 1,9 do
      cell = get_cell(r, c)
      s = s .. cell.display
      if c == 3 or c == 6 then
        s = s .. '|'
      end
    end
    print('|' .. s .. '|')
    s = ''
    if r == 3 or r == 6 then
      print('|---+---+---|')
    end
  end

  print('|---+---+---|')
  print()
end

--- Display the current state of the board with cell debugging.
function ss.show_debug()
  local s = ''

  print('|--------- --------- ---------+--------- --------- ---------+--------- --------- ---------|')

  for r = 1,9 do
    for c = 1,9 do
      cell = get_cell(r, c)
      s = s .. debug_values(cell)
      if c == 3 or c == 6 then
        s = s .. '|'
      elseif c ~= 9 then
        s = s .. " "
      end
    end
    print('|' .. s .. '|')
    s = ''
    if r == 3 or r == 6 then
      print('|--------- --------- ---------+--------- --------- ---------+--------- --------- ---------|')
    end
  end

  print('|--------- --------- ---------+--------- --------- ---------+--------- --------- ---------|')
  print()
end

--- Save the board to file.
-- Save only the cells that have a single value
-- @param filename a string of the file to write the board to
function ss.save(filename)
  print("Saving current state to " .. filename)

  local file = io.open (filename, 'w')

  for _, cell in pairs(ss.board) do
    if cell.count == 1 then
      file:write(cell.r .. " " .. cell.c .. " " .. cell.display .. "\n")
    end
  end

  io.close()
end

--- Load the board from a file.
-- @param filename a string of the file to load
function ss.load(filename)
  print("Reading saved state from " .. filename)

  local line = ''

  for line in io.lines(filename) do
    if line:sub(1,1,2) ~= '#' then
      local parts = {}
      for part in line:gmatch("%w+") do
        table.insert(parts, tonumber(part))
      end
      ss.set_cell(parts[1], parts[2], parts[3])
    end
  end
end

--- Mark all the cells that have only one value as locked.
function ss.lock()
  for _, cell in pairs(ss.board) do
    cell.locked = cell.count == 1
  end
end

--- Reset all the unlocked cells.
-- Set all cells that are not locked to their initial defaults
function ss.reset()
  for _, cell in pairs(ss.board) do
    if cell.locked == false then
      cell.candidates = { true, true, true, true, true, true, true, true, true }
      cell.count = 9
      cell.display = '#'
    end
  end
end

function ss.pass()
  local any_change = false

  for _, cell in pairs(ss.board) do
    if cell.count == 1 and cell.display == '#' then
      actual(cell)
    end

    if cell.count == 1 then
      for r = 1,9 do
        for c = 1,9 do
          local m = minigrid(r, c)
          if cell.r == r or cell.c == c or cell.m == m then
            if cell.r ~= r or cell.c ~= c then
              changed = eliminate(get_cell(r, c), cell.display)
              if changed == true then
                any_change = true
              end
            end
          end
        end
      end
    end
  end

  for _, cell in pairs(ss.board) do
    actual(cell)
  end

  return any_change
end

--- See if there is still work to do.
function ss.not_finished()
  local still_to_do = 0

  for _, cell in pairs(ss.board) do
    if cell.count ~= 1 then
      still_to_do = still_to_do + 1
    end
  end

  return still_to_do ~= 0
end

--- Validate the state of the board.
function ss.validate()
  local ok = true

  -- Row checks
  for r = 1,9 do
    local t = {false, false, false, false, false, false, false, false, false}
    for c = 1,9 do
      local cell = get_cell(r, c)
      if cell.count == 1 then
        if t[cell.display] == false then
          t[cell.display] = true
        else
          print("ERROR: ROW CHECK r=" .. r .. " c=" .. c .. " already set to " .. cell.display)
          ok = false
        end
      end
    end
  end

  -- Column checks
  for c = 1,9 do
    local t = {false, false, false, false, false, false, false, false, false}
    for r = 1,9 do
      local cell = get_cell(r, c)
      if cell.count == 1 then
        if t[cell.display] == false then
          t[cell.display] = true
        else
          print("ERROR: COLUMN CHECK r=" .. r .. " c=" .. c .. " already set to " .. cell.display)
          ok = false
        end
      end
    end
  end

  -- Minigrid check
  for m = 1,9 do
    local t = {false, false, false, false, false, false, false, false, false}
    for r = 1,9 do
      for c = 1,9 do
        local cell = get_cell(r, c)
        if cell.m == m then
          if cell.count == 1 then
            if t[cell.display] == false then
              t[cell.display] = true
            else
              print("ERROR: MINIGRID CHECK r=" .. r .. " c=" .. c .. " already set to " .. cell.display)
              ok = false
            end
          end
        end
      end
    end
  end

  return ok
end

return ss
