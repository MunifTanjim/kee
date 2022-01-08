local bundle = require("luvi").bundle
loadstring(bundle.readfile("loader.lua"), "bundle:loader.lua")()

local uv = require("uv")

local util_device = require("utils.device")

local function print_device(dev)
  print("  VENDOR_NAME", dev.vendor_name)
  print("    VENDOR_ID", dev.vendor_id)
  print(" PRODUCT_NAME", dev.product_name)
  print("   PRODUCT_ID", dev.product_id)
  print("      DEVNODE", dev.devnode)
  for _, devlink in ipairs(dev.devlinks) do
    print("      DEVLINK", devlink)
  end
end

print(string.rep("=", 14))
for _, dev in ipairs(util_device.list_input_devices({ type = "KEYBOARD", devlink = { ".+kbd.*" } })) do
  print_device(dev)
  print(string.rep("=", 14))
end

uv.run()
