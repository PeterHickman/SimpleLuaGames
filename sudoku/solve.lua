#!/usr/bin/env lua5.1

local ss = require 'ss'

if arg[1] ~= nil then
  filename = arg[1]
else
  error('No filename given on the command line')
end

ss.make()
ss.load(filename)
ss.lock()
ss.show()

pass = 1
change = false
ok = true

while ss.not_finished() do
  print('Pass ' .. pass)
  change = ss.pass()
  ss.show()

  if ss.validate() == false then
    ok = false
    break
  elseif change == false then
    print('Nothing updated!!!')
    break
  end

  pass = pass + 1
end

if change or ok == false then
  print('Pass ' .. pass)
  ss.pass()
  ss.show()
end
