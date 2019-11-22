function __fish_paginate --description 'Paginate the current command using the users default pager'
	set -l cursor (commandline -C)
	if commandline -p | string match -q -r -v "^\s*page"
          commandline -pr (commandline -p | string replace -r '^(\s*)' '$1page ')
          commandline -C (math $cursor+5)
        else
          commandline -pr (commandline -p | string replace -r '^(\s*)page ' '$1')
          set -l new_cursor (math $cursor-5)
          if [ $new_cursor -gt 0 ]
            commandline -C $new_cursor
          else 
            commandline -C 0
          end
        end
end
