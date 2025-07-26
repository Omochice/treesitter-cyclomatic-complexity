-- Test fixtures for Lua complexity calculation

-- Simple function (CC: 1)
function simple_function()
  return 42
end

-- Function with if statement (CC: 2)
function function_with_if(x)
  if x > 0 then
    return x
  end
  return 0
end

-- Function with multiple conditions (CC: 4)
function function_with_multiple_conditions(a, b, c)
  if a > 0 then
    if b > 0 then
      if c > 0 then
        return a + b + c
      end
    end
  end
  return 0
end

-- Function with loops (CC: 3)
function function_with_loops(items)
  for i, item in ipairs(items) do
    while item.valid do
      item = process(item)
    end
  end
end

-- Complex function (CC: 7)
function complex_function(data)
  if not data then
    return nil
  end
  
  local result = {}
  for i, item in ipairs(data) do
    if item.type == 'special' then
      while item.needs_processing do
        if item.can_process then
          item = process_item(item)
        else
          break
        end
      end
    end
    table.insert(result, item)
  end
  
  return result
end

-- Function with repeat loop (CC: 3)
function function_with_repeat(x)
  if x <= 0 then
    return 0
  end
  
  repeat
    x = x - 1
  until x <= 0
  
  return x
end

-- Nested functions (each should be counted separately)
function outer_function()
  local function inner_function(y)
    if y > 0 then
      return y * 2
    end
    return 0
  end
  
  return inner_function(5)
end

-- Local function (CC: 2)
local function local_function(flag)
  if flag then
    return "yes"
  else
    return "no"
  end
end