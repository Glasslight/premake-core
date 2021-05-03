--- Premake 5 Glasslight Ninja generator.
--- Mykola Konyk, 2021

	local p = premake

	p.modules.ninja = {}
	p.modules.ninja._VERSION = p._VERSION

	local ninja = p.modules.ninja
	local project = p.project

	function ninja.esc(value)

		result = value

		result = result:gsub("%$", "$$")
		result = result:gsub(":", "$:")
		result = result:gsub("\n", "$\n")
		result = result:gsub(" ", "$ ")

		return result
	end


	function ninja.generateWorkspace(wks)

		p.eol("\r\n")
		p.indent(" ")
		p.escaper(ninja.esc)

		wks.ninja = {}

		for cfg in p.workspace.eachconfig(wks) do

			wks.ninja.build_file_dir = path.join(wks.location, cfg.shortname)
			wks.ninja.build_file = path.join(wks.ninja.build_file_dir, "build.ninja")
			wks.ninja.rules_file = path.join(wks.ninja.build_file_dir, "rules.ninja")
			wks.ninja.current_cfg = cfg

			p.generate(wks, wks.ninja.build_file, ninja.workspace.generate)
			p.generate(wks, wks.ninja.rules_file, ninja.rules.generate)
		end
	end


	function ninja.generateProject(prj)

		p.eol("\r\n")
		p.indent(" ")
		p.escaper(ninja.esc)

		prj.ninja = {}
		prj.ninja.all_project_build_files = {}

		for cfg in p.project.eachconfig(prj) do

			prj.ninja.build_file_dir = path.join(prj.location, cfg.shortname)
			prj.ninja.build_file = path.join(prj.ninja.build_file_dir, prj.name .. ".ninja")
			table.insert(prj.ninja.all_project_build_files, prj.ninja.build_file)
			prj.ninja.current_cfg = cfg

			p.generate(prj, prj.ninja.build_file, ninja.project.generate)
		end
	end


	function ninja.cleanWorkspace(wks)
		p.clean.file(wks, wks.ninja.build_file)
	end


	function ninja.cleanProject(prj)
		for _, v in ipairs(prj.ninja.all_project_build_files) do
			p.clean.file(prj, v)
		end
	end


	function ninja.cleanTarget(prj)

	end


	include("ninja_workspace.lua")
	include("ninja_project.lua")
	include("ninja_rules.lua")
	include("ninja_common.lua")

	return ninja
