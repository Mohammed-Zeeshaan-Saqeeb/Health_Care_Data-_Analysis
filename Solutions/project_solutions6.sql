/*Problem Statement 1: 
The healthcare department wants a pharmacy report on the percentage of hospital-exclusive medicine prescribed in the year 2022.
Assist the healthcare department to view for each pharmacy, the pharmacy id, pharmacy name, total quantity of medicine prescribed 
in 2022, total quantity of hospital-exclusive medicine prescribed by the pharmacy in 2022, and the percentage of 
hospital-exclusive medicine to the total medicine prescribed in 2022.
Order the result in descending order of the percentage found. */

select ph.pharmacyID,
	   ph.pharmacyName,
       sum(c.quantity) as total_medicines_prescribed,
       sum(case when m.hospitalExclusive='S' then quantity else 0 end) as total_hospital_exclusive_prescribed,
       (sum(case when m.hospitalExclusive='S' then quantity else 0 end)/sum(c.quantity))*100 as pct_hospital_exclusive
from pharmacy ph 
inner join prescription using(pharmacyID)
inner join contain c using(prescriptionID)
inner join medicine m using(medicineID)
inner join treatment t using(treatmentID)
where year(t.date)=2022
group by ph.pharmacyID,
	     ph.pharmacyName
order by pct_hospital_exclusive desc;

/*Sarah, from the healthcare department, has noticed many people do not claim insurance for their treatment.
She has requested a state-wise report of the percentage of treatments that took place without claiming insurance.
 Assist Sarah by creating a report as per her requirement.*/
 
 select a.state,
        (sum(case when t.claimID is null then 1 else 0 end)/count(*))*100.0 as pct_of_treatments_without_claim
 from treatment t
	 inner join patient pt using(patientID)
     inner join person p on p.personID=pt.patientID
     inner join address a using(addressID)
	 left join claim c using(claimID)
 group by a.state
 order by pct_of_treatments_without_claim desc;
 
/*Problem Statement 3:  
Sarah, from the healthcare department, is trying to understand if some diseases are spreading in a particular region. 
Assist Sarah by creating a report which shows for each state, the number of the most and least treated diseases 
by the patients of that state in the year 2022.*/

with cte_diseases_treated_statewise as(
select a.state,
       d.diseaseName,
       count(t.treatmentID) as total_treatments,
       dense_rank() over(partition by a.state order by count(t.treatmentID) desc) as r
from treatment t
     inner join patient pt using(patientID)
     inner join person p on p.personID=pt.patientID
     inner join address a using(addressID)
     inner join disease d using(diseaseID)
where year(t.date)=2022
group by a.state,
         d.diseaseName)
select state,
       diseaseName,
       total_treatments,r
from cte_diseases_treated_statewise c1
where  r=1 or
     (state,r) IN (select state,max(r) 
                                    from cte_diseases_treated_statewise c2
									group by state);

/*Manish, from the healthcare department, wants to know how many registered people are registered as patients as well, in each city. 
Generate a report that shows each city that has 10 or more registered people belonging to it
 and the number of patients from that city as well as the percentage of the patient with respect to the registered people.*/
 
 select a.state,
        a.city,
        count(pt.patientID) as total_registered_patients,
        count(p.personID) as total_registered_persons,
        count(pt.patientID)/count(p.personID)*100 as pct_patient_reg_ppl
 from person p
	  left join patient pt on p.personID=pt.patientID
	  left join address a on p.addressID=a.addressID
group by a.state,a.city
having count(p.personID)>=10;

/*Problem Statement 5:  
It is suspected by healthcare research department that the substance “ranitidine” might be causing some side effects.
 Find the top 3 companies using the substance in their medicine so that they can be informed about it.*/
 
 select * from (
 select m.companyName,
       count(distinct m.medicineID) as no_of_medicines,
       dense_rank() over(order by count(distinct m.medicineID) desc) as r
 from medicine m
 where m.substanceName like'%ranitidina%'
 group by m.companyName
 ) t where r<=3;
 
 
 select * from medicine;
 
 
 

      
 

  
