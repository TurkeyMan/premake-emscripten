
--
-- Create an emscripten namespace to isolate the additions
--
	premake.modules.emscripten = {}

	local emscripten = premake.modules.emscripten

	include("_preload.lua")


	configuration { "Emscripten" }
		system "emscripten"
		toolset "clang"


	include("emscripten_emcc.lua")
	include("emscripten_vstudio.lua")

	return emscripten
