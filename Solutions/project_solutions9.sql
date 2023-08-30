/*Brian, the healthcare department, has requested for a report that shows for each state how many people underwent 
treatment for the disease “Autism”.  He expects the report to show the data for each state as well as each gender 
and for each state and gender combination. Prepare a report for Brian for his requirement.*/

select  a.state,
	    p.gender,
       count(distinct pt.patientID) as total_treatments
from disease d 
	 inner join treatment t on d.diseaseID=t.diseaseID
     inner join patient pt on t.patientID=pt.patientID
     inner join person p on p.personID=pt.patientID
     inner join address a on p.addressID=a.addressId
where d.diseaseName='Autism'
group by a.state,p.gender with rollup

union all
select 'NULL', 
       gender,
       count(t.treatmentID) as total_treatments
from disease d 
	 inner join treatment t on d.diseaseID=t.diseaseID
     inner join patient pt on t.patientID=pt.patientID
     inner join person p on p.personID=pt.patientID
     inner join address a on p.addressID=a.addressId
where d.diseaseName='Autism'
group by gender;

/*Problem Statement 2:  
Insurance companies want to evaluate the performance of different insurance plans they offer. 
Generate a report that shows each insurance plan, the company that issues the plan,
 and the number of treatments the plan was claimed for. The report would be more relevant if the data compares the performance 
 for different years(2020, 2021 and 2022) and if the report also includes the total number of claims in the different years, 
 as well as the total number of claims for each plan in all 3 years combined.*/

with cte1 as(
select ip.uin,
       year(t.date) as `year`,
       -- ic.companyName,
       count(t.claimID) as no_of_claims
from treatment t
	inner join claim c on t.claimID=c.claimID
	inner join insuranceplan ip on ip.uin=c.uin
	inner join insurancecompany ic on ip.companyID=ic.companyID
where year(t.date) in (2020,2021,2022)
group by  ip.uin,
          year(t.date) with rollup)
select ip.planName,
       ic.companyName,
        year,
       no_of_claims
from cte1
     inner join insuranceplan ip on cte1.uin=ip.uin
     inner join insurancecompany ic on ic.companyID=ip.companyID;
     
/*Problem Statement 3:  
Sarah, from the healthcare department, is trying to understand if some diseases are spreading in a particular region.
 Assist Sarah by creating a report which shows each state the number of the most and least treated diseases
 by the patients of that state in the year 2022. 
 It would be helpful for Sarah if the aggregation for the different combinations is found as well. Assist Sarah to create this report. */
 with cte as(
select a.state,
       d.diseaseName,
       count(t.treatmentID) as total_treatments,
       dense_rank() over(order by count(t.treatmentID) desc) as r
from disease d 
	 inner join treatment t on d.diseaseID=t.diseaseID
     inner join patient pt on pt.patientID=t.patientID
     inner join person p on p.personID=pt.patientID
     inner join address a on a.addressID=p.addressID
where year(t.date)=2022
group by a.state,
         d.diseaseName)
select state,
       diseaseName,
       sum(total_treatments) as total_treatments
from cte c1 
where r=1 or
      r=(select max(r) from cte c2 where c2.state=c1.state)
group by state,
         diseaseName with rollup;
         
/*Problem Statement 4: 
Jackson has requested a detailed pharmacy report that shows each pharmacy name, and how many prescriptions they have prescribed 
for each disease in the year 2022, along with this Jackson also needs 
to view how many prescriptions were prescribed by each pharmacy, and the total number prescriptions were prescribed for each disease.
Assist Jackson to create this report. */


select  ph.pharmacyName,
        d.diseaseName,
        count(pr.prescriptionID) as prescriptions_cnt
        
from disease d 
	 inner join treatment t on d.diseaseID=t.diseaseID
     inner join prescription pr on t.treatmentID=pr.treatmentID
     inner join pharmacy ph on ph.pharmacyID=pr.pharmacyID
where year(t.date)=2022
group by ph.pharmacyName,
         d.diseaseName with rollup
union 
select  
        ph.pharmacyName,d.diseaseName,
        count(pr.prescriptionID) as prescriptions_cnt
        
from disease d 
	 inner join treatment t on d.diseaseID=t.diseaseID
     inner join prescription pr on t.treatmentID=pr.treatmentID
     inner join pharmacy ph on ph.pharmacyID=pr.pharmacyID
where year(t.date)=2022
group by d.diseaseName,
         ph.pharmacyName with rollup;
         
/*Problem Statement 5:  
Praveen has requested for a report that finds for every disease how many males and 
females underwent treatment for each in the year 2022. 
It would be helpful for Praveen if the aggregation for the different combinations is found as well.
Assist Praveen to create this report. */

select d.diseaseName,
       p.gender,
       count(distinct pt.patientID) as total_treatments
from disease d
     inner join treatment t on d.diseaseID=t.diseaseID
     inner join patient pt on pt.patientID=t.patientID
     inner join person p on p.personID=pt.patientID
where year(t.date)=2022
group by d.diseaseName,
		p.gender with rollup;





