/*The healthcare department attempting to use the resources more efficiently.
 It already has some queries that are being used for different purposes. 
 The management suspects that these queries might not be efficient so they have requested to optimize the
 existing queries wherever necessary.

Given are some queries written in SQL server which may be optimized if necessary.

Query 1: 
-- For each age(in years), how many patients have gone for treatment?
SELECT DATEDIFF(hour, dob , GETDATE())/8766 AS age, count(*) AS numTreatments
FROM Person
JOIN Patient ON Patient.patientID = Person.personID
JOIN Treatment ON Treatment.patientID = Patient.patientID
group by DATEDIFF(hour, dob , GETDATE())/8766
order by numTreatments desc; */

select timestampdiff(year,dob,now()) as age,
	   count(pt.patientID)
from patient pt
inner join treatment t on pt.patientID=t.patientID
group by timestampdiff(year,dob,now())
order by age desc;

-- For each city, Find the number of registered people, number of pharmacies, and number of insurance companies.

select a.city,
      count(distinct p.personID) as no_of_reg_ppl,
      count(distinct ph.pharmacyID) as no_of_pharmacies,
      count(distinct ic.companyID) as no_of_ins_compaies
      
from address a
    left join person  p on p.addressID=a.addressID
    left join pharmacy ph on ph.addressID=a.addressID
	left join insurancecompany ic on ic.addressID=a.addressID
group by a.city
order by no_of_reg_ppl desc;

-- Query 3: 
-- Total quantity of medicine for each prescription prescribed by Ally Scripts
-- If the total quantity of medicine is less than 20 tag it as "Low Quantity".
-- If the total quantity of medicine is from 20 to 49 (both numbers including) tag it as "Medium Quantity".
-- If the quantity is more than equal to 50 then tag it as "High quantity".

select c.prescriptionID,
       sum(c.quantity) as total_quantity,
       case when sum(c.quantity)<20 then "Low Quantity"
            when sum(c.quantity)<=49 then "Medium quantity"
            else "High quantity"
		end as quantity_category
from pharmacy ph
     inner join prescription pr on ph.pharmacyID=pr.pharmacyID
     inner join contain c on c.prescriptionID=pr.prescriptionID
where ph.pharmacyName='Ally Scripts'
group by c.prescriptionID;


-- The total quantity of medicine in a prescription is the sum of the quantity of all the medicines in the prescription.
-- Select the prescriptions for which the total quantity of medicine exceeds
-- the avg of the total quantity of medicines for all the prescriptions.


with cte as(
select pr.prescriptionID,
      sum(quantity) as prescription_wise_quantities
from prescription pr 
	inner join contain c on pr.prescriptionID=c.prescriptionID
group by pr.prescriptionID)
select prescriptionID,
      prescription_wise_quantities
from cte 
where prescription_wise_quantities>
                                 (select avg(prescription_wise_quantities) from cte);
                                 
-- Select every disease that has 'p' in its name, and 
-- the number of times an insurance claim was made for each of them. 

select d.diseaseName,
	  count(t.claimID) as no_of_claims
from disease d
inner join treatment t on d.diseaseID=t.diseaseID
inner join claim c on t.claimID=c.claimID
where d.diseaseName like '%p%'
group by d.diseaseName;

use sql_project;
select count(prescriptionid) from prescription;
select * from medicine;
show indexes from  medicine;

create index id1 on medicine(medicineid);

select count(distinct medicineid) from medicine;

explain select count(distinct medicineid) from medicine where medicineid<10000;
