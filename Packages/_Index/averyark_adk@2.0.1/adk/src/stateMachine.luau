-- THIS MODULE IS DISABLE AND IS CURRENTLY NOT USED IN ASTRAX DEVELOPMENT KIT
-- ~~ Until I find a good way of how It should work

--!nonstrict
--[[
    FileName    > stateMachine.luau
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 02/06/2023
--]]

--[[local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = script.Parent.Parent
local Promise = require(Packages.Promise)
local Signal = require(Packages.Signal)
local things = require(script.Parent.things)
local Janitor = require(Packages.Janitor)
local Red = require(Packages.Red)
local t = require(Packages.t)
local class = require(script.Parent.class)

local stateMachine = {}
local states = {}
local methods = {}
local whenStatements = {}
local appliedStates = {}

local stateClass = class.new("stateClass", methods)

local function newState(module: ModuleScript)
    local metatable = {}

    metatable.onHeartbeat = nil :: (self: state, dt: number) -> ()?
    metatable.onRenderStepped = nil :: (self: state, dt: number) -> ()?
    metatable.onStepped = nil :: (self: state, dt: number) -> ()?
    metatable.onStateApplied = nil :: <a>(self: state, target: a) -> ()?
    metatable.module = module

    return class.construct(metatable, stateClass)
end

type state = typeof(newState(Instance.new("ModuleScript")))

function methods.__init__(self: state)
    table.insert(states, self)
end

function methods.Destroy(self : state) 
    table.remove(states, table.find(states, self))
end

local function findObject(tb, module: ModuleScript) : (state)?
    assert(t.table(tb))
    assert(t.instanceIsA("ModuleScript")(module))
    for _, object in pairs(tb) do
        if object.module == module then
            return object
        end
    end
    return
end

local function applyState(target, state: ModuleScript)
    assert(t.instanceIsA("ModuleScript")(state))
    stateMachine.waitFor()

    local stateObject = findObject(states, state)

    assert(stateObject, "nonexistant state passed, is it registred?" .. state.Name)

    if not stateObject or not stateObject.onStateApplied then
        warn("[AstraxFramework] onStateApplied is not set for this state", state)
        return
    end

    appliedStates[target] = stateObject

    Promise.try(stateObject.onStateApplied, stateObject, target)

    return 
end

local function when<a>(target: a, condition: (target: a) -> (boolean), callback: (target: a) -> ())
    assert(t.callback(condition))
    assert(t.callback(callback))
    stateMachine.waitFor()

    table.insert(whenStatements, {
        target = target,
        condition = condition,
        callback = callback,
        ready = true,
    })
end

local function isState(target, state: ModuleScript)
    assert(t.instanceIsA("ModuleScript")(state))
    stateMachine.waitFor()

    if appliedStates[target] and appliedStates[target].module :: ModuleScript == state then
        return true
    end
    return false
end

local started = false

stateMachine.waitFor = function()
    if started then return end

    repeat 
        task.wait(.1)
    until started
    return
end

stateMachine.start = function()
    RunService.RenderStepped:Connect(function(dt)
        for _, conditionObject in pairs(states) do
            if conditionObject.onRenderStepped then
                task.spawn(conditionObject.onRenderStepped, conditionObject, dt)
            end
        end
        for _, whenStatement in pairs(whenStatements) do
            if whenStatement.ready and whenStatement.condition(whenStatement.target) then
                task.spawn(function() 
                    whenStatement.ready = false
                    whenStatement.callback(whenStatement.target)
                    whenStatement.ready = true
                end)
            end
        end

    end)
end

stateMachine.setStateFolder = function(stateFolder)
    local promises = {}
    for _, state in pairs(stateFolder:GetDescendants()) do
        if not state:IsA("ModuleScript") then continue end
        table.insert(promises, Promise.new(function(resolve) 
            resolve(require(state))
        end))
    end
    Promise.all(promises):await()
    started = true
end

stateMachine.state = newState
stateMachine.apply = applyState
stateMachine.when = when
stateMachine.isState = isState

return stateMachine]]

return {}