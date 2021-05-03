--- Premake 5 Glasslight Ninja generator.
--- Mykola Konyk, 2021

	local p = premake
	local project = p.project
	local config = p.config
	local ninja = p.modules.ninja

	ninja.project = {}
	local m = ninja.project


	-- Write out a build option.
	function m.write_build_option(option_name, options)
		if options ~= nil and #options > 0 then
			p.w("  " .. option_name .. " = $")

			for _, opt in ipairs(options) do
				if next(options, _) == nil then
					p.w("    " .. opt)
				else
					p.w("    " .. opt .. " $")
				end
			end
		else
			p.w("  " .. option_name .. " = ")
		end
	end


	function m.write_build_rule(prj, cfg, rule)
		local build_file_dir = prj.ninja.build_file_dir
		local object_files = prj.ninja.object_files
		local target = path.getrelative(build_file_dir, path.join(cfg.buildtarget.directory, cfg.buildtarget.name))

		if object_files ~= nil and #object_files > 0 then
			p.w("build " .. target .. ": " .. rule .. " || $")

			for _, obj_file in ipairs(object_files) do
				if next(object_files, _) == nil then
					p.w("  " .. obj_file)
				else
					p.w("  " .. obj_file .. " $")
				end
			end
		else
			p.w("build " .. target .. ": " .. rule)
		end
	end


	-- Generate a response file.
	function m.generate_response(prj)
		for _, obj_file in ipairs(prj.ninja.object_files) do
			p.w(obj_file)
		end

		p.w(" ")
	end


	-- Retrieve dependent libs.
	function m.get_dep_libs(cfg, s1, s2)

		local location = cfg.project.location
		local deps = config.getlinks(cfg, s1, s2)
		local deps_new = {}

		for _, dep in ipairs(deps) do
			local dep_path = path.join(location, dep)
			table.insert(deps_new, dep_path)
		end

		return deps_new
	end


	-- Generate a project file.
	function m.generate(prj)

		local cfg = prj.ninja.current_cfg
		local toolset = ninja.get_toolset(cfg)
		local build_file_dir = prj.ninja.build_file_dir

		p.w("# project build file")
		p.w("# generated with premake5 ninja")
		p.w("")
		p.w("ninja_required_version = 1.10")
		p.w("include rules.ninja")
		p.w("")
		p.w("# build rules")
		p.w("")

		local object_files = {}

		for _, file in ipairs(cfg.files) do

			file = path.getrelative(build_file_dir, file)
			local object_file = path.getrelative(build_file_dir, path.join(cfg.objdir, ninja.remove_relative_dots(path.replaceextension(file, "o"))))

			if path.iscfile(file) then
				local cflags = ninja.to_list(ninja.get_cflags(cfg))
				local includes = ninja.to_list(ninja.get_includes(cfg, true))
				local defines = ninja.to_list(ninja.get_defines(cfg))

				table.insert(object_files, object_file)

				p.w("# Source c file: " .. file)
				p.w("build " .. object_file .. ": cc " .. file .. " ||")
				p.w("  flags    = " .. cflags)
				p.w("  includes = " .. includes)
				p.w("  defines  = " .. defines)
				p.w("")
			elseif path.iscppfile(file) then
				local cxxflags = ninja.to_list(ninja.get_cxxflags(cfg))
				local includes = ninja.to_list(ninja.get_includes(cfg, true))
				local defines = ninja.to_list(ninja.get_defines(cfg))

				table.insert(object_files, object_file)

				p.w("# Source cxx file: " .. file)
				p.w("build " .. object_file .. ": cxx " .. file .. " ||")
				p.w("  flags    = " .. cxxflags)
				p.w("  includes = " .. includes)
				p.w("  defines  = " .. defines)
				p.w("")
			elseif path.iscppheader(file) then
				p.w("# Source header file: " .. file)
				p.w("")
			end
		end

		prj.ninja.object_files = object_files

		local rule = ""

		if cfg.kind == p.CONSOLEAPP then
			p.w("# Console application: " .. cfg.buildtarget.name)

			if cfg.language == p.C then
				rule = "link_cc"
			elseif cfg.language == p.CPP then
				rule = "link_cxx"
			end
		elseif cfg.kind == p.SHAREDLIB then
			p.w("# Shared library: " .. cfg.buildtarget.name)

			if cfg.language == p.C then
				rule = "link_cc"
			elseif cfg.language == p.CPP then
				rule = "link_cxx"
			end
		elseif cfg.kind == p.STATICLIB then
			p.w("# Static library: " .. cfg.buildtarget.name)
			rule = "ar"
		else
			p.error("Unsupported target kind")
		end

		if rule == "" then
			p.error("Unsupported target type")
		end

		m.write_build_rule(prj, cfg, rule)

		do
			local responsefile = path.replaceextension(path.join(build_file_dir, cfg.buildtarget.name), ".response")
			p.generate(prj, responsefile, m.generate_response)

			p.w("  responsefile = " .. responsefile)
		end

		m.write_build_option("pre_link", {})
		m.write_build_option("dep_libs", m.get_dep_libs(cfg, "siblings", "fullpath"))
		m.write_build_option("sys_libs", config.getlinks(cfg, "system", "fullpath"))
		m.write_build_option("link_options", table.join(cfg.linkoptions, table.join(toolset.getldflags(cfg), ninja.get_library_paths(cfg, true))))

		p.w("")
	end
