function cdtemp
	set -l tmpdir_base

  if set -q TMPDIR
    set tmpdir_base $TMPDIR
  else
    set tmpdir_base /tmp
  end

  set -l date (date +%F)

  set tmpdir $tmpdir_base/$date

  mkdir -p $tmpdir

  cd (mktemp -p $tmpdir -d (date +%Hh-%Mm)-XXX)
end
