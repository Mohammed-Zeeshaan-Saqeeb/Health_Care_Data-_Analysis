/*Problem Statement 1:
Patients are complaining that it is often difficult to find some medicines. 
They move from pharmacy to pharmacy to get the required medicine.
A system is required that finds the pharmacies and their contact number that have the required medicine in their inventory. 
 So that the patients can contact the pharmacy and order the required medicine.
Create a stored procedure that can fix the issue.*/

delimiter //
create procedure find_pharmacy_details(in medicine_name varchar(30))
deterministic 
begin
select ph.pharmacyName,
       ph.phone
from pharmacy ph
	 inner join keep k on ph.pharmacyID=k.pharmacyID
     inner join medicine m on k.medicineID=m.medicineID
where m.productName=medicine_name;
end//
delimiter ;
call find_pharmacy_details('neosac');

/*Problem Statement 2:
The pharmacies are trying to estimate the average cost of all the prescribed medicines per prescription, 
for all the prescriptions they have prescribed in a particular year. Create a stored function that will return 
the required value when the pharmacyID and year are passed to it. Test the function with multiple values.*/

drop function pharmacy_prescribed_avg_cost;
delimiter //
create function pharmacy_prescribed_avg_cost(pharmacy_ID int, u_year int)
returns float
deterministic
begin
declare avg_cost float;
select avg(cost_per_prescription) into avg_cost 
 from (
	select  pr.prescriptionID,
           sum(c.quantity*m.maxPrice) as cost_per_prescription
	from pharmacy ph
        inner join prescription pr on ph.pharmacyID=pr.pharmacyID
        inner join contain c on pr.prescriptionID=c.prescriptionID
        inner join medicine m on c.medicineID=m.medicineID
       inner join treatment t on t.treatmentID=pr.treatmentID
    where year(t.date)=u_year and ph.pharmacyID=pharmacy_ID
group by pr.prescriptionID) t ;
return (avg_cost);
end//
delimiter ;
select pharmacy_prescribed_avg_cost(1008,2021);

/*Problem Statement 3:
The healthcare department has requested an application that finds out the disease that was spread the most in a state for a given year.
 So that they can use the information to compare the historical data and gain some insight.
Create a stored function that returns the name of the disease for which the patients from a particular state 
had the most number of treatments for a particular year. Provided the name of the state and year is passed to the stored function.*/
delimiter //
create function disease_with_most_treatments(state varchar(30),u_year int)
returns varchar(30)
deterministic
begin
declare disease_name varchar(30);
select diseaseName into disease_name from(
select d.diseaseName,
       count(t.treatmentID) as treatment_cnt,
       row_number() over(order by count(t.treatmentID) desc) as r
from disease d
     inner join treatment t on d.diseaseID=t.diseaseID
     inner join patient pt on pt.patientID=t.patientID
     inner join person p on p.personID=pt.patientID
     inner join address a on a.addressID=p.addressID
where year(t.date)=u_year and a.state=state
group by diseaseName) t where r=1;
return  (disease_name);
end//
delimiter ;
select disease_with_most_treatments('AL',2022);

/*Problem Statement 4:
The representative of the pharma union, Aubrey, has requested a system that she can use to find how many people 
in a specific city have been treated for a specific disease in a specific year.
Create a stored function for this purpose*/

delimiter //
create  function disease_trtcnt_city_year_wise1(disease_name varchar(30),city varchar(30),u_year int)
returns int
deterministic
begin
declare cnt int;
select count(distinct pt.patientId) into cnt
from disease d
     inner join treatment t on d.diseaseID=t.diseaseID
     inner join patient pt on pt.patientID=t.patientID
     inner join person p on p.personID=pt.patientID
     inner join address a on a.addressID=p.addressID
     where d.diseaseName=disease_name
           and a.city=city
           and year(t.date)=u_year;
return (cnt);
end//
delimiter ;
select disease_trtcnt_city_year_wise1('Cancer','Arvada',2021);

/*Problem Statement 5:
The representative of the pharma union, Aubrey, is trying to audit different aspects of the pharmacies. 
She has requested a system that can be used to find the average balance for claims submitted by a 
specific insurance company in the year 2022. 
Create a stored function that can be used in the requested application*/
drop function ins_cmp_avg_claim_balance;
delimiter //
create function ins_cmp_avg_claim_balance(insurance_cmp varchar(100))
returns decimal
deterministic
begin
declare avg_balance decimal;
select avg(balance) into avg_balance
from  treatment t
      inner join claim c on c.claimID=t.claimID
	  inner join insuranceplan ip on c.uin=ip.uin
      inner join insurancecompany ic on ic.companyID=ip.companyID
where year(t.date)=2022 
      and ic.companyName=insurance_cmp;
return (avg_balance);
end//
delimiter ;
select ins_cmp_avg_claim_balance('Bajaj Allianz General Insurance Co. Ltd.�');
select * from insurancecompany;

 


select avg(cost_per_prescription) 
 from (
	select  pr.prescriptionID,
           sum(c.quantity*m.maxPrice) as cost_per_prescription
	from pharmacy ph
        inner join prescription pr on ph.pharmacyID=pr.pharmacyID
        inner join contain c on pr.prescriptionID=c.prescriptionID
        inner join medicine m on c.medicineID=m.medicineID
       inner join treatment t on t.treatmentID=pr.treatmentID
    where year(t.date)=2021 and ph.pharmacyID=1008
group by pr.prescriptionID) t


