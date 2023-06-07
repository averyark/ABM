--!strict
--[[
    FileName    > module.luau
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 01/06/2023
--]]

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

local module = {}

local clientModules = {}
local sharedModules = {}

local clientModuleContainer

module.setModuleFolder = function(container: Instance)
	local promises = {}
	for _, module in pairs(container:GetDescendants()) do
		if module:IsA("ModuleScript") then
			table.insert(
				promises,
				Promise.new(function(resolve)
					resolve(require(module))
				end):catch(function(err)
					warn(`[{module.Name}]: initialization failed with error:\n\n`, err.error)
				end)
			)
		end
	end

	Promise.all(promises):andThen(function()
		clientModuleContainer = container
	end)
end

module.new = function<m>(
	identifier: string,
	methods: m & {
		[any]: any,
		load: () -> ()?,
		preload: () -> ()?,
	}
)
	local metatable = {}

	metatable.identifier = identifier

	methods.__index = methods

	table.insert(clientModules, {
		metatable = metatable,
		methods = methods,
	})

	return setmetatable(metatable, methods) :: typeof(metatable) & m
end

module.start = function()
	local waitingClock = os.clock()
	local warned = false

	repeat
		task.wait(0.1)
		if os.clock() - waitingClock >= 5 and not warned then
			warn("[AstraxFramework]: Did you forget to set the client module container?")
			warned = true
		end
	until clientModuleContainer

	local bench = {
		load = {},
		preload = {},
	}
	local errored = {
		load = {},
		preload = {},
	}
	local attempts = {
		load = {},
		preload = {},
	}
	for _, module in pairs(clientModules) do
		if module.methods.preload then
			table.insert(attempts.preload, module.metatable.identifier)
			local beginClock = os.clock()
			Promise.new(function(resolve)
				module.methods.preload()
				table.insert(bench.preload, {
					identifier = module.metatable.identifier,
					bench = os.clock() - beginClock,
				})
				resolve()
			end)
				:catch(function(err)
					warn(
						`[AstraxFramework] Module errored while preloading -> ({module.metatable.identifier})\n\n{err.error}`
					)
					table.insert(errored.preload, {
						identifier = module.metatable.identifier,
						err = err,
					})
				end)
				:await()
		end
	end
	for _, module in pairs(clientModules) do
		if module.methods.load then
			table.insert(attempts.load, module.metatable.identifier)
			local moduleErroredOnPreload = false
			for _, _module in pairs(errored.preload) do
				if _module.identifier == module.metatable.identifier then
					moduleErroredOnPreload = true
				end
			end
			if moduleErroredOnPreload then
				continue
			end
			local beginClock = os.clock()
			Promise.new(function(resolve)
				module.methods.load()
				table.insert(bench.load, {
					identifier = module.metatable.identifier,
					bench = os.clock() - beginClock,
				})
				resolve()
			end):catch(function(err)
				warn(`[AstraxFramework] Module errored while loading -> ({module.metatable.identifier})\n\n{err.trace}`)
				table.insert(errored.load, {
					identifier = module.metatable.identifier,
					err = err,
				})
			end)
		end
	end

	if things.settings.ModuleLoadAnalysisReport then
		local benchPreloadString = ""
		for _, preloadBench in pairs(bench.preload) do
			benchPreloadString =
				`{benchPreloadString}\n\t[{preloadBench.identifier}]: ({things.smallTimeUnit(preloadBench.bench)})`
		end
		local benchLoadString = ""
		for _, loadBench in pairs(bench.load) do
			benchLoadString = `{benchLoadString}\n\t[{loadBench.identifier}]: ({things.smallTimeUnit(loadBench.bench)})`
		end
		print(
			`[AstraxFramework]: Client Module Analysis Report:\n{string.rep("-", 30)}\nPreload queries: ({#attempts.preload}), Successful preloads: ({#attempts.preload - #errored.preload}), Failed preloads: ({#errored.preload}), Preload benchmarks:{benchPreloadString}\n{string.rep(
				"-",
				30
			)}\nLoad queries: ({#attempts.load}), Successful loads: ({#attempts.load - #errored.load}), Failed loads: ({#errored.load}), Load benchmarks:{benchLoadString}\n{string.rep(
				"-",
				30
			)}`
		)
	end
end

return module
