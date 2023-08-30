with cte as(
 select ip.planName,
		ip.uin,
		d.diseaseName,
        d.diseaseID,
        t.claimID
from disease d
      inner join treatment t on d.diseaseID=t.diseaseID
      inner join claim c on t.claimID=c.claimID
      inner join insuranceplan ip on c.uin=ip.uin
      inner join insurancecompany ic on ip.companyID=ic.companyID
      where ic.companyID=1839
 ),
cte_total_claims as(
 select uin,
		planName,
        count(claimID) as total_claims
from cte
group by uin,planName 
),
cte_most_claimed_disease as 
(
   select t.uin,t.diseaseName from(
                              select uin,planName,diseaseName,
									count(claimID) as total_claims,
									dense_rank() over(partition by planName order by count(claimID) desc) as r
							 from cte
                             group by uin,
                                     planName,
                                     diseaseName) t where t.r=1
)
select c1.planName,
       c1.total_claims,
       c2.diseaseName as most_claimed_disease
from cte_total_claims c1
inner join cte_most_claimed_disease c2 on c1.uin=c2.uin;