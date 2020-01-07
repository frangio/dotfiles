# Defined in /tmp/fish.wmbFSw/__nvim.fish @ line 2
function __nvim
	set -l pid (jobs | rg nvim | cut -f2)
	if [ -n "$pid" ]
		fg $pid
	else
		nvim
	end
end
