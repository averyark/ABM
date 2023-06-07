--[[
    FileName    > initialize.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 31/05/2023
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local astrax = require(ReplicatedStorage.Packages.Astrax)

astrax.module.setModuleFolder(ReplicatedStorage.client)
astrax.start():andThen(function() 
    print("[AstraxFramework] Framework loaded on the client")
end)

local methods = {}

function methods.foo(self: class)
    self.x = 1
end

function methods.__init__(self: class)
    
end

local class = astrax.class.new("testingObject", methods)

local new = function()
    local meta = {}
    local object = astrax.class.construct(meta, class)

    meta.a = 1
    meta.b = "test"
    meta.c = true

    return object :: typeof(object) & typeof(methods) & typeof(meta)
end

type class = typeof(new())

local object = new()

object:foo()

astrax.dataClient:connect({"a"}, function(changes)
    print(changes)
end)