# Defined in /tmp/fish.K57CeD/cdtemp.fish @ line 2
function cdtemp
	set -l tmpdir_base

  if set -q TMPDIR
    set tmpdir_base $TMPDIR
  else
    set tmpdir_base /tmp
  end

  set -l date (date +%F/%R)

  set tmpdir $tmpdir_base/$date

  mkdir -p $tmpdir

  cd (mktemp -p $tmpdir -d XXX)
end
