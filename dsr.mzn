%% TODO take into account maxReductionTime specified per object
%% TODO think about partial reduction in ORED

par set of int: ReductionObjects = 1..20;  % lets say we have that many OREDs
par float: unitReductionPotential = 0.2; % [MW] per ReductionObject
array[ReductionObjects] of par float: ReductionPotential = [unitReductionPotential | obj in ReductionObjects];

% volume parameters
par float: reduction = 2; % [MW]
par set of int: reductionHours = {2};

%% Reduction volume bounds
par float: minReductionByPSE = 0.9; % [%]
%% reduction bounded "only" by cost - use when maximizing profit
par float: lowerReductionBoundary = reduction * minReductionByPSE; % [MW]
par float: upperReductionBoundary = reduction * 10; % [MW]

% cost parameters
par int: unitReductionCost = 100; % [zł/MW]
par int: reductionPrice = 13000; % [zł/MW]
par float: minProfit = 0.25; % [%]

set of int: HOUR = 0..23;
array[ReductionObjects,reductionHours] of var 0..1: reductionPlan; % binary decision - reduction on/off

% volume constraints
var lowerReductionBoundary..upperReductionBoundary: reductionPlanVolume =
    sum(h in reductionHours, obj in ReductionObjects)
        (reductionPlan[obj, h] * ReductionPotential[obj]);

constraint reductionPlanVolume >= lowerReductionBoundary;
constraint reductionPlanVolume <= upperReductionBoundary;

% costs constraints
var float: reductionCost = reductionPlanVolume * unitReductionCost;
var float: reductionProfit = reductionPrice - reductionCost;

constraint reductionProfit >= reductionPrice * minProfit;

%% when changing maximization variable change also volume bounds
solve maximize reductionProfit;

output ["Requested reduction volume=\(reduction)MW\n",
        "Requested reduction hours=\(reductionHours)\n",
        "Planned reduction volume=\(reductionPlanVolume)MW\n",
        "Planned reduction profit=\(reductionProfit)zł\n",
        "Planned reduction cost=\(reductionCost)zł\n"];

output [ "Hours:    "];
output [ formatNumber(h) ++ " " | h in reductionHours];
output [ if h = reductionHours[1] then "\nObj[\(formatNumber(obj))]: " else "  " endif ++ "\(reductionPlan[obj, h])" | obj in ReductionObjects, h in reductionHours];

function string: formatNumber(int: number) =
  if number < 10
    then "0\(number)"
    else "\(number)"
  endif;