
--
-- Create an emscripten namespace to isolate the additions
--
	premake.modules.emscripten = {}

	local emscripten = premake.modules.emscripten

	include("_preload.lua")
	include("emscripten_emcc.lua")


	configuration { "Emscripten" }
		system "emscripten"
		toolset "emcc"


	premake.override(premake.modules.vstool, "isclang", function(oldfn, cfg)
		return cfg.toolset == "emcc" or oldfn(cfg)
	end)


	include("emscripten_vstudio.lua")

	return emscripten
