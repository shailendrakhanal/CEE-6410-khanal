$ontext
Irrigation problem with reservoir and pump options 
$offtext

* 1. Define Sets
SETS
    t       /1*2/     
    runs    /r1*r4/;     

* 2. Define Parameters
PARAMETERS
    Qt(t)          /1 600, 2 200/     
    Demand(t)      /1 1.0, 2 3.0/      
    HighDamCost    /10000/          
    LowDamCost     /6000/            
    PumpCost       /8000/             
    OperatingCost  /20/                
    RevenuePerAcre /300/                
    DaysPerSeason  /180/                 
    PumpHoursPerDay /6/;                

* Programming Data
PARAMETER
    PumpCapacity(runs)   Pump capacity per day (acre-feet per day);

PumpCapacity(runs) = 2.2 - 0.5*(ord(runs)-1);

DISPLAY PumpCapacity;

* 3. Define Variables
VARIABLES
    X1, X2, Y   
    I(t)         
    S(t)          
    Z;            

BINARY VARIABLES X1, X2, Y;
POSITIVE VARIABLES I, S;

* 4. Declaring the Equations 
EQUATIONS
    PROFIT                      * Objective function
    water_balance1              * Water balance for season 1
    water_balance2              * Water balance for season 2
    irrigation_demand1          * Irrigation demand for season 1
    irrigation_demand2          * Irrigation demand for season 2
    reservoir_capacity          * Storage capacity constraint
    pump_limit1                 * Pump capacity limit for season 1
    pump_limit2                 * Pump capacity limit for season 2
    dam_choice                  * Only one dam can be built   ;

* Scalar for pump capacity 
SCALAR current_pump_capacity /0/;

* Defining the logic of each equation
PROFIT..
    Z =E= RevenuePerAcre * SUM(t, I(t)/ Demand(t)) 
         - HighDamCost * X1
         - LowDamCost * X2
         - PumpCost * Y
         - OperatingCost * current_pump_capacity * PumpHoursPerDay * DaysPerSeason * Y;

water_balance1..
    S('1') =E= Qt('1') - I('1') + current_pump_capacity * Y;

water_balance2..
    S('2') =E= S('1') + Qt('2') - I('2') + current_pump_capacity * Y;

irrigation_demand1..
    I('1') =G= Demand('1');

irrigation_demand2..
    I('2') =G= Demand('2');

reservoir_capacity..
    S('1') =L= 700 * X1 + 300 * X2;

pump_limit1..
        I('1') =L= current_pump_capacity  * PumpHoursPerDay * DaysPerSeason * Y;

pump_limit2..
        I('2') =L= current_pump_capacity  * PumpHoursPerDay * DaysPerSeason * Y;

dam_choice..
    X1 + X2 =E= 1;


* 5. Define the Model
MODEL irrigation_problem /ALL/;


* Parameters to store results
PARAMETERS
    ObjFunc(runs)           Objective function values ($)
    DecVars_X1(runs)        Decision variable X1 (High Dam decision)
    DecVars_X2(runs)        Decision variable X2 (Low Dam decision)
    DecVars_Y(runs)         Decision variable Y (Pump decision)
    DecVars_I(runs,t)       Irrigation amounts per season
    DecVars_S(runs,t)       Storage amounts per season
    current_pump_capacity   Declare current pump capacity;
* 6. Implementing the Loop (with Parameter Updates, No Equation Redefinition)
LOOP(runs,

* Update parameters for each run
current_pump_capacity = PumpCapacity(runs);
    
   
* Solve the model
    SOLVE irrigation_problem USING MIP MAXIMIZING Z;


* Store the results
    ObjFunc(runs)        = Z.L;
    DecVars_X1(runs)     = X1.L;
    DecVars_X2(runs)     = X2.L;
    DecVars_Y(runs)      = Y.L;
    DecVars_I(runs,t)    = I.L(t);
    DecVars_S(runs,t)    = S.L(t);
);

* 7. Display Results
DISPLAY PumpCapacity, ObjFunc, DecVars_X1, DecVars_X2, DecVars_Y, DecVars_I, DecVars_S;