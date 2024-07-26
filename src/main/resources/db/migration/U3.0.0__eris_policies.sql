/*
2022-02-10: KD
- initial version
*/

DROP VIEW IF EXISTS ${deployment_schema}.veris_test_summary;

DROP VIEW IF EXISTS ${deployment_schema}.veris_test_details;

DROP TABLE IF EXISTS ${deployment_schema}.vmeris_policies	;
CREATE TABLE ${deployment_schema}.vmeris_policies	
(	
report_year INTEGER ENCODE az64,	
report_quarter INTEGER ENCODE az64,	
policynumber VARCHAR(50) ENCODE lzo,	
policy_id INTEGER NOT NULL ENCODE lzo DISTKEY,	
policy_uniqueid VARCHAR(100) ENCODE lzo,	
riskcd VARCHAR(12) ENCODE lzo,	
policyversion VARCHAR(10) ENCODE lzo,	
effectivedate DATE ENCODE az64,	
expirationdate DATE ENCODE az64,	
renewaltermcd VARCHAR(255) ENCODE lzo,	
policyneworrenewal VARCHAR(10) ENCODE lzo,	
policystate VARCHAR(50) ENCODE lzo,	
companynumber VARCHAR(50) ENCODE lzo,	
company VARCHAR(100) ENCODE lzo,	
lob VARCHAR(3) ENCODE lzo,	
asl VARCHAR(5) ENCODE lzo,	
lob2 VARCHAR(3) ENCODE lzo,	
lob3 VARCHAR(3) ENCODE lzo,	
product VARCHAR(2) ENCODE lzo,	
policyformcode VARCHAR(255) ENCODE lzo,	
programind VARCHAR(6) ENCODE lzo,	
producer_status VARCHAR(10) ENCODE lzo,	
coveragetype VARCHAR(4) ENCODE lzo,	
coverage VARCHAR(5) ENCODE lzo,	
feeind VARCHAR(1) ENCODE lzo,	
source VARCHAR(5) ENCODE lzo,	
wp NUMERIC(38, 2) ENCODE az64,	
ep NUMERIC(38, 2) ENCODE az64,	
clep DOUBLE PRECISION,	
ee NUMERIC(38, 3) ENCODE az64,	
loaddate DATE NOT NULL ENCODE runlength	
)	
SORTKEY	
(	
report_year,report_quarter	
);	
	
comment on table ${deployment_schema}.vmERIS_Policies is 'ERIS Premiums detail level. Business Owner: Pierre-Antoine Espagnet <pespagnet@cseinsurance.com>';	
	
comment on column ${deployment_schema}.vmeris_policies.report_year	 is 'Based on policy transaction accounting date';
comment on column ${deployment_schema}.vmeris_policies.report_quarter	 is 'Based on policy transaction accounting date';
comment on column ${deployment_schema}.vmeris_policies.lob	 is 'See Configuration in ERIS Tables Design document';
comment on column ${deployment_schema}.vmeris_policies.lob2	 is 'See Configuration in ERIS Tables Design document';
comment on column ${deployment_schema}.vmeris_policies.lob3	 is 'See Configuration in ERIS Tables Design document';
comment on column ${deployment_schema}.vmeris_policies.product	 is 'See Configuration in ERIS Tables Design document';
comment on column ${deployment_schema}.vmeris_policies.programind	 is 'See Configuration in ERIS Tables Design document';
comment on column ${deployment_schema}.vmeris_policies.coveragetype	 is 'See Configuration in ERIS Tables Design document';
comment on column ${deployment_schema}.vmeris_policies.coverage	 is 'See Configuration in ERIS Tables Design document';
comment on column ${deployment_schema}.vmeris_policies.wp	 is 'Written Premium';
comment on column ${deployment_schema}.vmeris_policies.ep	 is 'Earned Premium';
comment on column ${deployment_schema}.vmeris_policies.clep	 is 'Current Level Earned Premium: Earned premium adjusted using all rate changes starting after policy term effecyive date, based on company,  state, policyformcode,  new or renewal policy. ';


CREATE OR REPLACE PROCEDURE ${deployment_schema}.sp_eris_policies(pLoadDate datetime) 
AS $$
BEGIN
/*
2022-02-10: KD
- initial version
2022-03-15: KD
- fix in Auto policy scope in dim_policy_extended
*/
/*full load takes 3 min*/
/*dim_policy_extension is a combination of dim_policy with dim_policyextension
with additional calculated fields (LOB) 
plus rate changes coefficients which are applied based on effective date and coverages
There are more lines per policy then just one in dim_policy
It depends on ERIS coverages*/
/*Because there is no regular aggregation function for multiplicateion 
- EXP(SUM(of lograthim LN)) is used*/
create temporary table dim_policy_extended as 
select 
p.policy_id,
p.pol_policynumber,
p.pol_uniqueid,
p.pol_policynumbersuffix,
p.pol_effectivedate,
p.pol_expirationdate,
p.pol_masterstate,
case 
when upper(substring(p.pol_policynumber,3,1))='A' then 'AU'
when upper(substring(p.pol_policynumber,3,1))='B' then 'OTH'
when upper(substring(p.pol_policynumber,3,1))='E' then 'OTH'
when upper(substring(p.pol_policynumber,3,1))='F' then 'DF'
when upper(substring(p.pol_policynumber,3,1))='H' then 'HO'
when upper(substring(p.pol_policynumber,3,1))='M' then 'OTH'
when upper(substring(p.pol_policynumber,3,1))='Q' then 'OTH'
when upper(substring(p.pol_policynumber,3,1))='R' then 'AU'
when upper(substring(p.pol_policynumber,3,1))='U' then 'OTH'
end LOB,
isnull(r.coverage,'All') coverage,
isnull(EXP(SUM(LN(cast((1+r.renewal_change/100) as float)))),1) renewal_change,
isnull(EXP(SUM(LN(cast((1+r.nb_change/100) as float)))),1) nb_change
from fsbi_dw_spinn.dim_policy p
join fsbi_dw_spinn.dim_policyextension pe 
on p.policy_id=pe.policy_id
join fsbi_dw_spinn.vdim_company co
on p.company_id=co.company_id
left outer join reporting.eris_ratechange r
on  r.startdt>pol_effectivedate
and r.carriercd=co.comp_name1
and r.formcd=pe.PolicyFormCode
and r.statecd=p.pol_masterstate
where upper(substring(p.pol_policynumber,3,1)) in ('A',
'B',
'E',
'F',
'H',
'M',
'Q',
'R',
'U' )
group by
p.policy_id,
p.pol_policynumber,
p.pol_uniqueid,
p.pol_policynumbersuffix,
p.pol_effectivedate,
p.pol_expirationdate,
p.pol_masterstate,
case 
when upper(substring(p.pol_policynumber,3,1))='A' then 'AU'
when upper(substring(p.pol_policynumber,3,1))='B' then 'OTH'
when upper(substring(p.pol_policynumber,3,1))='E' then 'OTH'
when upper(substring(p.pol_policynumber,3,1))='F' then 'DF'
when upper(substring(p.pol_policynumber,3,1))='H' then 'HO'
when upper(substring(p.pol_policynumber,3,1))='M' then 'OTH'
when upper(substring(p.pol_policynumber,3,1))='Q' then 'OTH'
when upper(substring(p.pol_policynumber,3,1))='R' then 'AU'
when upper(substring(p.pol_policynumber,3,1))='U' then 'OTH'
end,
isnull(r.coverage,'All');

/*main part*/
truncate table ${deployment_schema}.vmERIS_Policies;
insert into ${deployment_schema}.vmERIS_Policies 
select
m.mon_year report_year,
m.mon_quarter report_quarter,
p.pol_policynumber Policynumber,
p.policy_id,
p.pol_uniqueid policy_uniqueid,
lpad(cr.cvrsk_number,3,'0') RiskCd,
p.pol_policynumbersuffix PolicyVersion,
p.pol_effectivedate effectivedate,
p.pol_expirationdate expirationdate,
pe.RenewalTermCd,
f.policyneworrenewal,
p.pol_masterstate PolicyState,
co.comp_number CompanyNumber,
co.comp_name1 Company,
p.LOB,
c.cov_asl ASL,
case
when c.cov_asl='010' then 'SP'
when c.cov_asl='021' then 'SP'
when c.cov_asl='040' then 'HO'
when c.cov_asl='090' then 'SP'
when c.cov_asl='120' then 'SP'
when c.cov_asl='160' then 'HO'
when c.cov_asl='170' then 'SP'
when c.cov_asl='191' then 'AL'
when c.cov_asl='192' then 'AL'
when c.cov_asl='211' then 'APD'
when c.cov_asl='220' then 'AC'
end LOB2,
case
when c.cov_asl='010' then 'DF'
when c.cov_asl='021' then 'DF'
when c.cov_asl='040' then 'HO'
when c.cov_asl='090' then 'OTH'
when c.cov_asl='120' then 'OTH'
when c.cov_asl='160' then 'HO'
when c.cov_asl='170' then 'DF'
when c.cov_asl='191' then 'AL'
when c.cov_asl='192' then 'AL'
when c.cov_asl='211' then 'APD'
when c.cov_asl='220' then 'APD'
end LOB3,
case
when upper(substring(p.pol_policynumber,3,1))='A' then 'AU'
when upper(substring(p.pol_policynumber,3,1))='B' then 'BO'
when upper(substring(p.pol_policynumber,3,1))='E' then 'EQ'
when upper(substring(p.pol_policynumber,3,1))='F' then 'DF'
when upper(substring(p.pol_policynumber,3,1))='H' then 'HO'
when upper(substring(p.pol_policynumber,3,1))='M' then 'MH'
when upper(substring(p.pol_policynumber,3,1))='Q' then 'EQ'
when upper(substring(p.pol_policynumber,3,1))='R' then 'AU'
when upper(substring(p.pol_policynumber,3,1))='U' then 'PU'
end Product,
pe.PolicyFormCode,
case 
when co.comp_number in ('0019') then 'Select'
when pe.ProgramInd='Non-Civil Servant' then 'NC'
when pe.ProgramInd='Civil Servant' then 'CS'
when pe.ProgramInd='Affinity Group' then 'AG'
when pe.ProgramInd='Educator' then 'ED'
when pe.ProgramInd='Firefighter' then 'FF'
when pe.ProgramInd='Law Enforcement' then 'LE'
else p.LOB
end ProgramInd,
pr.producer_status,
case
when c.cov_asl='010' then 'PROP'
when c.cov_asl='021' then 'PROP'
when c.cov_asl='040' then 'PROP'
when c.cov_asl='090' then 'PROP'
when c.cov_asl='120' then 'PROP'
when c.cov_asl='160' then 'LIAB'
when c.cov_asl='170' then 'LIAB'
when c.cov_asl='191' then 'LIAB'
when c.cov_asl='192' then 'LIAB'
when c.cov_asl='211' then 'PROP'
when c.cov_asl='220' then 'PROP'
end CoverageType,
case when ce.codetype='Fee' then 'Fee' 
else 
 case
  when substring(p.pol_policynumber,3,1)='A' then isnull(ce.Act_ERIS,'OTH')
  when substring(p.pol_policynumber,3,1) in ('F','H') then
   case
    when pe.PolicyFormCode='DF1' then '03'
    when pe.PolicyFormCode='DF3' then '03'
    when pe.PolicyFormCode='DF6' then '06'
    when pe.PolicyFormCode='FL1-Basic' then '03'
    when pe.PolicyFormCode='FL1-Vacant' then '03'
    when pe.PolicyFormCode='FL2-Broad' then '03'
    when pe.PolicyFormCode='FL3-Special' then '03'
    when pe.PolicyFormCode='Form3' then '03'
    when pe.PolicyFormCode='HO3' then '03'
    when pe.PolicyFormCode='HO4' then '04'
    when pe.PolicyFormCode='HO6' then '06'
    when pe.PolicyFormCode='PA' then 'OTH'
   end
  else 'OTH'
 end
end Coverage,
case when ce.codetype='Fee' then 'Y' else 'N' end FeeInd,
'SPINN' Source,
sum(wrtn_prem_amt + fees_amt) WP,
sum(earned_prem_amt) EP,
sum(case
 when f.policyneworrenewal='New' then p.nb_change*earned_prem_amt
 else p.renewal_change*earned_prem_amt
end) CLEP,
sum(
case
 when c.cov_code in ('F.30005B','F.31580A') then round(ee_rm/12,3) /*Umbrella*/
 when pe.PolicyFormCode='PB' and ce.covx_code in ('CovA','CovC') then round(ee_rm/12,3) /*Boatowners - boats - CovA and Trailers covC*/
 when pe.PolicyFormCode='EQ' and ce.covx_code in ('CovA','CovC') then round(ee_rm/12,3) /*In Earthquake policies if there are both CovA and CovC, then CovC do not have exposures*/
 when pe.PolicyFormCode in ('DF6','DF1', 'DF3', 'FL1-Basic', 'FL1-Vacant', 'FL2-Broad', 'FL3-Special', 'Form3', 'HO3' ) and (c.cov_subline in ('410','402') and ce.covx_code='CovA') then round(ee_rm/12,3)
 when pe.PolicyFormCode in ('HO4', 'HO6') and ce.covx_code='CovC' then round(ee_rm/12,3)
 when substring(p.pol_policynumber,3,1)='A' and  (ce.covx_code in ('BI', 'COMP', 'COLL','MEDPAY', 'PD','RREIM', 'ROAD', 'UM','UMBI', 'UMPD' ) or isnull(ce.Act_ERIS,'OTH')='OTH') then round(ee_rm/12,3)
else 0
end
)  EE,
pLoadDate LoadDate
from fsbi_dw_spinn.fact_policycoverage f
join fsbi_dw_spinn.dim_policyextension pe
on f.policy_id=pe.policy_id
join fsbi_dw_spinn.vdim_company co
on f.company_id=co.company_id
join fsbi_dw_spinn.dim_coverage c
on f.coverage_id=c.coverage_id
left outer join public.dim_coverageextension ce
on c.coverage_id=ce.coverage_id
join dim_policy_extended p
on f.policy_id=p.policy_id
and (isnull(ce.Act_ERIS,'OTH')=p.coverage or p.coverage='All')
join fsbi_dw_spinn.vdim_producer pr
on f.producer_id=pr.producer_id
join fsbi_dw_spinn.dim_month m
on f.month_id=m.month_id
join fsbi_dw_spinn.dim_coveredrisk cr
on f.primaryrisk_id=cr.coveredrisk_id
/*Only "meaningfull" coverages from ratin. The results of this join will help to filter out duplicates */
left outer join dim_policy_extended r
on f.policy_id=r.policy_id
and isnull(ce.Act_ERIS,'OTH')=r.coverage
where m.mon_year>cast(to_char(GetDate(),'yyyy') as int) - 10
/*keep coverages only once*/
and not (p.coverage='All' and isnull(ce.Act_ERIS,'OTH')=isnull(r.coverage,'N/A'))
group by
m.mon_year,
m.mon_quarter,
p.pol_policynumber,
p.policy_id,
p.pol_uniqueid,
lpad(cr.cvrsk_number,3,'0'),
p.pol_policynumbersuffix,
p.pol_effectivedate,
p.pol_expirationdate,
pe.RenewalTermCd,
f.policyneworrenewal,
p.pol_masterstate,
co.comp_number,
co.comp_name1,
p.LOB ,
c.cov_asl,
case
when c.cov_asl='010' then 'SP'
when c.cov_asl='021' then 'SP'
when c.cov_asl='040' then 'HO'
when c.cov_asl='090' then 'SP'
when c.cov_asl='120' then 'SP'
when c.cov_asl='160' then 'HO'
when c.cov_asl='170' then 'SP'
when c.cov_asl='191' then 'AL'
when c.cov_asl='192' then 'AL'
when c.cov_asl='211' then 'APD'
when c.cov_asl='220' then 'AC'
end,
case
when c.cov_asl='010' then 'DF'
when c.cov_asl='021' then 'DF'
when c.cov_asl='040' then 'HO'
when c.cov_asl='090' then 'OTH'
when c.cov_asl='120' then 'OTH'
when c.cov_asl='160' then 'HO'
when c.cov_asl='170' then 'DF'
when c.cov_asl='191' then 'AL'
when c.cov_asl='192' then 'AL'
when c.cov_asl='211' then 'APD'
when c.cov_asl='220' then 'APD'
end,
case
when upper(substring(p.pol_policynumber,3,1))='A' then 'AU'
when upper(substring(p.pol_policynumber,3,1))='B' then 'BO'
when upper(substring(p.pol_policynumber,3,1))='E' then 'EQ'
when upper(substring(p.pol_policynumber,3,1))='F' then 'DF'
when upper(substring(p.pol_policynumber,3,1))='H' then 'HO'
when upper(substring(p.pol_policynumber,3,1))='M' then 'MH'
when upper(substring(p.pol_policynumber,3,1))='Q' then 'EQ'
when upper(substring(p.pol_policynumber,3,1))='R' then 'AU'
when upper(substring(p.pol_policynumber,3,1))='U' then 'PU'
end,
pe.PolicyFormCode,
case 
when co.comp_number in ('0019') then 'Select'
when pe.ProgramInd='Non-Civil Servant' then 'NC'
when pe.ProgramInd='Civil Servant' then 'CS'
when pe.ProgramInd='Affinity Group' then 'AG'
when pe.ProgramInd='Educator' then 'ED'
when pe.ProgramInd='Firefighter' then 'FF'
when pe.ProgramInd='Law Enforcement' then 'LE'
else p.LOB
end,
pr.producer_status,
case
when c.cov_asl='010' then 'PROP'
when c.cov_asl='021' then 'PROP'
when c.cov_asl='040' then 'PROP'
when c.cov_asl='090' then 'PROP'
when c.cov_asl='120' then 'PROP'
when c.cov_asl='160' then 'LIAB'
when c.cov_asl='170' then 'LIAB'
when c.cov_asl='191' then 'LIAB'
when c.cov_asl='192' then 'LIAB'
when c.cov_asl='211' then 'PROP'
when c.cov_asl='220' then 'PROP'
end,
case when ce.codetype='Fee' then 'Fee' 
else 
 case
  when substring(p.pol_policynumber,3,1)='A' then isnull(ce.Act_ERIS,'OTH')
  when substring(p.pol_policynumber,3,1) in ('F','H') then
   case
    when pe.PolicyFormCode='DF1' then '03'
    when pe.PolicyFormCode='DF3' then '03'
    when pe.PolicyFormCode='DF6' then '06'
    when pe.PolicyFormCode='FL1-Basic' then '03'
    when pe.PolicyFormCode='FL1-Vacant' then '03'
    when pe.PolicyFormCode='FL2-Broad' then '03'
    when pe.PolicyFormCode='FL3-Special' then '03'
    when pe.PolicyFormCode='Form3' then '03'
    when pe.PolicyFormCode='HO3' then '03'
    when pe.PolicyFormCode='HO4' then '04'
    when pe.PolicyFormCode='HO6' then '06'
    when pe.PolicyFormCode='PA' then 'OTH'
   end
  else 'OTH'
 end
end ,
case when ce.codetype='Fee' then 'Y' else 'N' end
having sum(wrtn_prem_amt + fees_amt)<>0 or sum(earned_prem_amt)<>0 or sum(ee_rm)<>0
order by report_year, report_quarter;

END;
$$ LANGUAGE plpgsql;

create or replace view ${deployment_schema}.veris_test_details as 
with test_data as (
select policy_id,							
sum(wp) wp,				
sum(ep) ep			
from ${deployment_schema}.vmERIS_Policies				
where substring(policynumber,3,1)='A'			
group by 				
policy_id						
)
, prod_data as (
select
f.policy_id,
sum(wrtn_prem_amt) wp,				
sum(earned_prem_amt) ep
from fsbi_dw_spinn.fact_policycoverage f
join fsbi_dw_spinn.dim_month m
on f.month_id=m.month_id
join fsbi_dw_spinn.dim_policy p
on f.policy_id=p.policy_id
where substring(p.pol_policynumber,3,1)='A'
and m.mon_year>cast(to_char(GetDate(),'yyyy') as int) - 10
group by f.policy_id
)
select
t.policy_id,
t.wp wp_test,
p.wp wp_prod,
t.ep ep_test,
p.ep ep_prod,
case when p.wp!=0 then 100*abs(p.wp - t.wp)/p.wp when p.wp != t.wp then 100 else 0 end wp_p_diff,
case when p.ep!=0 then 100*abs(p.ep - t.ep)/p.ep when p.ep != t.ep then 100 else 0 end  ep_p_diff,
case when wp_p_diff>5 or ep_p_diff>5 then 1 else 0 end IsDiff
from test_data t
join prod_data p
on t.policy_id = p.policy_id;



create or replace view ${deployment_schema}.veris_test_summary as
select
sum(IsDiff) CntDiff,
count(*) Total,
100*CntDiff/Total pDiff
from ${deployment_schema}.veris_test_details;

--call ${deployment_schema}.sp_eris_policies(getDate());