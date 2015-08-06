
--
-- Create an emscripten namespace to isolate the additions
--

	local p = premake

	p.modules.emscripten = {}

	local m = p.modules.emscripten
	m._VERSION = "0.0.1"


	require "vstool"


	include("emscripten_emcc.lua")


	premake.override(premake.modules.vstool, "isclang", function(oldfn, cfg)
		return cfg.toolset == "emcc" or oldfn(cfg)
	end)

	premake.override(premake.modules.vstool, "isvstool", function(oldfn, cfg)
		return not (cfg.system == "emscripten" or cfg.toolset == "emcc") and oldfn(cfg)
	end)


	include("emscripten_vstudio.lua")

	return m
