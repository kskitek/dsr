%% TODO take into account maxReductionTime specified per object
%% TODO think about partial reduction in ORED

par set of int: ReductionObjects;
par float: unitReductionPotential;  % [MW] per ReductionObject
array[ReductionObjects] of par float: ReductionPotential;

% volume parameters
par float: reduction; % [MW]
par set of int: reductionHours;

% cost parameters
par int: unitReductionCost; % [zł/MW]
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

% costs constraints
var float: reductionCost = reductionPlanVolume * unitReductionCost;
var float: reductionProfit = reductionPrice - reductionCost;

constraint reductionProfit >= reductionPrice * minProfit;

solve maximize reductionProfit;

output ["Requested reduction volume=\(reduction)MW\n",
        "Requested reduction hours=\(reductionHours)\n",
        "Planned reduction volume=\(reductionPlanVolume)MW\n",
        "Planned reduction profit=\(reductionProfit)zł\n",
        "Planned reduction cost=\(reductionCost)zł\n"];

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