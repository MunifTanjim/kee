local mod = {}

function mod.map(list, cb)
  local items = {}

  for i, item in ipairs(list) do
    table.insert(items, cb(item, i))
  end

  return items
end

function mod.filter(list, cb)
  local items = {}

  for i, item in ipairs(list) do
    if cb(item, i) then
      table.insert(items, item)
    end
  end

  return items
end

function mod.every(list, cb)
  for i, item in ipairs(list) do
    if not cb(item, i) then
      return false
    end
  end

  return true
end

function mod.some(list, cb)
  for i, item in ipairs(list) do
    if cb(item, i) then
      return true
    end
  end

  return false
end

return mod
