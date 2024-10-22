$ontext
CEE 6410 - Water Resources Systems Analysis
Problem 3 from Bishop Et Al Text (https://digitalcommons.usu.edu/ecstatic_all/76/)

An irrigated farm can be planted in two crops:  hay and grain  Data are as fol-lows:

                                   Hay                   Grain
Water Availability June         2 acft/acre            1 acft/zcre          14000 acft
Water Availability July         1 acft/acre            2 acft/acre          180000 acft
Water Availability August       1 acft/acre            0 acft/acre          60000 acft
Land Availablity                    1                       1               100000 acre
Profit                           100 $/acre             120 $/acre           

shailendra khanal
s.khanal@usu.edu
$offtext


* 1. DEFINE SETS
SETS 
   m months /June, July, August/
   c crops /hay, grain/;

* 2. DEFINE PARAMETERS
PARAMETERS
   water_req(c,m) 'Water requirement (acre-feet per acre for each crop per month)'
       /hay.June 2, hay.July 1, hay.August 1,
        grain.June 1, grain.July 2, grain.August 0/
   water_avail(m) 'Water available (acre-feet per month)' 
       /June 14000, July 18000, August 6000/
   return_per_acre(c) 'Profit per acre' 
       /hay 100, grain 120/
   max_land 'Maximum land available for irrigation' /10000/;

* 3. DEFINE VARIABLES
VARIABLES
   x(c) 'Acres allocated for each crop'
   Z 'Total profit ($)'
   lambda(m) 'Dual variable for water constraints'
   mu 'Dual variable for land constraint';

POSITIVE VARIABLES x, lambda, mu;

* 4. DEFINE EQUATIONS
EQUATIONS
   profit_eq 'Objective function: maximize total profit'
   water_constraints(m) 'Water availability constraint for each month'
   land_constraint 'Land constraint: max 10,000 acres'
   dual_obj 'Dual objective: minimize cost of resources'
   dual_constraints(c) 'Dual constraints for each crop';

* Objective function: maximize total return
profit_eq.. Z =E= sum(c, return_per_acre(c) * x(c));

* Water availability constraints
water_constraints(m).. sum(c, water_req(c,m) * x(c)) =L= water_avail(m);

* Land constraint
land_constraint.. sum(c, x(c)) =L= max_land;

* Dual objective function: minimize the cost of providing resources
dual_obj.. sum(m, lambda(m) * water_avail(m)) + mu * max_land =G= Z;

* Dual constraints: crop profitability must exceed or equal cost of resources
dual_constraints(c).. sum(m, lambda(m) * water_req(c,m)) + mu =G= return_per_acre(c);

* 5. DEFINE MODELS
MODEL primal_irrigation /profit_eq, water_constraints, land_constraint/;
MODEL dual_irrigation /dual_obj, dual_constraints/;

* 6. SOLVE MODELS
SOLVE primal_irrigation MAXIMIZING Z USING LP;
SOLVE dual_irrigation MINIMIZING Z USING LP;

* 7. DISPLAY RESULTS
DISPLAY x.l, Z.l, lambda.l, mu.l;










