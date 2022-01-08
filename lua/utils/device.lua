local Enumerator = require("udev.enumerator")
local UDevice = require("udev.device")
local h = require("utils.helper")

---@param dec number
---@param length? number
---@return string
local function dec_to_hex(dec, length)
  return string.format("%0" .. tostring(length or 4) .. "x", dec)
end

---@param hex string
---@return number
local function hex_to_dec(hex)
  return tonumber(hex, 16)
end

local mod = {}

local property_name_by_input_type = {
  KEYBOARD = "ID_INPUT_KEYBOARD",
  KEY = "ID_INPUT_KEY",
  MOUSE = "ID_INPUT_MOUSE",
  TOUCHPAD = "ID_INPUT_TOUCHPAD",
  TOUCHSCREEN = "ID_INPUT_TOUCHSCREEN",
  TABLET = "ID_INPUT_TABLET",
  JOYSTICK = "ID_INPUT_JOYSTICK",
  ACCELEROMETER = "ID_INPUT_ACCELEROMETER",
}

local property_name_by_filter_key = {
  vendor_id = "ID_VENDOR_ID",
  vendor_name = "ID_VENDOR",
  product_id = "ID_MODEL_ID",
  product_name = "ID_MODEL",
}

local filter_value_transformer_by_property_name = {
  ID_VENDOR_ID = dec_to_hex,
  ID_MODEL_ID = dec_to_hex,
}

function mod.list_input_devices(filters)
  filters = filters or {}

  local enumerator = Enumerator:new()

  enumerator:filter_match("subsystem", "input")

  if filters.type and property_name_by_input_type[filters.type] then
    enumerator:filter_match("property", property_name_by_input_type[filters.type], "1")
  end

  for key, property_name in pairs(property_name_by_filter_key) do
    if filters[key] then
      local transformer = filter_value_transformer_by_property_name[property_name]
      enumerator:filter_match("property", property_name, transformer and transformer(filters[key]) or filters[key])
    end
  end

  if filters.tag then
    for _, tag in ipairs(filters.tag) do
      enumerator:filter_match("tag", tag)
    end
  end

  local function to_device(syspath)
    local udev = UDevice:new("syspath", enumerator.context, syspath)

    local devnode = udev:devnode()
    if devnode == "" then
      return
    end

    local vendor_id = udev:property_value("ID_VENDOR_ID")
    if vendor_id == "" then
      return
    end

    local product_id = udev:property_value("ID_MODEL_ID")
    if product_id == "" then
      return
    end

    local devlinks = h.map(udev:devlink_list():entries(), function(entry)
      return entry.name
    end)

    if
      filters.devlink
      and not h.some(devlinks, function(devlink)
        return h.some(filters.devlink, function(devlink_pattern)
          return string.match(devlink, devlink_pattern)
        end)
      end)
    then
      return
    end

    local tags = h.map(udev:tag_list():entries(), function(tag)
      return tag.name
    end)

    local device = {
      devlinks = devlinks,
      devnode = devnode,
      product_id = hex_to_dec(product_id),
      product_name = udev:property_value("ID_MODEL"),
      tags = tags,
      vendor_id = hex_to_dec(vendor_id),
      vendor_name = udev:property_value("ID_VENDOR"),
    }

    return device
  end

  local devices = {}

  for entry in enumerator:device_list() do
    local device = to_device(entry.name)

    if device then
      table.insert(devices, device)
    end
  end

  return devices
end

return mod
