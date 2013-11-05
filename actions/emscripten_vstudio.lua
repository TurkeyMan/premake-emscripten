--
-- vstudio.lua
-- Emscripten integration for vstudio.
-- Copyright (c) 2012 Manu Evans and the Premake project
--

	local emscripten = premake.extensions.emscripten
	local sln2005 = premake.vstudio.sln2005
	local vc2010 = premake.vstudio.vc2010
	local vstudio = premake.vstudio
	local project = premake.project
	local config = premake.config


--
-- Add Emscripten tools to vstudio actions.
--

	if vstudio.vs2010_architectures ~= nil then
		vstudio.vs2010_architectures.emscripten = "Emscripten"
	end

--
-- Extend configurationProperties.
--

	premake.override(vc2010, "platformToolset", function(orig, cfg)
		if cfg.system == premake.EMSCRIPTEN then
			-- is there a reason to write this? default is fine.
--			_p(2,'<PlatformToolset>emcc</PlatformToolset>')
		else
			orig(cfg)
		end
	end)

	premake.override(vc2010, "configurationType", function(oldfn, cfg)
		if cfg.system == premake.EMSCRIPTEN then
			if cfg.kind then
				local types = {
					StaticLib = "StaticLibrary",
					ConsoleApp = "Application",
					WindowedApp = "Application",
					HTMLPage = "HTMLPage"
				}
				if not types[cfg.kind] then
					error("Invalid 'kind' for Emscripten: " .. cfg.kind, 2)
				else
					_p(2,'<ConfigurationType>%s</ConfigurationType>', types[cfg.kind])
				end
			end
		else
			oldfn(cfg)
		end
	end)


--
-- Extend outputProperties.
--

	table.insert(vc2010.elements.outputProperties, "emscriptenClangPath")
	table.insert(vc2010.elements.outputProperties, "emscriptenEmccPath")

	function vc2010.emscriptenClangPath(cfg)
		if cfg.system == premake.EMSCRIPTEN then
			if cfg.clangpath ~= nil then
--				local dirs = project.getrelative(cfg.project, includedirs)
--				dirs = path.translate(table.concat(fatalwarnings, ";"))
				_p(2,'<ClangPath>%s</ClangPath>', cfg.clangpath)
			end
		end
	end

	function vc2010.emscriptenEmccPath(cfg)
		if cfg.system == premake.EMSCRIPTEN then
			if cfg.emccpath ~= nil then
--				local dirs = project.getrelative(cfg.project, includedirs)
--				dirs = path.translate(table.concat(fatalwarnings, ";"))
				_p(2,'<EmccPath>%s</EmccPath>', cfg.emccpath)
			end
		end
	end

	premake.override(vc2010, "targetExt", function(oldfn, cfg)
		if cfg.system == premake.EMSCRIPTEN then
			local ext = cfg.buildtarget.extension
			if ext ~= "" then
				_x(2,'<TargetExt>%s</TargetExt>', ext)
			end
		else
			oldfn(cfg)
		end
	end)


--
-- Extend clCompile.
--

	table.insert(vc2010.elements.clCompile, "emscriptenDebugInformation")
	table.insert(vc2010.elements.clCompile, "emscriptenEnableWarnings")
	table.insert(vc2010.elements.clCompile, "emscriptenDisableWarnings")
	table.insert(vc2010.elements.clCompile, "emscriptenSpecificWarningsAsErrors")
	table.insert(vc2010.elements.clCompile, "emscriptenPreprocessorUndefinitions")
	table.insert(vc2010.elements.clCompile, "emscriptenLanguageStandard")

	function vc2010.emscriptenDebugInformation(cfg)
		if cfg.system == premake.EMSCRIPTEN then
			if cfg.flags.Symbols then
				_p(3,'<GenerateDebugInformation>true</GenerateDebugInformation>')
			end
		end
	end

	function vc2010.emscriptenEnableWarnings(cfg)
		if cfg.system == premake.EMSCRIPTEN then
			if #cfg.enablewarnings > 0 then
				_x(3,'<EnableWarnings>%s</EnableWarnings>', table.concat(cfg.enablewarnings, ";"))
			end
		end
	end

	function vc2010.emscriptenDisableWarnings(cfg)
		if cfg.system == premake.EMSCRIPTEN then
			if #cfg.disablewarnings > 0 then
				_x(3,'<DisableWarnings>%s</DisableWarnings>', table.concat(cfg.disablewarnings, ";"))
			end
		end
	end

	function vc2010.emscriptenSpecificWarningsAsErrors(cfg)
		if cfg.system == premake.EMSCRIPTEN then
			if #cfg.fatalwarnings > 0 then
				_x(3,'<SpecificWarningsAsErrors>%s</SpecificWarningsAsErrors>', table.concat(cfg.fatalwarnings, ";"))
			end
		end
	end

	function vc2010.emscriptenPreprocessorUndefinitions(cfg)
		if cfg.system == premake.EMSCRIPTEN then
			if #cfg.undefines > 0 then
				_x(3,'<PreprocessorUndefinitions>%s</PreprocessorUndefinitions>', table.concat(cfg.undefines, ";"))
			end
		end
	end

	function vc2010.emscriptenLanguageStandard(cfg)
		if cfg.system == premake.EMSCRIPTEN then
			local map = {
				c90         = "LanguageStandardC89",
				gnu90       = "LanguageStandardGnu89",
				c94         = "LanguageStandardC94",
				c99         = "LanguageStandardC99",
				gnu99       = "LanguageStandardGnu99",
				["c++98"]   = "LanguageStandardCxx03",
				["gnu++98"] = "LanguageStandardGnu++98",
				["c++11"]   = "LanguageStandardC++11",
				["gnu++11"] = "LanguageStandardGnu++11"
			}
			if cfg.languagestandard and map[cfg.languagestandard] then
				_p(3,'<LanguageStandardMode>%s</LanguageStandardMode>', map[cfg.languagestandard])
			end
		end
	end

	premake.override(vc2010, "warningLevel", function(oldfn, cfg)
		if cfg.system == premake.EMSCRIPTEN then
			local map = { Off = "DisableAllWarnings", Extra = "AllWarnings" }
			if map[cfg.warnings] ~= nil then
				_p(3,'<Warnings>%s</Warnings>', map[cfg.warnings])
			end
		else
			oldfn(cfg)
		end
	end)

	premake.override(vc2010, "treatWarningAsError", function(oldfn, cfg)
		if cfg.system == premake.EMSCRIPTEN then
			if cfg.flags.FatalWarnings and cfg.warnings ~= "Off" then
				_p(3,'<WarningsAsErrors>true</WarningsAsErrors>')
			end
		else
			oldfn(cfg)
		end
	end)

	premake.override(vc2010, "optimization", function(oldfn, cfg, condition)
		local config = cfg.config or cfg
		if config.system == premake.EMSCRIPTEN then
			local map = { Off="O0", On="O2", Debug="O0", Full="O3", Size="Os", Speed="O3" }
			local value = map[cfg.optimize]
			if value or not condition then
				value = value or "O0"
				if cfg.flags.LinkTimeOptimization and value ~= "O0" then
					value = "O4"
				end
				vc2010.element(3, 'OptimizationLevel', condition, value)
			end
		else
			oldfn(cfg, condition)
		end
	end)

	premake.override(vc2010, "exceptionHandling", function(oldfn, cfg)
		-- ignored for Emscripten
		if cfg.system ~= premake.EMSCRIPTEN then
			oldfn(cfg)
		end
	end)

	premake.override(vc2010, "additionalCompileOptions", function(oldfn, cfg, condition)
		local config = cfg.config or cfg
		if config.system == premake.EMSCRIPTEN then
			emscripten.additionalOptions(cfg)
		end
		return oldfn(cfg, condition)
	end)


--
-- Extend Link.
--

	-- TODO: link needs to be extendable...

--      <SubSystem>Console</SubSystem>
--      <EntryPointSymbol>mainCRTStartup</EntryPointSymbol>
--      <OutputFile>$(OutDir)$(TargetName)$(TargetExt)</OutputFile>
--      <AdditionalLibraryDirectories>libDir;lib2</AdditionalLibraryDirectories>
--      <LinkerOptimizationLevel>O2</LinkerOptimizationLevel>
--      <TypedArrays>SharedTypedArrays</TypedArrays>
--      <RunClosureCompiler>true</RunClosureCompiler>
--      <RunMinify>true</RunMinify>
--      <IgnoreDynamicLinking>true</IgnoreDynamicLinking>
--      <PreJsFile>prejs;prejs2;%(PreJsFile)</PreJsFile>
--      <PostJsFile>postjs;postjs2;%(PostJsFile)</PostJsFile>
--      <EmbedFile>embedRes;embed2;%(EmbedFile)</EmbedFile>
--      <PreloadFile>preloadRes;preload2;%(PreloadFile)</PreloadFile>
--      <HtmlShellFile>htmlShell;html2;%(HtmlShellFile)</HtmlShellFile>
--      <JsLibrary>jsLib;jsLib2;%(JsLibrary)</JsLibrary>
--      <AdditionalDependencies>additionalDep;dep2;%(AdditionalDependencies)</AdditionalDependencies>
--      <AdditionalOptions>link commands %(AdditionalOptions)</AdditionalOptions>

	premake.override(vc2010, "generateDebugInformation", function(oldfn, cfg)
		-- Note: Emscripten specifies the debug info in the clCompile section
		if cfg.system ~= premake.EMSCRIPTEN then
			oldfn(cfg)
		end
	end)


--
-- Add options unsupported by Emscripten vs-tool UI to <AdvancedOptions>.
--
	function emscripten.additionalOptions(cfg)

		local function alreadyHas(t, key)
			for _, k in ipairs(t) do
				if string.find(k, key) then
					return true
				end
			end
			return false
		end

--		Eg: table.insert(cfg.buildoptions, "-option")

	end
