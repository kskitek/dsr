%:
	minizinc --statistics --no-output-ozn --output-objective --output-time \
	  --time-limit 60000 --solver Gecode $@.mzn
