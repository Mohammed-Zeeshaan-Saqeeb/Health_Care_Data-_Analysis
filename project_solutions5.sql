/*Problem Statement 1: 
Johansson is trying to prepare a report on patients who have gone through treatments more than once. 
Help Johansson prepare a report that shows the patient's name, the number of treatments they have undergone, 
and their age, Sort the data in a way that the patients who have undergone more treatments appear on top.*/

select p.personName,
       timestampdiff(year,pt.dob,now()) as age,
       count(t.treatmentID)  as number_of_treatments   
from person p 
inner join patient pt on p.personID=pt.patientID
inner join treatment t using(patientID)
group by pt.patientID,
         timestampdiff(year,pt.dob,now())      
having count(t.treatmentID)>1
order by number_of_treatments desc;

/*Problem Statement 2:  
Bharat is researching the impact of gender on different diseases, 
He wants to analyze if a certain disease is more likely to infect a certain gender or not.
Help Bharat analyze this by creating a report showing for every disease how many males and 
females underwent treatment for each in the year 2021. It would also be helpful for Bharat if the male-to-female ratio is also shown.*/

select d.diseaseName,
	   sum(case when gender='male' then 1 else 0 end) as male,
       sum(case when gender='female' then 1 else 0 end) as female,
       sum(case when gender='male' then 1 else 0 end)/sum(case when gender='female' then 1 else 0 end) as male_to_female_ratio
from person p
inner join patient pt on p.personID=pt.patientID
inner join treatment t using(patientID)
inner join disease d using(diseaseID)
where year(t.date)=2021
group by d.diseaseName;

/*Kelly, from the Fortis Hospital management, has requested a report that shows for each disease, 
the top 3 cities that had the most number treatment for that disease.
Generate a report for Kelly’s requirement.*/

select * from(
select  d.diseaseName,
		a.city,
	   count(t.treatmentID) as number_of_treatments,
       dense_rank() over(partition by diseaseName order by count(t.treatmentID) desc) as r
from person p
inner join address a using(addressID)
inner join patient pt on p.personID=pt.patientID
inner join treatment t using(patientID)
inner join disease d using(diseaseID)
group by d.diseaseName,
		 a.city
order by d.diseaseName asc) t where r<=3;


/*Problem Statement 4: 
Brooke is trying to figure out if patients with a particular disease are preferring some pharmacies over others or not,
 For this purpose, she has requested a detailed pharmacy report that shows each pharmacy name, 
 and how many prescriptions they have prescribed for each disease in 2021 and 2022, 
 She expects the number of prescriptions prescribed in 2021 and 2022 be displayed in two separate columns.
Write a query for Brooke’s requirement.*/
use sql_project;
select d.diseaseName,
	   ph.pharmacyName,
       count(case when year(t.date)=2021 then pr.prescriptionID end ) as 'yr_2021',
       count(case when year(t.date)=2022 then pr.prescriptionID end) as 'yr_2022'
from disease d 
inner join treatment t using(diseaseID)
inner join prescription pr using(treatmentID)
inner join pharmacy ph using(pharmacyID)
group by d.diseaseName,
         ph.pharmacyName
having yr_2021>0 or yr_2022>0
order by diseaseName;

/*Problem Statement 5:  
Walde, from Rock tower insurance, has sent a requirement for a report that presents which insurance company 
is targeting the patients of which state the most. 
Write a query for Walde that fulfills the requirement of Walde.
Note: We can assume that the insurance company is targeting a region more if the patients of that 
region are claiming more insurance of that company*/

select companyName,
	  state,
      total_claims 
from(
		select ic.companyName,
				a.state,
				count(distinct t.claimID) as total_claims,
			     dense_rank() over(partition by ic.companyID order by count(t.claimID) desc) as r
		from person p 
			 left join address a using(addressID)
             left join patient pt on p.personID=pt.patientID
             inner join treatment t using(patientID)
             inner join claim c using(claimID)
             inner join insuranceplan ip using(UIN)
             inner join insurancecompany ic using(companyID)
        group by ic.companyName,
				  a.state
				) tr
where r=1
order by companyName asc;

select distinct companyName from insurancecompany;





