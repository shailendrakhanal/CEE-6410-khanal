$ontext
Irrigation problem with reservoir and pump options 

shailedra khanal    
s.khanalusu.edu
$offtext

* Sets and Parameters
SET t /1*2/; 

* Parameters
SCALARS
    revenue_per_acre " Revenue per acre" /300/ 
    high_dam_cost "Annual cost of high dam"  /10000/       
    low_dam_cost "Annual cost of low dam" /6000/        
    pump_capital_cost  "Pump installation cost"   /8000/    
    pump_operating_cost   "Operating cost per acre-foot for pump"   /20/   
    high_dam_capacity  "Capacity of high dam in acre-feet"  /700/   
    low_dam_capacity  "Capacity of low dam in acre-feet"    /300/      
    pump_capacity_per_day  "Pump capacity per day in acre-feet"   /2.2/ 
    days_in_season  "Days in a 6-month season"  /180/;       

PARAMETER
    river_inflow(t)"Seasonal river inflows" /1 600, 2 200/      
    irrigation_demand(t)   "Irrigation demand per acre in each season"    /1 1.0, 2 3.0/; 

* Variables
BINARY VARIABLES
* Binary variables for high dam, low dam, and pump
    I_H, I_L, I_P;  

POSITIVE VARIABLES
* Water released from reservoir for direct irrigation
    R_irrigation(t)
* Water released into groundwater
    R_groundwater(t)
* Water pumped from groundwater
    P(t)
* Total acres irrigated
    A           ;    

FREE VARIABLE
*Objective function
 Z;   

* Objective Function
EQUATION obj;
obj.. Z =E= revenue_per_acre * A
          - (high_dam_cost * I_H + low_dam_cost * I_L + pump_capital_cost * I_P)
          - pump_operating_cost * SUM(t, P(t));

* Constraints
EQUATIONS
    demand_constraint(t)          * Water demand constraint for each season
    reservoir_capacity_constraint(t)  * Reservoir capacity constraint
    groundwater_flow_constraint(t)    * Effective groundwater flow available for pumping
    pump_capacity_constraint(t)       * Pump capacity per season
    reservoir_selection_constraint    * Only one reservoir can be selected
    water_balance_constraint(t)      * Reservoir inflow equals releases ;

* Demand Constraints
demand_constraint(t).. R_irrigation(t) + P(t) =G= irrigation_demand(t) * A;

* Reservoir Capacity Constraints
reservoir_capacity_constraint(t).. R_irrigation(t) + R_groundwater(t) =L= high_dam_capacity * I_H + low_dam_capacity * I_L;

* Groundwater Flow Augmentation
groundwater_flow_constraint(t).. P(t) =L= R_groundwater(t) + 360;

* Pump Capacity Constraints
pump_capacity_constraint(t).. P(t) =L= pump_capacity_per_day * days_in_season * I_P;

* Single Reservoir Selection Constraint
reservoir_selection_constraint.. I_H + I_L =L= 1;

* Water Balance Constraints
water_balance_constraint(t).. river_inflow(t) =E= R_irrigation(t) + R_groundwater(t);

* Model and Solve
MODEL reservoir_model /all/;
SOLVE reservoir_model USING MIP MAXIMIZING Z;

* Display results
DISPLAY Z.l, I_H.l, I_L.l, I_P.l, R_irrigation.l, R_groundwater.l, P.l, A.l;* Sets and Parameters
