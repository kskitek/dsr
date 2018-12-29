int: reduction = 14;
set of int: reductionHours = {1,2};

set of int: HOUR = 0..5;

int: objectPotential = 5;

array[HOUR] of var 0..1: id1;
array[HOUR] of var 0..1: id2;
array[HOUR] of var 0..1: id3;

var int: red;
constraint red = sum(h in reductionHours)
           (id1[h]*objectPotential + id2[h]*objectPotential + id3[h]*objectPotential);
constraint reduction * 0.8 <= red;
constraint red <= reduction * 1.2;

solve maximize red;