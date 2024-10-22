$ontext
CEE 6410 - Water Resources Systems Analysis
Formulate and solve the PRIMAL and DUAL of the problem.

An aqueduct has excess water capacity in June, July, and August that can be used for irrigation to grow hay and grain. This code defines and solves both the primal and dual models for maximizing profit and minimizing resource costs.

Problem Setup:
- Water availability: June (14,000 acft), July (18,000 acft), August (6,000 acft)
- Land availability: 10,000 acres
- Water requirements per crop (acft/acre) and return ($/acre):
  - Hay: June (2), July (1), August (1); Return: $100/acre
  - Grain: June (1), July (2), August (0); Return: $120/acre    

shailendra khanal
s.khanal@usu.edu
$offtext


* 1. DEFINE the SETS
SETS
    crops /hay, grain/  
    res /June, July, August, Land/;

* 2. DEFINE input data
PARAMETERS
    profit_per_acre(crops) 'Profit per acre for each crop'
        /hay 100, grain 120/
    resource_avail(res) 'Resource availability (acre-feet of water and total land)'
        /June 14000, July 18000, August 6000, Land 10000/;

TABLE water_usage(crops, res) 'Water usage per acre by crop and month (acre-feet per acre)'
              June   July   August  Land
    hay        2      1      1        1
    grain      1      2      0        1;

* 3. DEFINE the VARIABLES
VARIABLES 
    acres_planted(crops) 'Acres planted for each crop'
    total_profit 'Total profit ($)'
    dual_prices(res) 'Dual variables (shadow prices) for resource constraints'
    total_resource_cost 'Total reduced cost ($)';

* Non-negativity constraints
POSITIVE VARIABLES acres_planted, dual_prices;

* 4. COMBINE variables and data in equations

* Primal Equations: Maximize total profit
EQUATIONS
    PROFIT_PRIMAL 'Total profit ($) and objective function'
    RES_CONS_PRIMAL(res) 'Resource constraints for water and land';

PROFIT_PRIMAL.. total_profit =E= SUM(crops, profit_per_acre(crops) * acres_planted(crops));

RES_CONS_PRIMAL(res).. SUM(crops, water_usage(crops, res) * acres_planted(crops)) =L= resource_avail(res);

* Dual Equations: Minimize resource cost
EQUATIONS
    REDCOST_DUAL 'Total cost of using resources'
    RES_CONS_DUAL(crops) 'Ensure profitability for each crop';

REDCOST_DUAL.. total_resource_cost =E= SUM(res, resource_avail(res) * dual_prices(res));

RES_CONS_DUAL(crops).. SUM(res, water_usage(crops, res) * dual_prices(res)) =G= profit_per_acre(crops);

* 5. DEFINE the MODELS
* Primal model
MODEL IRRIGATION_PRIMAL /PROFIT_PRIMAL, RES_CONS_PRIMAL/;

* Dual model
MODEL IRRIGATION_DUAL /REDCOST_DUAL, RES_CONS_DUAL/;

* 6. SOLVE the MODELS
* Solve the IRRIGATION PRIMAL model using a Linear Programming solver
SOLVE IRRIGATION_PRIMAL USING LP MAXIMIZING total_profit;

* Solve the IRRIGATION DUAL model using a Linear Programming solver
SOLVE IRRIGATION_DUAL USING LP MINIMIZING total_resource_cost;

* 7. DISPLAY the results
DISPLAY acres_planted.l, total_profit.l, dual_prices.l, total_resource_cost.l;
