## Astrax Development Kit
Astrax Development Kit (ADK) provides a collection of helpful libraries that are vital to slothful programmers such as myself.

### Getting started
Astrax requires minimal setup before you can begin using it. The core usage of Astrax is the same on the Server and Client. To begin, call `astrax.module.setModuleFolder(folder)` with the ancestry folder for all your modules. After you set your module folder, call the `astrax.start` function to boot up Astrax. The `astrax.start` function returns a **Promise**, you can chain `:await()` to yield until all modules are loaded.
```lua
local astrax = require(game:GetService("ReplicatedStorage").Packages.Astrax)

-- .setModuleFolder() should be called before .start()
astrax.setModuleFolder(script.Parent)
astrax.start():catch(warn):andThen(function() 
    print("Astrax has initialized successfully")
end):await()
```

### Libraries
Some libraries do not run until you call `astrax.start`, so ensure the function is called before you use it. All libraries are reachable from the astrax module.

#### Data Handler
Have you ever been bothered by the countless events you need to create just to communicate to the client when you updated the player's data? That's not a problem now with the data library. The data handler allows listening to individual paths in a data table with a simple function call!

```lua
-- On the server, we're giving the player coins
local astrax = require(game:GetService("ReplicatedStorage").Packages.Astrax)

game:GetService("Players").PlayerAdded:Connect(function(player)
    -- Retrieve the object for the player, this method yields
    local playerData = astrax.dataServer.getPlayer(player)

    -- Any change that has to replicate to the client must be wrapped within a :apply call
    playerData:apply(function(data)
        data.Coins += 100
    end)
end)
```

```lua
-- On the client
local astrax = require(game:GetService("ReplicatedStorage").Packages.Astrax)

-- The function is called when the data is first initialized. changes.old is always nil for the initialization call
-- With that in mind you'll observe two prints
-- First is the initial data and second is the coins added by the server
astrax.dataClient:connect({"coins"}, function(changes)
    print(changes.old, changes.new)
    -- nil, 0
    -- 0, 100
end)
```

#### Class
The class module provides utility and enables debugging. Create a Class with `astrax.class.new(identifier, methods)` and create an object with `astrax.class.construct(metatable, class)`.

```lua
local methods = {}

-- Unfortunatley due to luau limitations, you have to implicitly type self with typeof(new())
function methods.foo(self: class)
    self.x = 1
end

-- This function is automatically called when the object is initialized
function methods.__init__(self: class)
    self._maid:Add(self.part)
    self:foo()
end

local class = astrax.class.new("object", methods)

local new = function()
    local meta = {}

    meta.a = 1
    meta.b = "something"
    meta.c = true
    meta.x = nil :: number?
    meta.part = Instance.new("Part")

    return astrax.class.construct(meta, class)
end

-- Class type
type class = typeof(new())
```