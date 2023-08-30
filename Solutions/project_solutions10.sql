/* Problem Statement 1:
The healthcare department has requested a system to analyze the performance of insurance companies and their plan.
For this purpose, create a stored procedure that returns the performance of different insurance plans of an insurance company.
 When passed the insurance company ID the procedure should generate and return all the insurance plan names the provided company issues,
 the number of treatments the plan was claimed for, and the name of the disease the plan was claimed for the most. 
 The plans which are claimed more are expected to appear above the plans that are claimed less.*/
 
 drop procedure sp_insurance_comp_performance;
 delimiter //
 create procedure sp_insurance_comp_performance(IN companyID int)
 deterministic
 begin
 with cte as(
 select ip.planName,
		ip.uin,
		d.diseaseName,
        d.diseaseID,
        t.claimID
from disease d
      inner join treatment t on d.diseaseID=t.diseaseID
      inner join claim c on t.claimID=c.claimID
      inner join insuranceplan ip on c.uin=ip.uin
      inner join insurancecompany ic on ip.companyID=ic.companyID
      where ic.companyID=companyID
 ),
cte_total_claims as(
 select uin,
		planName,
        count(claimID) as total_claims
from cte
group by uin,planName 
),
cte_most_claimed_disease as 
(
   select t.uin,t.diseaseName from(
                              select uin,planName,diseaseName,
									count(claimID) as total_claims,
									dense_rank() over(partition by planName order by count(claimID) desc) as r
							 from cte
                             group by uin,
                                     planName,
                                     diseaseName) t where t.r=1
)
select c1.planName,
       c1.total_claims,
       c2.diseaseName as most_claimed_disease
from cte_total_claims c1
inner join cte_most_claimed_disease c2 on c1.uin=c2.uin
order by c1.total_claims desc;
end//
delimiter ;

call sp_insurance_comp_performance(1118);
select * from insurancecompany;
/*Problem Statement 2:
It was reported by some unverified sources that some pharmacies are more popular for certain diseases. 
The healthcare department wants to check the validity of this report.
Create a stored procedure that takes a disease name as a parameter and would return the top 3 pharmacies 
the patients are preferring for the treatment of that disease in 2021 as well as for 2022.
Check if there are common pharmacies in the top 3 list for a disease, in the years 2021 and the year 2022.
Call the stored procedure by passing the values “Asthma” and “Psoriasis” as disease names and draw a conclusion from the result*/

drop procedure top3_pharmacies;
delimiter //
create procedure top3_pharmacies(IN diseasename varchar(30))
deterministic
begin
select year,
	  pharmacyName,r from (
select d.diseaseName,
       year(t.date) as year,
       ph.pharmacyName,
       count(ph.pharmacyName) as no_of_times_visted,
       row_number() over(partition by year(t.date) order by count(ph.pharmacyName) desc) as r
from pharmacy ph
	inner join prescription pr on ph.pharmacyID=pr.pharmacyID
	inner join treatment t on t.treatmentID=pr.treatmentID
	inner join disease d on d.diseaseID=t.diseaseID
where d.diseaseName=diseasename and  year(t.date) in (2021,2022)
group by d.diseaseName,
       year(t.date),
       ph.pharmacyName) t where t.r<=3;
end//
delimiter ;
call top3_pharmacies('Asthma');
call top3_pharmacies('Psoriasis');

/*Problem Statement 3:
Jacob, as a business strategist, wants to figure out if a state is appropriate for setting up an insurance company or not.
Write a stored procedure that finds the num_patients, num_insurance_companies, and insurance_patient_ratio, 
the stored procedure should also find the avg_insurance_patient_ratio and if the insurance_patient_ratio of 
the given state is less than the avg_insurance_patient_ratio then it Recommendation section can have the value “Recommended”
 otherwise the value can be “Not Recommended”.*/
 
/*Description of the terms used:
num_patients: number of registered patients in the given state
num_insurance_companies:  The number of registered insurance companies in the given state
insurance_patient_ratio: The ratio of registered patients and the number of insurance companies in the given state
avg_insurance_patient_ratio: The average of the ratio of registered patients and the number of insurance for all the states.*/

drop procedure recommend_state_ins;
delimiter //

create procedure recommend_state_ins(in state_name varchar(30))
deterministic
begin
with pt_insurance_companies as(
select a.state,
       pt.patientID,
       ic.companyID
from address a
      left join insurancecompany ic on a.addressid=ic.addressId
      left join person p on p.addressid=a.addressid
      left join patient pt on p.personid=pt.patientid),
cte_avg_ins_pt_ratio as(
select
      count(distinct patientID)/count(distinct companyID) as avg_insurance_patient_ratio
      from pt_insurance_companies
)
select state,
       count(distinct patientID) as num_patients,
       count(distinct companyID) as num_insurance_companies,
       count(distinct patientID)/count(distinct companyID) as insurance_patient_ratio,
       c2.avg_insurance_patient_ratio,
	   case when coalesce(count(distinct patientID)/count(distinct companyID),0)> coalesce(c2.avg_insurance_patient_ratio,0) 
		        then "Recommended"
		   else "Not Recommended"
       end as Recommendation
from pt_insurance_companies,
     cte_avg_ins_pt_ratio c2
where state=state_name;
end //
delimiter ;
call recommend_state_ins('MD');
select state from address;

/* Problem Statement 4:
Currently, the data from every state is not in the database, The management has decided to add the data from other states and cities 
as well. It is felt by the management that it would be helpful if the date and time were to be stored whenever new city or state data 
is inserted.
The management has sent a requirement to create a PlacesAdded table if it doesn’t already exist, that has four attributes. 
placeID, placeName, placeType, and timeAdded.
Description
placeID: This is the primary key, it should be auto-incremented starting from 1
placeName: This is the name of the place which is added for the first time
placeType: This is the type of place that is added for the first time. The value can either be ‘city’ or ‘state’
timeAdded: This is the date and time when the new place is added

You have been given the responsibility to create a system that satisfies the requirements of the management.
 Whenever some data is inserted in the Address table that has a new city or state name, 
 the PlacesAdded table should be updated with relevant data. */
 drop table placesAdded;
 drop trigger address_insert_trigger;

CREATE TABLE IF NOT EXISTS PlacesAdded (
  placeID INT AUTO_INCREMENT PRIMARY KEY,
  placeName VARCHAR(255),
  placeType ENUM('city', 'state'),
  timeAdded TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


delimiter //
CREATE TRIGGER address_insert_trigger
AFTER INSERT ON Address
FOR EACH ROW
BEGIN
 
  IF NOT EXISTS(SELECT * FROM PlacesAdded WHERE placeName = NEW.city AND placeType = 'city') THEN
    INSERT INTO PlacesAdded (placeName, placeType) VALUES (NEW.city, 'city');
  END IF;

  IF NOT EXISTS(SELECT * FROM PlacesAdded WHERE placeName = NEW.state AND placeType = 'state') THEN
    INSERT INTO PlacesAdded (placeName, placeType) VALUES (NEW.state, 'state');
  END IF;
END //
delimiter ;

insert into address (state,addressid,city) values('Telangana',12346,'hyderabad');
select * from placesAdded;
delete from address where city='hyderabad';


/*Problem Statement 5:
Some pharmacies suspect there is some discrepancy in their inventory management. 
The quantity in the ‘Keep’ is updated regularly and there is no record of it. 
They have requested to create a system that keeps track of all the transactions whenever the quantity of the inventory is updated.

You have been given the responsibility to create a system that automatically updates a Keep_Log table which has  the following fields:
id: It is a unique field that starts with 1 and increments by 1 for each new entry
medicineID: It is the medicineID of the medicine for which the quantity is updated.
quantity: The quantity of medicine which is to be added. If the quantity is reduced then the number can be negative.

For example:  If in Keep the old quantity was 700 and the new quantity to be updated is 1000, then in Keep_Log the quantity should be 300.
Example 2: If in Keep the old quantity was 700 and the new quantity to be updated is 100, then in Keep_Log the quantity should be -600.*/

create table Keep_Log
(
id int AUTO_INCREMENT PRIMARY KEY,
medicineID int ,
quantity int
);

delimiter //
create trigger after_update_keep_quantity
after update on keep
for each row
begin
declare new_quantity int;
set new_quantity=new.quantity-old.quantity;
insert into Keep_Log(medicineID,quantity) values(old.medicineID,new_quantity);
end//
delimiter ;


