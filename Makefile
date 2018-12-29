dsr:
	minizinc --statistics --no-output-ozn --output-objective --output-time \
	  --time-limit 60000 --solver Gecode dsr.mzn -d dsr.dzn

check:
	minizinc --solver Gecode -e dsr.mzn