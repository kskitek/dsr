%:
	mzn2fzn $@.mzn && fzn-gecode -s true $@.fzn

