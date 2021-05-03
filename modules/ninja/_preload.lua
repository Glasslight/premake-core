--- Premake 5 Glasslight Ninja generator.
--- Mykola Konyk, 2021

	local p = premake

	newaction
	{
		-- Metadata for the command line and help system

		trigger         = "ninja",
		shortname       = "ninja",
		description     = "Generate ninja project files",
		toolset         = "clang",

		-- The capabilities of this action

		valid_kinds     = { "ConsoleApp", "WindowedApp", "Makefile", "SharedLib", "StaticLib", "Utility" },
		valid_languages = { "C", "C++" },
		valid_tools     = {
			cc = { "clang", "msc" }
		},

		-- Workspace and project generation logic

		onWorkspace = function(wks)
			p.modules.ninja.generateWorkspace(wks)
		end,

		onProject = function(prj)
			p.modules.ninja.generateProject(prj)
		end,

		onCleanWorkspace = function(wks)
			p.modules.ninja.cleanWorkspace(wks)
		end,

		onCleanProject = function(prj)
			p.modules.ninja.cleanProject(prj)
		end,

		onCleanTarget = function(prj)
			p.modules.ninja.cleanTarget(prj)
		end,
	}


--
-- Decide when the full module should be loaded.
--

	return function(cfg)
		return (_ACTION == "ninja")
	end
