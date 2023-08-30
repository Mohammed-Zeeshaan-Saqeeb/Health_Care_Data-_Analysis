/*Insurance companies want to know if a disease is claimed higher or lower than average.  
Write a stored procedure that returns “claimed higher than average” or “claimed lower than average” when the diseaseID is passed to it. 
Hint: Find average number of insurance claims for all the diseases.  
If the number of claims for the passed disease is higher than the average return “claimed higher than average” 
otherwise “claimed lower than average”.*/

delimiter //
create procedure disease_claimed(IN u_diseaseID varchar(30),OUT res varchar(30))
deterministic
begin
with cte1 as(
select diseaseID,
       count(claimID) as no_of_claims
from disease d
     inner join treatment t using(diseaseID)
     left join claim c using(claimID)
group by diseaseID),
cte2 as(
select avg(no_of_claims) as avg_num_claims from cte1
),
cte3 as(
select cte1.diseaseID,
	   cte1.no_of_claims,
       case when cte1.no_of_claims>cte2.avg_num_claims then "claimed higher than average"
             else "claimed lower than average" 
		end as 'Claims'
from cte1,cte2
)
select Claims into res 
from cte3 where diseaseID=u_diseaseID;
end//
 delimiter ;
 call  disease_claimed(15,@x);
 select @x;
/*Problem Statement 2:  
Joseph from Healthcare department has requested for an application which helps him get genderwise report for any disease. 
Write a stored procedure when passed a disease_id returns 4 columns,
disease_name, number_of_male_treated, number_of_female_treated, more_treated_gender*/
drop procedure genderwise_disease_report;
delimiter //
create procedure genderwise_disease_report
                                     (IN u_diseaseID int,
                                     OUT diseaseName varchar(30),
                                     OUT number_of_males_treated int,
                                     OUT number_of_females_treated int,
                                     OUT more_treated_gender varchar(30))
deterministic
begin

select d.diseaseName,
       sum(case when gender='male' then 1 else 0 end)  as males,
       sum(case when gender='female' then 1 else 0 end) as females ,
       case 
          when sum(case when gender='male' then 1 else 0 end)>sum(case when gender='female' then 1 else 0 end) then "male"
          when sum(case when gender='male' then 1 else 0 end)>sum(case when gender='female' then 1 else 0 end) then "female"
          else "same"
	   end as more_treated_gender 
into  diseaseName,
	  number_of_males_treated,
	  number_of_females_treated,
	   more_treated_gender
from person p
	inner join patient pt on p.personID=pt.patientID
	inner join treatment t using(patientID)
	inner join disease d using(diseaseID)
where diseaseID=u_diseaseID
group by d.diseaseName;
end//
delimiter ;
call genderwise_disease_report(2,@diseaseName,
                                 @number_of_males_treated,
								 @number_of_females_treated,
					             @more_treated_gender);
					
select   @diseaseName,
		 @number_of_males_treated,
		 @number_of_females_treated,
		 @more_treated_gender;
         
/*Problem Statement 3:  
The insurance companies want a report on the claims of different insurance plans. 
Write a query that finds the top 3 most and top 3 least claimed insurance plans.
The query is expected to return the insurance plan name, the insurance company name which has that plan,
 and whether the plan is the most claimed or least claimed. */
 
 with cte_plans_claimed as(
 select 
       ip.planName,
       ic.companyName,
       count(c.claimID) as total_claims,
       dense_rank() over(order by count(c.claimID) desc) as most_claimed_ranks,
       dense_rank() over(order by count(c.claimID) ) as least_claimed_ranks
from treatment t 
     inner join claim c using(claimID)
     inner join insuranceplan ip using(UIN)
     inner join insurancecompany ic using(companyID)
group by 
         ip.planName,
         ic.companyName)
select planName,
       companyName,
       total_claims,
       case 
           when most_claimed_ranks<=3 then "most_claimed" 
           when least_claimed_ranks<=3 then "least_claimed"
		end as claim_status
from cte_plans_claimed
where most_claimed_ranks<=3
      or least_claimed_ranks<=3
order by total_claims desc;

/*Problem Statement 4: 
The healthcare department wants to know which category of patients is being affected the most by each disease.
Assist the department in creating a report regarding this.
Provided the healthcare department has categorized the patients into the following category.
YoungMale: Born on or after 1st Jan  2005  and gender male.
YoungFemale: Born on or after 1st Jan  2005  and gender female.
AdultMale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender male.
AdultFemale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender female.
MidAgeMale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender male.
MidAgeFemale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender female.
ElderMale: Born before 1st Jan 1970, and gender male.
ElderFemale: Born before 1st Jan 1970, and gender female.*/

with cte_disease_age as(
select d.diseaseName,
        pt.patientID,
        case 
          when pt.dob<'1970-01-01' and p.gender='male' then 'ElderMale'
          when pt.dob<'1970-01-01' and p.gender='female' then 'ElderFemale'
          when pt.dob<'1985-01-01' and p.gender='male' then 'MidAgeMale'
          when pt.dob<'1985-01-01' and p.gender='female' then 'MidAgeFemale'
		  when pt.dob<'2005-01-01' and p.gender='male' then 'AdultMale'
          when pt.dob<'2005-01-01' and p.gender='female' then 'AdultFemale'
          when pt.dob>='2005-01-01' and p.gender='male' then 'YoungMale'
          when pt.dob>='2005-01-01' and p.gender='female' then 'YoungFemale'
          end as category
from person p
	inner join  patient pt on p.personID=pt.patientID
    inner join treatment t on t.patientID=pt.patientID
    inner join disease d on d.diseaseID=t.diseaseID),
    
cte_disease_age_ranks as(
select diseaseName,
		category,
        count(patientID) as patients_cnt,
        rank() over(partition by diseaseName order by count(patientID) desc) as r
from cte_disease_age
group by diseaseName,
		 category)
select diseaseName,
       category as most_affected_category,
       patients_cnt
from cte_disease_age_ranks where r=1;

/*Problem Statement 5:  
Anna wants a report on the pricing of the medicine. She wants a list of the most expensive and most affordable medicines only. 
Assist anna by creating a report of all the medicines which are pricey and affordable, listing the 
companyName, productName, description, maxPrice, and the price category of each. Sort the list in descending order of the maxPrice.
Note: A medicine is considered to be “pricey” if the max price exceeds 1000 and “affordable” if the price is under 5. 
Write a query to find */

use sql_project;
select * from (
select m.companyName,
	   m.productName,
       m.description,
	   m.maxPrice,
       case when m.maxPrice>1000 then "pricey" 
            when m.maxPrice<5 then "affordable"
		end as price_category
from medicine m) t 
where t.price_category is not null;
         

       

         

     


         



