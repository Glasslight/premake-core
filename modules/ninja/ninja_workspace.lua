--- Premake 5 Glasslight Ninja generator.
--- Mykola Konyk, 2021

	local p = premake
	local project = p.project
	local workspace = p.workspace
	local tree = p.tree
	local ninja = p.modules.ninja

	ninja.workspace = {}
	local m = ninja.workspace


	function m.generate(wks)

		p.w("# workspace build file")
		p.w("# generated with premake5 ninja")
		p.w("")
		p.w("ninja_required_version = 1.10")
		p.w("")
		p.w("# build projects")
		p.w("")

		local start_prj = nil
		local targets = {}

		for prj in p.workspace.eachproject(wks) do
			for cfg in project.eachconfig(prj) do

				if cfg.shortname == wks.ninja.current_cfg.shortname then
					p.w("subninja " .. prj.name .. ".ninja")

					if wks.startproject == prj.name then
						start_prj = prj
					end

					targets[prj.name] = cfg.buildtarget.name
				end
			end
		end

		p.w("")
		p.w("# targets")
		p.w("")

		local targets_all = {}

		for n, t in pairs(targets) do
			p.w("build " .. n .. ": phony " .. t)
			table.insert(targets_all, t)
		end

		local next = next
		if next(targets_all) ~= nil then
			p.w("build all: " .. table.concat(targets_all, " "))
		end

		p.w("")
		p.w("# default target")

		if start_prj then
			p.w("default " .. start_prj.name)
		else
			p.w("default all")
		end

		p.w("")
	end

