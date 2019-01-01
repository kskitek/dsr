%% TODO give maxReductionDuration in hours (e.g. night hours have 4h max while day hours have 1h)
%% TODO think about partial reduction in ORED

par set of int: ReductionObjects;
array[ReductionObjects] of par float: ReductionPotential; % [MW]
array[ReductionObjects] of par int: MaxReductionDuration; % [h]

% volume parameters
par float: reduction; % [MW]
par set of int: reductionHours;

% cost parameters
array[ReductionObjects] of par float: ReductionCost; % [zł/MW]
par int: reductionPrice; % [zł/MW]
par float: minProfit; % [%]

%% Reduction volume bounds
par float: minReductionByPSE; % [%]
par float: lowerReductionBoundary = reduction * minReductionByPSE; % [MW]
par float: upperReductionBoundary = reduction * 10; % [MW]

% binary decision - reduction on/off
array[ReductionObjects,reductionHours] of var 0..1: reductionPlan;

% volume constraints
var lowerReductionBoundary..upperReductionBoundary: reductionPlanVolume;
constraint reductionPlanVolume = sum(h in reductionHours, obj in ReductionObjects)
        (reductionPlan[obj, h] * ReductionPotential[obj]);

% reduction hours constraints
constraint forall (obj in ReductionObjects)
        (sum(h in reductionHours) (reductionPlan[obj,h]) <= MaxReductionDuration[obj]);

% costs constraints
var float: reductionCost = sum(h in reductionHours, obj in ReductionObjects)
                          (ReductionCost[obj] * reductionPlan[obj,h] * ReductionPotential[obj]);
var float: reductionProfit = reductionPrice * reduction - reductionCost;

constraint reductionProfit >= reductionPrice * minProfit;

solve maxmize reductionProfit;
% solve satisfy;

output ["Requested reduction volume =\(reduction)MW\n",
        "Requested reduction hours  =\(reductionHours)\n",
        "Planned reduction volume   =\(reductionPlanVolume)MW\n",
        "Planned reduction profit   =\(reductionProfit)zł\n",
        "Planned reduction cost     =\(reductionCost)zł\n"];

output [ "Hours:    "];
output [ formatNumber(h) ++ " " | h in reductionHours];
output [ if h = reductionHours[1]
           then "\nObj[\(formatNumber(obj))]: "
           else "  "
         endif ++ "\(reductionPlan[obj, h])"
         | obj in ReductionObjects, h in reductionHours];

function string: formatNumber(int: number) =
  if number < 10
    then "0\(number)"
    else "\(number)"
  endif;