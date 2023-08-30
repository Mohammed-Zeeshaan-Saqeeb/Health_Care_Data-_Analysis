/*Problem Statement 1:  Some complaints have been lodged by patients that they have been prescribed hospital-exclusive medicine 
that they can’t find elsewhere and facing problems due to that. Joshua, from the pharmacy management, wants to get a report 
of which pharmacies have prescribed hospital-exclusive medicines the most in the years 2021 and 2022. Assist Joshua to
generate the report so that the pharmacies who prescribe hospital-exclusive medicine
more often are advised to avoid such practice if possible.  */ 

select ph.pharmacyName,
count(distinct pr.prescriptionID) as hospital_exclusive_cnt
from pharmacy ph
	inner join prescription pr using(pharmacyID)
	inner join treatment t using(treatmentID)
	inner join contain c using(prescriptionID)
	inner join medicine m using(medicineID)
where m.hospitalExclusive='S'
	 and year(t.date) in (2021,2022)
group by ph.pharmacyName
order by hospital_exclusive_cnt desc;

/*Problem Statement 2: Insurance companies want to assess the performance of their insurance plans.
 Generate a report that shows each insurance plan, the company that issues the plan, and the number of treatments
 the plan was claimed for.*/
 
 select ic.companyName,
		ip.planName,
        count(c.claimID) as total_claims
 from treatment t 
	inner join claim c using(claimID)
	inner join insuranceplan ip using(uin)
	inner join insurancecompany ic using(companyID)
 group by ic.companyName,
		  ip.planName
order by total_claims desc;

/*Problem Statement 3: Insurance companies want to assess the performance of their insurance plans. 
Generate a report that shows each insurance company's name with their most and least claimed insurance plans.*/




with cte_company_ins_plans as(
select ic.companyName,
		ip.planName,
        count(c.claimID) as total_claims,
        dense_rank() over(partition by  ic.companyName order by count(c.claimID) desc) as r
 from treatment t 
	inner join claim c using(claimID)
	inner join insuranceplan ip using(uin)
	inner join insurancecompany ic using(companyID)
 group by ic.companyName,
		  ip.planName)
select *
from cte_company_ins_plans c1
where r=1 
      or r=(select max(r) from cte_company_ins_plans c2 where c2.companyName=c1.companyName and c2.planName=c2.planName);
      
/*Problem Statement 4:  The healthcare department wants a state-wise health report
 to assess which state requires more attention in the healthcare sector. Generate a report for them that shows the 
 state name, number of registered people in the state, number of registered patients in the state, and the people-to-patient ratio. 
 sort the data by people-to-patient ratio */
 
 select * from address;
 select * from person;
 select * from patient;
 
 select a.state,
 count(patientID) as registered_patient_cnt,
 count(p.personID) as registered_ppl_cnt,
 count(patientID)/count(p.personID) as people_to_patient_ratio
 from person p
	left join patient pt on p.personID=pt.patientID
	left join address a on p.addressID=a.addressID
group by a.state;

/*Problem Statement 5:  Jhonny, from the finance department of Arizona(AZ), has requested a 
report that lists the total quantity of medicine each pharmacy in his state has prescribed that falls under Tax criteria 
I for treatments that took place in 2021. Assist Jhonny in generating the report. */
select ph.pharmacyName,
	   sum(quantity) as total_quantity
from pharmacy ph
	inner join prescription pr using(pharmacyID)
    inner join contain c using (prescriptionID)
    inner join medicine m using(medicineID)
    inner join treatment t using(treatmentID)
    inner join address a using (addressID)
where a.state='AZ'
      and m.taxCriteria='I'
      and year(t.date)=2021
group by ph.pharmacyName;


