$ontext
**** Reservoir Operation Problem ****

This model is designed to maximize the total economic benefit from hydropower and irrigation
over a six-month period. The reservoir system includes hydropower turbines, water for irrigation,
and an in-stream flow requirement at point A.

The reservoir has the following features:
- Initial storage: 5 units of water.
- Maximum reservoir capacity: 9 units.
- Hydropower turbines: Maximum release of 4 units of water per month.
- Minimum flow to point A: At least 1 unit of water must flow downstream to point A every month.
- Objective: Maximize economic benefits from hydropower and irrigation.

The mass balance equations track the water storage in the reservoir each month, accounting
for inflows, releases for hydropower, irrigation, and spills.

Reservoir storage in Time t is storage at the **end** of period t. Inflow in time period t, Spill in time period t, and Hydropower release in time t occur across the time period t-1 to t.
* General equation: ResBalance(t)..  Storage(t) = Storage(t-1) + Inflow(t) - Spill(t) - Hydropower(t); 
* Special cases:
*    A) In timestep #1, there is no prior timestep [Storage(1-1)] is undefined]. Instead, storage at the beginning of timestep #1 is Initial storage
*           Code in GAMS as: InitialStorage$(ord(t) eq 1) => means only add initial storage if t is the first element of the set t (i.e., "m1")
*    B) In timestep #1, there is no prior period storage. Only include storage if period i is greater than or equal to the second element of the set t (i.e., "m2", "m3", ..., "m6").
*           Code in GAMS as: Storage(t-1)$(ord(t) gt 1) => means only include storage at the end of prior timestep of t if t is the second, third, forth, fifth, or sixth element of set t (m2 to m6)
*
*    Combine A) and B) into the general equation. Will let you do for HW #5
* 
*    C) In timestep #6, the end of period storage is initial storage, i.e., t = "m6". Code in GAMS as a separate equation:
*           EndStorage.. Storage("m6") =G= InitialStorage;

Approach:
- At each month, water can either be released for hydropower, spilled, or used for irrigation.
- Water from both hydropower and spills is combined at a point (Point C), where it is either used
  for irrigation or released downstream to point A.

$offtext

Sets
* Months 1 to 6 (6 months in total)
    t /1*6/ ;  

Parameters
* Inflows to the reservoir in each month
    inflow(t)      /1 2, 2 2, 3 3, 4 4, 5 3, 6 2/   
* Hydropower benefits per unit of water (measured in $)
    HB(t)          /1 1.6, 2 1.7, 3 1.8, 4 1.9, 5 2.0, 6 2.0/
* Irrigation benefits per unit of water (measured in $)
    IB(t)          /1 1.0, 2 1.2, 3 1.9, 4 2.0, 5 2.2, 6 2.2/
    
Scalar
* Initial storage in the reservoir is 5 units
    InitialStorage /5/ ;  

Variables
    H(t)           "Water released for hydropower in month t"
    spill(t)       "Water spilled (bypassed from turbines) in month t"
    I(t)           "Water diverted for irrigation in month t"
    f_A(t)         "Water flowing to point A (minimum in-stream flow requirement) in month t"
    S(t)           "Reservoir storage at the end of each month t"
    Z              "Total economic benefit from hydropower and irrigation"

Positive Variables
* Non-negative decision variables
    H, spill, I, f_A, S ;  

Equations
    obj             "Objective function"
    mass_balance(t) "Mass balance constraint for each month"
    flow_distribution(t) "Flow distribution at Point C (combining spill and hydropower)"
    min_flow(t)     "Minimum in-stream flow requirement for each month"
    hydro_cap(t)    "Hydropower turbine capacity constraint"
    storage_limit(t) "Reservoir capacity constraint"
    final_storage   "Final storage must be at least equal to initial storage";

* Objective function: Maximize total economic benefit from hydropower and irrigation
obj ..
    Z =e= sum(t, HB (t) * H(t) + IB (t) * I(t));

* Mass balance constraint for each month: Ensures that storage at the end of each month
* is updated based on inflows, hydropower releases, and spill.
mass_balance(t) ..
    S(t) =e= InitialStorage$(ord(t) eq 1) + S(t-1)$(ord(t) gt 1) + inflow(t) - H(t) - spill(t);

* Flow distribution at Point C: Total flow at Point C is split between irrigation and flow to Point A
flow_distribution(t) ..
    H(t) + spill(t) =e= I(t) + f_A(t);

* Minimum in-stream flow requirement: At least 1 unit of water must flow to Point A each month
min_flow(t) ..
    f_A(t) =g= 1;

* Hydropower capacity: The turbines have a maximum capacity of 4 units of water per month
hydro_cap(t) ..
    H(t) =l= 4;

* Reservoir capacity: The reservoir storage cannot exceed 9 units
storage_limit(t) ..
    S(t) =l= 9;

* Final storage requirement: The storage at the end of the last month (t=6) must be at least
* as large as the initial storage (5 units).
final_storage ..
    S('6') =g= InitialStorage;

Model reservoir_operation /all/;
Solve reservoir_operation maximizing Z using lp ;

Display H.l , I.l , spill.l, f_A.l, S.l, Z.l;