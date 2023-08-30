/*Problem Statement 1: 
“HealthDirect” pharmacy finds it difficult to deal with the product type of medicine being displayed
in numerical form, they want the product type in words. Also, they want to filter the medicines based on tax criteria. 
Display only the medicines of product categories 1, 2, and 3 for medicines that come under tax category I and medicines of 
product categories 4, 5, and 6 for medicines that come under tax category II.
Write a SQL query to solve this problem.
ProductType numerical form and ProductType in words are given by
1 - Generic, 
2 - Patent, 
3 - Reference, 
4 - Similar, 
5 - New, 
6 - Specific,
7 - Biological, 
8 – Dinamized*/

with cte as(
select  *,
 case
 when productType=1 then 'Generic'
 when productType=2 then 'Patent'
 when productType=3 then 'Reference'
 when productType=4 then 'Similar'
 when productType=5 then 'New'
 when productType=6 then 'Specific'
 when productType=7 then 'Dinamized' end as 'productType_expanded'
 from medicine)
 select medicineID,
	companyName, 
    productName, description, substanceName, 
    productType,productType_expanded,
    taxCriteria, hospitalExclusive, governmentDiscount, taxImunity, maxPrice
 from cte 
 inner  join keep k using(medicineID)
 inner join pharmacy ph using(pharmacyID)
 where  ph.pharmacyName='HealthDirect' and 
 ((taxCriteria='I' and productType in(1,2,3)) or 
 (taxCriteria='II' and productType in(4,5,6)));


/*Problem Statement 2:  
'Ally Scripts' pharmacy company wants to find out the quantity of medicine prescribed in each of its prescriptions.
Write a query that finds the sum of the quantity of all the medicines in a prescription 
and if the total quantity of medicine is less than 20 tag it as “low quantity”. 
If the quantity of medicine is from 20 to 49 (both numbers including) tag it as “medium quantity“ and 
if the quantity is more than equal to 50 then tag it as “high quantity”.
Show the prescription Id, the Total Quantity of all the medicines in that prescription, 
and the Quantity tag for all the prescriptions issued by 'Ally Scripts'. */

select  prescriptionID,
	    sum(quantity) as total_quantity,
        case when sum(quantity)<20 then "low quantity"
             when sum(quantity)<49 then "medium quantity"
             else "high quantity" 
		end as tag
from prescription p
inner join contain c using(prescriptionID)
inner join pharmacy ph using(pharmacyID)
where pharmacyName='Ally Scripts'
group by prescriptionID ;
 
 
/*Problem Statement 3: 
In the Inventory of a pharmacy 'Spot Rx' the quantity of medicine is considered ‘HIGH QUANTITY’ 
when the quantity exceeds 7500 and ‘LOW QUANTITY’ when the quantity falls short of 1000. 
The discount is considered “HIGH” if the discount rate on a product is 30% or higher,
 and the discount is considered “NONE” when the discount rate on a product is 0%.
 'Spot Rx' needs to find all the Low quantity products with high discounts and all the high-quantity products with no discount so they can adjust the discount rate according to the demand. 
Write a query for the pharmacy listing all the necessary details relevant to the given requirement.

Hint: Inventory is reflected in the Keep table.*/

 with cte as(
select ph.pharmacyName,
       m.productName,
       k.quantity,
       k.discount,
	  case when quantity<1000 then "LOW QUANTITY"
	       when quantity>7000 then "HIGH QUANTITY"
           end as quantity_tag ,
		
      case when discount=0 then "NONE"
           when discount>=30 then "HIGH"
	  end as discount_tag
from pharmacy ph
inner join keep k using(pharmacyID)
inner join medicine m using(medicineID))
select * 
from cte 
where pharmacyName='Spot Rx'
      and ((quantity_tag="LOW QUANTITY" and discount_tag="HIGH")
            or (quantity_tag="HIGH QUANTITY" and discount_tag="NONE"));
            
/*Problem Statement 4: 
Mack, From HealthDirect Pharmacy, wants to get a list of all the affordable and costly, 
hospital-exclusive medicines in the database. Where affordable medicines are the medicines that have a maximum price 
of less than 50% of the avg maximum price of all the medicines in the database, and costly medicines are the medicines
 that have a maximum price of more than double the avg maximum price of all the medicines in the database. 
 Mack wants clear text next to each medicine name to be displayed that identifies the medicine as affordable or costly.
 The medicines that do not fall under either of the two categories need not be displayed.*/
 
 select * from(
 select m.productName,
        m.maxPrice,
        case when maxPrice<(select 0.5*avg(maxPrice) from medicine) then "Affordable"
             when maxPrice>(select 2*avg(maxPrice) from medicine) then "Costly"
		end as price_tag
 from pharmacy ph 
 inner join keep k using(pharmacyID)
 inner join medicine m using(medicineID)
 where pharmacyName='HealthDirect' and hospitalExclusive='S' ) t where price_tag is not null;
 
 
/* Problem Statement 5:  
The healthcare department wants to categorize the patients into the following category.
YoungMale: Born on or after 1st Jan  2005  and gender male.
YoungFemale: Born on or after 1st Jan  2005  and gender female.
AdultMale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender male.
AdultFemale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender female.
MidAgeMale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender male.
MidAgeFemale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender female.
ElderMale: Born before 1st Jan 1970, and gender male.
ElderFemale: Born before 1st Jan 1970, and gender female.


Write a SQL query to list all the patient name, gender, dob, and their category.*/

select  personName as patientName,
        p.gender,
        pt.dob,
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
inner join  patient pt on p.personID=pt.patientID;



 
