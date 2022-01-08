local function patch_package_path()
  package.path = package.path .. ";deps/?.lua;deps/?/init.lua"
  package.path = package.path .. ";libs/?.lua;libs/?/init.lua"
  package.path = package.path .. ";lua/?.lua;lua/?/init.lua"
end

patch_package_path()
