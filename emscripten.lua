
--
-- Create an emscripten namespace to isolate the additions
--
	premake.extensions.emscripten = {}

	local emscripten = premake.extensions.emscripten
	local vstudio = premake.vstudio
	local project = premake.project
	local api = premake.api

	emscripten.support_url = "https://bitbucket.org/premakeext/emscripten/wiki/Home"

	emscripten.printf = function( msg, ... )
		printf( "[emscripten] " .. msg, ...)
	end

	emscripten.printf( "Premake Emscripten Extension (" .. emscripten.support_url .. ")" )

	-- Extend the package path to include the directory containing this
	-- script so we can easily 'require' additional resources from
	-- subdirectories as necessary
	local this_dir = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]];
	package.path = this_dir .. "actions/?.lua;".. package.path


--
-- Register the Emscripten extension
--

	premake.EMSCRIPTEN = "emscripten"

	api.addAllowed("system", { premake.EMSCRIPTEN })
	api.addAllowed("kind", "HTMLPage")
	api.addAllowed("flags", {
		"NoClosureCompiler",
		"NoMinifyJavaScript",
		"IgnoreDynamicLinking",
	})


--
-- Register Emscripten properties
--

	api.register {
		name = "clangpath",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "emccpath",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "languagestandard",
		scope = "config",
		kind = "string",
		allowed = {
			"c90",
			"gnu90",
			"c94",
			"c99",
			"gnu99",
			"c++98",
			"gnu++98",
			"c++11",
			"gnu++11",
			"c++1y",
		},
	}

	api.register {
		name = "enablewarnings",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "disablewarnings",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "fatalwarnings",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "undefines",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "linkeroptimize",
		scope = "config",
		kind = "string",
		allowed = {
			"Off",
			"Simple",
			"On",
			"Unsafe",
		}
	}

	api.register {
		name = "typedarrays",
		scope = "config",
		kind = "string",
		allowed = {
			"None",
			"Parallel",
			"Shared",
		}
	}

--      <PreJsFile>prejs;prejs2;%(PreJsFile)</PreJsFile>
--      <PostJsFile>postjs;postjs2;%(PostJsFile)</PostJsFile>
--      <EmbedFile>embedRes;embed2;%(EmbedFile)</EmbedFile>
--      <PreloadFile>preloadRes;preload2;%(PreloadFile)</PreloadFile>
--      <HtmlShellFile>htmlShell;html2;%(HtmlShellFile)</HtmlShellFile>
--      <JsLibrary>jsLib;jsLib2;%(JsLibrary)</JsLibrary>


--
-- 'require' the vs-tool code.
--

	require( "emscripten_vstudio" )
	emscripten.printf( "Loaded vs-tool support 'emscripten_vstudio.lua'", v )
