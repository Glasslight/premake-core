--- Premake 5 Glasslight Ninja generator.
--- Mykola Konyk, 2021

	local p = premake
	local tree = p.tree
	local project = p.project
	local config = p.config
	local ninja = p.modules.ninja


	-- Wrap a given command.
	function ninja.wrap_cmd(command)
		if os.ishost("windows") then
			--return "cmd /c \"" .. command .. "\""
			return command
		else
			return command
		end
	end


	-- Flatten a given table into a string.
	function ninja.to_list(t)
		if t ~= nil and #t > 0 then
			return table.concat(t, " ")
		else
			return ""
		end
	end


	-- Remove leading relative path dots.
	function ninja.remove_relative_dots(file_path)
		while true do
			if string.startswith(file_path, "./") then
				file_path = string.sub(file_path, 3)
			elseif string.startswith(file_path, "../") then
				file_path = string.sub(file_path, 4)
			else
				break
			end
		end

		return file_path
	end


	-- Given a config, return a corresponding toolset.
	function ninja.get_toolset(cfg)

		local toolset_name = _OPTIONS.cc or cfg.toolset

		if toolset_name == nil then
			p.error("Missing a toolchain name")
		end

		local toolset = p.tools[toolset_name]

		if toolset == nil then
			p.error("Missing a toolchain")
		end

		return toolset
	end


	-- Retrieve cc compiler executable.
	function ninja.get_executable_cc(cfg)
		local toolset = ninja.get_toolset(cfg)
		local tool = toolset.gettoolname(cfg, "cc")

		if tool == nil then
			p.error("Missing a c compiler binary")
		end

		return tool
	end


	-- Retrieve cxx compiler executable.
	function ninja.get_executable_cxx(cfg)
		local toolset = ninja.get_toolset(cfg)
		local tool = toolset.gettoolname(cfg, "cxx")

		if tool == nil then
			p.error("Missing a cxx compiler binary")
		end

		return tool
	end


	-- Retrieve ar static linker executable.
	function ninja.get_executable_ar(cfg)
		local toolset = ninja.get_toolset(cfg)
		local tool = toolset.gettoolname(cfg, "ar")

		if tool == nil then
			p.error("Missing a static linker binary")
		end

		return tool
	end


	-- Retrieve a linker executable.
	function ninja.get_executable_link(cfg)
		local toolset = ninja.get_toolset(cfg)
		local tool = toolset.gettoolname(cfg, "link")

		if tool == nil then
			p.error("Missing a linker binary")
		end

		return tool
	end


	-- Retrieve defines for a given config.
	function ninja.get_defines(cfg)
		local toolset = ninja.get_toolset(cfg)
		return table.join(toolset.getdefines(cfg.defines, cfg), toolset.getundefines(cfg.undefines))
	end


	-- Retrieve force includes for a given config.
	function ninja.get_forceincludes(cfg)
		local toolset = ninja.get_toolset(cfg)
		return toolset.getforceincludes(cfg)
	end


	-- Retrieve includes for a given config.
	function ninja.get_includes(cfg, make_fullpath)
		local toolset = ninja.get_toolset(cfg)

		if make_fullpath then
			local location = cfg.location
			local dirs = table.join(cfg.includedirs, cfg.sysincludedirs)
			local dirs_new = {}

			for _, dir in ipairs(dirs) do
				if path.isabsolute(dir) then
					table.insert(dirs_new, "-I \"" .. dir .. "\"")
				else
					table.insert(dirs_new, "-I \"" .. path.getabsolute(path.join(location, dir)) .. "\"")
				end
			end

			return dirs_new
		else
			return toolset.getincludedirs(cfg, cfg.includedirs, cfg.sysincludedirs)
		end
	end


	-- Retrieve library directories.
	function ninja.get_library_paths(cfg, make_fullpath)
		local toolset = ninja.get_toolset(cfg)

		if make_fullpath then
			local location = cfg.location

			if toolset.getname() == "msc" then
				local library_dirs = table.join(cfg.libdirs, cfg.syslibdirs)
				local library_dirs_new = {}

				for _, dir in ipairs(library_dirs) do
					if path.isabsolute(dir) then
						table.insert(library_dirs_new, "/LIBPATH:\"" .. dir .. "\"")
					else
						table.insert(library_dirs_new, "/LIBPATH:\"" .. path.getabsolute(path.join(location, dir)) .. "\"")
					end
				end

				return library_dirs_new
			else
				local library_dirs = table.join(config.getlinks(cfg, "system", "directory"), cfg.syslibdirs)
				local library_dirs_new = {}

				for _, dir in ipairs(library_dirs) do
					if path.isabsolute(dir) then
						table.insert(library_dirs_new, "-L \"" .. dir .. "\"")
					else
						table.insert(library_dirs_new, "-L \"" .. path.getabsolute(path.join(location, dir)) .. "\"")
					end
				end

				return library_dirs_new
			end
		else
			return toolset.getLibraryDirectories(cfg)
		end
	end


	-- Retrieve c flags for a given config.
	function ninja.get_cflags(cfg)
		local toolset = ninja.get_toolset(cfg)
		return table.join(toolset.getcflags(cfg), cfg.buildoptions)
	end


	-- Retrieve cxx flags for a given config.
	function ninja.get_cxxflags(cfg)
		local toolset = ninja.get_toolset(cfg)
		return table.join(toolset.getcxxflags(cfg), cfg.buildoptions)
	end
