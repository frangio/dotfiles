# Defined in /tmp/fish.ww5pOt/fish_user_key_bindings.fish @ line 2
function fish_user_key_bindings
	if functions -q fzf_key_bindings
		fzf_key_bindings
	end
	bind \en nvim
        bind \eF forward-bigword
end
