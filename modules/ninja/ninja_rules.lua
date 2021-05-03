--- Premake 5 Glasslight Ninja generator.
--- Mykola Konyk, 2021

	local p = premake
	local tree = p.tree
	local ninja = p.modules.ninja

	ninja.rules = {}
	local m = ninja.rules


	function m.build_command_cc_cxx(toolset, cfg, exe)

		local result = ""

		if toolset.getname() == "msc" then
			result = "$out.d /showIncludes -c $in /Fo$out"
		else
			result = "-MMD -MF $out.d -c -o $out $in"
		end

		return ninja.wrap_cmd(exe .. " $defines $includes $flags " .. result)
	end


	function m.rule_cc_cxx_deps(toolset, cfg)

		if toolset.getname() == "msc" then
			return "msvc"
		else
			return "gcc"
		end
	end


	function m.build_command_ar(toolset, cfg)

		local result = ""

		if toolset.getname() == "msc" then
			result = "$in @$responsefile /nologo -OUT:$out"
		else
			result = "rcs $out $in @$responsefile"
		end

		return ninja.wrap_cmd(ninja.get_executable_ar(cfg) .. " " .. result)
	end


	function m.build_command_link(toolset, cfg)

		local result = ""

		if toolset.getname() == "msc" then
			result = "$in $dep_libs $sys_libs @$responsefile $link_options /out:$out"
		else
			result = "-o $out $in $ @$responsefile"
		end

		return ninja.wrap_cmd("$pre_link " .. ninja.get_executable_link(cfg) .. " " .. result)
	end


	function m.generate(wks)

		local cfg = wks.ninja.current_cfg
		local toolset = ninja.get_toolset(cfg)

		p.w("# rules file")
		p.w("# generated with premake5 ninja")
		p.w("")
		p.w("ninja_required_version = 1.10")
		p.w("")

		p.w("# rules for " .. cfg.name .. " configuration")
		p.w("")

		-- Generate a cc rule.
		do
			p.w("rule cc")
			p.w("  command     = " .. m.build_command_cc_cxx(toolset, cfg, ninja.get_executable_cc(cfg)))
			p.w("  description = Building c object $out")
			p.w("  depfile     = $out.d")
			p.w("  deps        = " .. m.rule_cc_cxx_deps(toolset, cfg))
			p.w("")
		end

		-- Generate a cxx rule.
		do
			p.w("rule cxx")
			p.w("  command     = " .. m.build_command_cc_cxx(toolset, cfg, ninja.get_executable_cxx(cfg)))
			p.w("  description = Building cxx object $out")
			p.w("  depfile     = $out.d")
			p.w("  deps        = " .. m.rule_cc_cxx_deps(toolset, cfg))
			p.w("")
		end

		-- Generate an ar rule.
		do
			p.w("rule ar")
			p.w("  command     = " .. m.build_command_ar(toolset, cfg))
			p.w("  description = Building an archive $out")
			p.w("")
		end

		-- Generate a link cc rule.
		do
			p.w("rule link_cc")
			p.w("  command     = " .. m.build_command_link(toolset, cfg))
			p.w("  description = Linking a cc executable $out")
			p.w("")

		end

		-- Generate a link cxx rule.
		do
			p.w("rule link_cxx")
			p.w("  command     = " .. m.build_command_link(toolset, cfg))
			p.w("  description = Linking a cxx executable $out")
			p.w("")
		end

	end

