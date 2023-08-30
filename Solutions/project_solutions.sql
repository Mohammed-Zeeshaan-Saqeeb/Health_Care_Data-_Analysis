/*Problem Statement 1:  Jimmy, from the healthcare department, has requested a report that shows how the number of treatments each age 
category of patients has gone through in the year 2022. 
The age category is as follows, Children (00-14 years), Youth (15-24 years), Adults (25-64 years), and Seniors (65 years and over).
Assist Jimmy in generating the report. */
select * from person;
select * from patient;
select * from treatment;

select 
case when timestampdiff(year,dob,curdate()) between 0 and 14 then 'Children'
when timestampdiff(year,dob,curdate()) between 15 and 24 then 'Youth'
when timestampdiff(year,dob,curdate()) between 25 and 64 then 'Adults'
else 'Seniors' end as Age_Category,
count(t.treatmentID) as count
from treatment t
inner join patient p using(patientID)
where year(t.date)=2022
group by age_category;

/*Problem Statement 2:  Jimmy, from the healthcare department, wants to know which disease is infecting people 
of which gender more often.
Assist Jimmy with this purpose by generating a report that shows for each disease the male-to-female ratio.
 Sort the data in a way that is helpful for Jimmy.*/
 
select d.diseaseName,
sum(case when p.gender='male' then 1 else 0 end) as 'Males',
sum(case when p.gender='female' then 1 else 0 end) as 'Females',
round(sum(case when p.gender='male' then 1 else 0 end) /sum(case when p.gender='female' then 1 else 0 end),2) as male_to_female_ratio
from person p
inner join patient pt on p.personID=pt.patientID
inner join treatment t using(patientID)
inner join disease d using(diseaseID)
group by d.diseaseName
order by male_to_female_ratio desc;
 
 /*Problem Statement 3: Jacob, from insurance management, has noticed that insurance claims are not made for all the treatments.
 He also wants to figure out if the gender of the patient has any impact on the insurance claim. 
 Assist Jacob in this situation by generating a report that finds for each gender the number of treatments, 
 number of claims, and treatment-to-claim ratio. 
 And notice if there is a significant difference between the treatment-to-claim ratio of male and female patients.*/
select p.gender,
count(t.treatmentID) as number_of_treatments,
count(c.claimID) as number_of_claims,
count(c.claimID)/count(t.treatmentID) as treatment_to_claim_ration
from person p 
inner join patient pt on p.personID=pt.patientID
inner join treatment t on pt.patientID=t.patientID
left  join claim c on c.claimID=t.claimID
group by gender;

/*Problem Statement 4: The Healthcare department wants a report about the inventory of pharmacies.
 Generate a report on their behalf that shows how many units of medicine each pharmacy has in their inventory,
 the total maximum retail price of those medicines, and the total price of all the medicines after discount. 
Note: discount field in keep signifies the percentage of discount on the maximum price.*/

select ph.pharmacyName,
sum(quantity),
sum(quantity*maxPrice) as total_MRP,
sum(quantity*maxPrice-(discount/100.0*maxPrice*quantity)) as total_MRP_after_discount
from
pharmacy ph 
inner join keep k using(pharmacyID)
inner join medicine m on k.medicineID=m.medicineID
group by ph.pharmacyID,ph.pharmacyName;

/*Problem Statement 5:  The healthcare department suspects that some pharmacies prescribe more medicines than others 
in a single prescription, for them, generate a report that 
finds for each pharmacy the maximum, minimum and average number of medicines prescribed in their prescriptions. */

with total_medicines as(
select ph.pharmacyID,ph.pharmacyName,pr.prescriptionID,
sum(quantity) as medicines_per_prescription from 
pharmacy  ph inner join prescription pr using(pharmacyID)
inner join contain c using(prescriptionID)
group by pharmacyName,pr.prescriptionID)
select pharmacyID,pharmacyName,
min(medicines_per_prescription) as minimum,
max(medicines_per_prescription) as maximum,
avg(medicines_per_prescription) as average
from total_medicines
group by 1,pharmacyName order by 1;



