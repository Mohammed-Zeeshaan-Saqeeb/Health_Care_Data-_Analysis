/*Problem Statement 1: A company needs to set up 3 new pharmacies, they have come up with an idea that the pharmacy 
can be set up in cities where the pharmacy-to-prescription ratio is the lowest and the number
 of prescriptions should exceed 100. Assist the company to identify those cities where the pharmacy can be set up.*/
 

 select a.city,
        count(distinct pharmacyID)/count(distinct pr.prescriptionID) as pharmacy_to_prescription
 from pharmacy ph 
      inner join address a on ph.addressID=a.addressID
      left  join prescription pr using(pharmacyID)
 group by a.city 
 having count(pr.prescriptionID)>100
 order by pharmacy_to_prescription  limit 3;
 
 /*Problem Statement 2: The State of Alabama (AL) is trying to manage its healthcare resources more efficiently. 
 For each city in their state, they need to identify the disease for which the maximum number of patients have gone for treatment.
 Assist the state for this purpose.
Note: The state of Alabama is represented as AL in Address Table.*/

with alabama_diseases_cnt as(
select a.city,
       d.diseaseID,
	   d.diseaseName,
	   count(t.treatmentID) as patients_count,
	   rank() over(partition by city order by count(t.treatmentID) desc) as ranks
from person p
    inner join address a using(addressID)
    inner join patient pt on pt.patientID=p.personID
    inner join treatment t using(patientID)
	inner join disease d using(diseaseID)
where state='AL'
group by a.city,d.diseaseID,d.diseaseName)
select city,
      diseaseID,
	  diseaseName,
      patients_count
from alabama_diseases_cnt 
where ranks=1;
use sql_project;

/*Problem Statement 3: The healthcare department needs a report about insurance plans. 
The report is required to include the insurance plan, which was claimed the most and least for each disease. 
 Assist to create such a report.*/
 with cte_disease_insurance_plan as(
 select d.diseaseName,
		i.planName,
		count(c.uin) as cnt,
        dense_rank() over(partition by diseaseName order by count(c.uin) desc) as r
 from treatment t
	  inner join disease d using(diseaseID)
	  inner join claim c using(claimID)
      inner join insuranceplan i using(uin)
 group by d.diseaseName,i.planName),
 min_max_plans as(
 select diseaseName,
		planName,
        cnt,
        r
from cte_disease_insurance_plan c1 
where r=1 
	  or 
	 (diseaseName,r)IN (select diseaseName,
                               max(r) 
                        from cte_disease_insurance_plan c2 
						group by diseaseName))
select  diseaseName,
		case when r=1 then planName end as max_plan,
		case when r=1 then cnt end as max_cnt,
		case when r!=1 then planName end as min_plan,
		case when r!=1 then cnt end as min_cnt
from min_max_plans;



 /*Problem Statement 4: The Healthcare department wants to know which disease is most likely to infect multiple people 
 in the same household.For each disease find the number of households that has more than one patient with the same disease. 
 Note: 2 people are considered to be in the same household if they have the same address. */
 
 use sql_project;
 with cte_disease_household_wise as(
 select a.addressID,
       d.diseaseName,
	   count(distinct patientID) as household_ppl_cnt
 from person p
    inner join address a using(addressID)
    inner join patient pt on p.personID=pt.patientID
    inner join treatment t using(patientID)
	inner join disease d using(diseaseID)
 group by a.addressID, d.diseaseName
 having count(distinct patientID)>1
 )
 select 
       diseaseName,
       count(distinct addressID) as no_of_households
from cte_disease_household_wise
group by diseaseName
order by no_of_households desc;


/*Problem Statement 5:  An Insurance company wants a state wise report of the treatments to claim ratio
 between 1st April 2021 and 31st March 2022 (days both included).
 Assist them to create such a report.*/
 
 select a.state,
	count(t.treatmentID) as total_treatments,
	count(c.claimID) as total_claims,
	count(t.treatmentID)/count(c.claimID) as treatments_to_claim_ratio
 from person p
	 inner join address a using(addressID)
	 inner join patient pt on p.personID=pt.patientID
	 inner join treatment t using(patientID)
	 left join claim c using(claimID)
where t.date between '2021-04-01' and '2022-03-31'
group by a.state 
order by treatments_to_claim_ratio desc;
 
