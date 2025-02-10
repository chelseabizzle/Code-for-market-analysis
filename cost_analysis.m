clearvars

pwd

cd '/Users/chelseabunke/Library/CloudStorage/OneDrive-ImperialCollegeLondon/project'

data_births = readtable('Tables_2_and_3.xlsx','Sheet','Table 2');

%-----removing second column of NaN values, removing columns on disability
%for the sake of the visualization of this analysis.
data_births = removevars(data_births,{'liveBirths_percentage_','NoDisability','MildDisability', ...
    'ModerateDisability','SevereDisability'});

total_births_2023 = 591072+45935; %this is live, not doing still in this analysis

ideal_rate = 0.06;

rate_2023 = 0.081;

real_PTBs_2023 = total_births_2023*rate_2023;

target_PTBs_2023 = total_births_2023*ideal_rate; % this is rounded up

%-----Initializing my new table variable
percentage = zeros([19 1]); %percentage = the percentage of PTBs in this week of gestation
data_births = addvars(data_births,percentage,'NewVariableNames','percentage'); 

for i = 6:19 %i = 6:19 is weeks 23:36 preterm
    data_births{i,"percentage"} = data_births{i,"LiveBirths"} ./ data_births{3,"LiveBirths"};
end

%--------Using this percentage of PTBs in each week of gestation to model
%this on real 2023 data.

%--------Initializing my new variables
new_data = zeros([19 1]); %new_data is the percentage from the 
% Mangham study modelled on the data from 2023.

new_data(3,1) = target_PTBs_2023;
survivor_percentage = zeros([19 1]);%Initializing survivor numbers for the 2023 data
new_survivors = zeros([19 1]);
data_births = addvars(data_births,new_data,new_survivors,survivor_percentage);

for i = 6:19
    data_births{i,"new_data"} = data_births{i,"percentage"} .* data_births{3,"new_data"}; %number of PTBs by week in 2023 based on Mangham's study.
    data_births{i,"new_data"} = round(data_births{i,"new_data"}); %Rounding to the nearest integer.
    data_births{i,"survivor_percentage"} = data_births{i,"Survived"} ./ data_births{3,"LiveBirths"};
    data_births{i,"new_survivors"} = data_births{i,"survivor_percentage"} .* data_births{3,"new_data"}; %Number of survivors in 2023 by week of gestation.
    data_births{i,"new_survivors"} = round(data_births{i,"new_survivors"});%Rounding to the nearest integer.
    data_births{3,"new_survivors"} = data_births{3,"new_survivors"} + data_births{i,"new_survivors"}; %All of the PTB survivors in 2023.
end

%-----Now looking at costs
costs = readtable('Tables_2_and_3.xlsx','Sheet','Table 3');
cost_per_survivor = costs{:,5}; %Column 5 is the incremental cost per survivor by gestational week.
%------Initializing my variables
total_cost_new_rate_pre_inflation = zeros([19 1]);
data_births = addvars(data_births,cost_per_survivor,total_cost_new_rate_pre_inflation);
for i = 6:19
    data_births{i,"total_cost_new_rate_pre_inflation"} = data_births{i,"new_survivors"} .* data_births{i,"cost_per_survivor"}; %Total cost per week of gestation
    data_births{3,"total_cost_new_rate_pre_inflation"} = data_births{3,"total_cost_new_rate_pre_inflation"} + data_births{i,"total_cost_new_rate_pre_inflation"}; %Total cost of all PTB survivors.
end

%-----Analysis based on real 2023 PTB numbers
%-----Initializing
real_new_data = zeros([19 1]);
real_survivors = zeros([19 1]);
real_survivor_percentage = zeros([19 1]);
real_new_data(3,1) = real_PTBs_2023; %Putting in real PTB numbers
data_births = addvars(data_births,real_new_data,real_survivors,real_survivor_percentage);
for i = 6:19
    data_births{i,"real_new_data"} = data_births{i,"percentage"} .* data_births{3,"real_new_data"};
    data_births{i,"real_new_data"} = round(data_births{i,"real_new_data"});%Rounding to nearest integer
    data_births{i,"real_survivor_percentage"} = data_births{i,"Survived"} ./ data_births{3,"LiveBirths"};
    data_births{i,"real_survivors"} = data_births{i,"real_survivor_percentage"} .* data_births{3,"real_new_data"};%Number of survivors by gestational week
    data_births{i,"real_survivors"} = round(data_births{i,"real_survivors"});%Rounding to nearest integer
    data_births{3,"real_survivors"} = data_births{3,"real_survivors"} + data_births{i,"real_survivors"};%Total survivors in all PTBs
end

%-----Costs
cost_per_survivor = costs{:,5};
%-----Initializing
total_cost_new_rate_pre_inflation = zeros([19 1]);
data_births = addvars(data_births,total_cost_new_rate_pre_inflation,'NewVariableNames',"real_total_cost_new_rate_pre_inflation");
for i = 6:19
    data_births{i,"real_total_cost_new_rate_pre_inflation"} = data_births{i,"real_survivors"} .* data_births{i,"cost_per_survivor"}; %Cost per gestational week
    data_births{3,"real_total_cost_new_rate_pre_inflation"} = data_births{3,"real_total_cost_new_rate_pre_inflation"} + data_births{i,"real_total_cost_new_rate_pre_inflation"}; %Cost for all PTBs
end

%Printing the incremental costs in the target case and the ideal case.
data_births{3,"total_cost_new_rate_pre_inflation"}
data_births{3,"real_total_cost_new_rate_pre_inflation"}


%%

array = data_births{6:19,"Survived"}.*data_births{6:19,"cost_per_survivor"};
sum(array,1)

%% -------------------------------US data

clearvars

%---------------- specific costs

med_care_child = 17126625946;
delivery_costs = 1950230570;
Early_Intervention_Services = 702014493;
Special_Education_Services = 622589060;
Assistive_Devices = 10820563;
Lost_Labor_Market_Productivity = 4750215975;
total = med_care_child + delivery_costs + ...
    Early_Intervention_Services + Special_Education_Services + ...
    Assistive_Devices + Lost_Labor_Market_Productivity

total_births_2023 = 3596017 + 21000

national_rate = 0.104;

target_rate = 0.094;

total_PTBs_2023 = total_births_2023*0.104

array=zeros([3 7]);

data_2016 = array2table(array);

data_2016 = renamevars(data_2016,{'array1','array2','array3','array4','array5','array6','array7'},...
    {'cost of medical care','Maternal Delivery Costs', ...
  'Early Intervention Services (EI)','Special Education Services','Assistive Devices','Lost Labor Market Productivity', ...
   'Total'});

data_2016{1,"cost of medical care"}=med_care_child;
data_2016{1,"Maternal Delivery Costs"}=delivery_costs;
data_2016{1,"Early Intervention Services (EI)"}=Early_Intervention_Services;
data_2016{1,"Special Education Services"}=Special_Education_Services;
data_2016{1,"Assistive Devices"}=Assistive_Devices;
data_2016{1,"Lost Labor Market Productivity"}=Lost_Labor_Market_Productivity;
data_2016{1,"Total"}=total;

cost_per_PTB = 64815;

PTB_rate_2016 = 0.094;

total_births_2016_factor = 100/9.4;

PTB_births = [total/cost_per_PTB; 0; 0];

total_births_2016 = total_births_2016_factor*PTB_births;

data_2016 = addvars(data_2016,PTB_births,'NewVariableNames','PTB births');

cost_of_PTBs_2023 = cost_per_PTB*total_PTBs_2023; %this is a little bit lower, just because the birth rate has gone down.

% now i will model the cost for the target at the current birth rate

cost_of_target_2023 = cost_per_PTB*(target_rate*total_births_2023); %~22B USD

% could do a sample of this for massachusetts and mississippi?

% i am now modelling the different specific costs under the different
% paradigms

for i = 1:6
    data_2016{2,i} = data_2016{1,i}/total*cost_of_PTBs_2023; %new costs of the true cost 2023
    data_2016{3,i} = data_2016{1,i}/total*cost_of_target_2023; %new costs of the target 2023
    data_2016{2,"Total"} = data_2016{2,"Total"} + data_2016{2,i};
    data_2016{3,"Total"} = data_2016{3,"Total"} + data_2016{3,i};

end



%%  

format long

825000 - (825000*(0.15+0.265))

482625*0.97

ans*0.96

468146*0.96

5507000 - ((5507000*(0.15*0.8)) + (5507000*(0.131*0.928)))

(3596017 + 21000)/4176685

1.155*0.761*4176685

3671111*0.12*0.96

825000 - (825000*((0.15*0.8)+(0.265*0.93)))

522679*0.97
