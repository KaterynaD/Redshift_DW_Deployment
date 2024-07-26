create schema IF NOT EXISTS reporting;
create schema IF NOT EXISTS reporting_test;
create schema IF NOT EXISTS fsbi_dw_spinn;

CREATE TABLE IF NOT EXISTS fsbi_dw_spinn.dim_month
(
	month_id INTEGER NOT NULL  ENCODE RAW
	,mon_monthname VARCHAR(25)   ENCODE text255
	,mon_monthabbr VARCHAR(4)   ENCODE text255
	,mon_reportperiod VARCHAR(6)   ENCODE lzo
	,mon_monthinquarter INTEGER   ENCODE lzo
	,mon_monthinyear INTEGER   ENCODE lzo
	,mon_year INTEGER   ENCODE lzo
	,mon_quarter INTEGER   ENCODE lzo
	,mon_startdate DATE   ENCODE lzo
	,mon_enddate DATE   ENCODE lzo
	,mon_sequence INTEGER   ENCODE lzo
	,mon_isodate VARCHAR(8)   ENCODE lzo
	,loaddate DATE   ENCODE lzo
	,PRIMARY KEY (month_id)
)
DISTSTYLE AUTO
 SORTKEY (
	month_id
	)
;

COMMENT ON TABLE fsbi_dw_spinn.dim_month IS 'DW Table type:	Dimension Type 1 (Dictionary)	Table description:	For backward compatibility only, not needed in new projects, all foreign keys (date fields) are integers in format YYYYMM';

CREATE TABLE IF NOT EXISTS fsbi_dw_spinn.dim_policy
(
	policy_id INTEGER NOT NULL  ENCODE delta
	,pol_policynumber VARCHAR(50)   ENCODE lzo
	,pol_policynumbersuffix VARCHAR(10)   ENCODE bytedict
	,pol_masterstate VARCHAR(50)   ENCODE bytedict
	,pol_mastercountry VARCHAR(50)   ENCODE lzo
	,pol_uniqueid VARCHAR(100)   ENCODE lzo
	,company_id INTEGER   ENCODE delta
	,pol_effectivedate DATE   ENCODE lzo
	,pol_expirationdate DATE   ENCODE lzo
	,source_system VARCHAR(100)   ENCODE lzo
	,loaddate DATE   ENCODE lzo
	,PRIMARY KEY (policy_id)
)
DISTSTYLE AUTO
 DISTKEY (policy_id)
 SORTKEY (
	policy_id
	)
;

COMMENT ON TABLE fsbi_dw_spinn.dim_policy IS ' 	Source: 	BasicPolicy	DW Table type:	Dimension Type 1	Table description:	PolicyNumber, Version (pol_policynumbersuffix), State See dim_policyextension for more details';

-- Column comments

COMMENT ON COLUMN fsbi_dw_spinn.dim_policy.pol_policynumber IS 'Policy number. The first 2 characters is a state abbrevation. The 3rd character defines the line of business: A for Auto, H for homeowners, F for Dwelling etc';
COMMENT ON COLUMN fsbi_dw_spinn.dim_policy.pol_policynumbersuffix IS 'Policy term version';
COMMENT ON COLUMN fsbi_dw_spinn.dim_policy.pol_masterstate IS 'PolicyNumber first 2 character';
COMMENT ON COLUMN fsbi_dw_spinn.dim_policy.pol_uniqueid IS 'Policy Term unique identifier in SPINN also known as PolicyRef in PolicyStats and some other table or SystemId and cmmContainer=''Policy''. It''s teh same as Policy_Uniqueid in all other tables in Redshift DW';

CREATE TABLE IF NOT EXISTS fsbi_dw_spinn.fact_policycoverage
(
	factpolicycoverage_id BIGINT NOT NULL  ENCODE az64
	,month_id INTEGER NOT NULL  ENCODE zstd
	,producer_id INTEGER NOT NULL  ENCODE zstd
	,product_id INTEGER NOT NULL  ENCODE zstd
	,company_id INTEGER NOT NULL  ENCODE zstd
	,firstinsured_id INTEGER NOT NULL  ENCODE az64
	,policy_id INTEGER NOT NULL  ENCODE az64
	,policyextension_id INTEGER NOT NULL  ENCODE az64
	,policyeffectivedate_id INTEGER NOT NULL  ENCODE zstd
	,policyexpirationdate_id INTEGER NOT NULL  ENCODE zstd
	,policystatus_id INTEGER NOT NULL  ENCODE zstd
	,coverage_id INTEGER NOT NULL  ENCODE zstd
	,coverageextension_id INTEGER NOT NULL  ENCODE az64
	,coverageeffectivedate_id INTEGER NOT NULL  ENCODE zstd
	,coverageexpirationdate_id INTEGER NOT NULL  ENCODE zstd
	,policymasterterritory_id INTEGER NOT NULL  ENCODE zstd
	,primaryriskterritory_id INTEGER NOT NULL  ENCODE zstd
	,limit_id INTEGER NOT NULL  ENCODE zstd
	,deductible_id INTEGER NOT NULL  ENCODE zstd
	,class_id INTEGER NOT NULL  ENCODE zstd
	,primaryrisk_id INTEGER NOT NULL  ENCODE zstd
	,primaryriskextension_id INTEGER NOT NULL  ENCODE az64
	,primaryriskgeography_id INTEGER NOT NULL  ENCODE zstd
	,primaryriskaddress_id INTEGER NOT NULL  ENCODE zstd
	,vehicle_id INTEGER NOT NULL  ENCODE zstd
	,driver_id INTEGER NOT NULL  ENCODE zstd
	,building_id INTEGER NOT NULL  ENCODE zstd
	,location_id INTEGER NOT NULL  ENCODE az64
	,month_vehicle_id INTEGER NOT NULL  ENCODE zstd
	,month_driver_id INTEGER NOT NULL  ENCODE zstd
	,month_building_id INTEGER NOT NULL  ENCODE zstd
	,month_location_id INTEGER NOT NULL  ENCODE az64
	,policyneworrenewal VARCHAR(10) NOT NULL  ENCODE zstd
	,coverage_deletedindicator VARCHAR(1) NOT NULL  ENCODE zstd
	,risk_deletedindicator VARCHAR(1) NOT NULL  ENCODE zstd
	,policy_uniqueid VARCHAR(100) NOT NULL  ENCODE zstd
	,coverage_uniqueid VARCHAR(100)   ENCODE zstd
	,insuredage INTEGER NOT NULL  ENCODE zstd
	,policynewissuedind INTEGER NOT NULL  ENCODE zstd
	,policyneweffectiveind INTEGER NOT NULL  ENCODE az64
	,policyrenewedissuedind INTEGER NOT NULL  ENCODE zstd
	,policyrenewedeffectiveind INTEGER NOT NULL  ENCODE az64
	,policyexpiredeffectiveind INTEGER NOT NULL  ENCODE zstd
	,policycancelledissuedind INTEGER NOT NULL  ENCODE zstd
	,policycancelledeffectiveind INTEGER NOT NULL  ENCODE zstd
	,policynonrenewalissuedind INTEGER NOT NULL  ENCODE az64
	,policynonrenewaleffectiveind INTEGER NOT NULL  ENCODE az64
	,policyendorsementissuedind INTEGER NOT NULL  ENCODE zstd
	,policyendorsementeffectiveind INTEGER NOT NULL  ENCODE az64
	,exposureamount1 VARCHAR(25) NOT NULL  ENCODE zstd
	,exposureamount2 VARCHAR(25) NOT NULL  ENCODE zstd
	,exposureamount3 VARCHAR(25) NOT NULL  ENCODE zstd
	,exposureamount4 VARCHAR(25) NOT NULL  ENCODE zstd
	,exposureamount5 VARCHAR(25) NOT NULL  ENCODE zstd
	,comm_amt NUMERIC(13,2) NOT NULL  ENCODE zstd
	,comm_amt_ytd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,comm_amt_itd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,wrtn_prem_amt NUMERIC(13,2) NOT NULL  ENCODE zstd
	,wrtn_prem_amt_ytd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,wrtn_prem_amt_itd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,gross_wrtn_prem_amt NUMERIC(13,2) NOT NULL  ENCODE zstd
	,gross_wrtn_prem_amt_ytd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,gross_wrtn_prem_amt_itd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,man_wrtn_prem_amt NUMERIC(13,2) NOT NULL  ENCODE az64
	,man_wrtn_prem_amt_ytd NUMERIC(13,2) NOT NULL  ENCODE az64
	,man_wrtn_prem_amt_itd NUMERIC(13,2) NOT NULL  ENCODE az64
	,orig_wrtn_prem_amt NUMERIC(13,2) NOT NULL  ENCODE az64
	,orig_wrtn_prem_amt_ytd NUMERIC(13,2) NOT NULL  ENCODE az64
	,orig_wrtn_prem_amt_itd NUMERIC(13,2) NOT NULL  ENCODE az64
	,term_prem_amt NUMERIC(13,2) NOT NULL  ENCODE zstd
	,term_prem_amt_ytd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,term_prem_amt_itd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,earned_prem_amt NUMERIC(13,2) NOT NULL  ENCODE zstd
	,earned_prem_amt_ytd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,earned_prem_amt_itd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,unearned_prem NUMERIC(13,2) NOT NULL  ENCODE zstd
	,gross_earned_prem_amt NUMERIC(13,2) NOT NULL  ENCODE zstd
	,gross_earned_prem_amt_ytd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,gross_earned_prem_amt_itd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,comm_earned_amt NUMERIC(13,2) NOT NULL  ENCODE zstd
	,comm_earned_amt_ytd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,comm_earned_amt_itd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,endorse_prem_amt NUMERIC(13,2) NOT NULL  ENCODE zstd
	,endorse_prem_amt_ytd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,endorse_prem_amt_itd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,audit_prem_amt NUMERIC(13,2) NOT NULL  ENCODE az64
	,audit_prem_amt_ytd NUMERIC(13,2) NOT NULL  ENCODE az64
	,audit_prem_amt_itd NUMERIC(13,2) NOT NULL  ENCODE az64
	,cncl_prem_amt NUMERIC(13,2) NOT NULL  ENCODE zstd
	,cncl_prem_amt_ytd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,cncl_prem_amt_itd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,rein_prem_amt_ytd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,rein_prem_amt_itd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,rein_prem_amt NUMERIC(13,2) NOT NULL  ENCODE zstd
	,taxes_amt NUMERIC(13,2) NOT NULL  ENCODE az64
	,taxes_amt_ytd NUMERIC(13,2) NOT NULL  ENCODE az64
	,taxes_amt_itd NUMERIC(13,2) NOT NULL  ENCODE az64
	,fees_amt NUMERIC(13,2) NOT NULL  ENCODE zstd
	,fees_amt_ytd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,fees_amt_itd NUMERIC(13,2) NOT NULL  ENCODE zstd
	,source_system VARCHAR(100) NOT NULL  ENCODE zstd
	,loaddate DATE NOT NULL  ENCODE az64
	,audit_id INTEGER NOT NULL  ENCODE zstd
	,we INTEGER  DEFAULT 0 ENCODE zstd
	,ee INTEGER  DEFAULT 0 ENCODE zstd
	,we_ytd INTEGER  DEFAULT 0 ENCODE zstd
	,ee_ytd INTEGER  DEFAULT 0 ENCODE zstd
	,we_itd INTEGER  DEFAULT 0 ENCODE zstd
	,ee_itd INTEGER  DEFAULT 0 ENCODE zstd
	,we_rm NUMERIC(38,4)  DEFAULT 0 ENCODE zstd
	,ee_rm NUMERIC(38,4)  DEFAULT 0 ENCODE zstd
	,we_rm_ytd NUMERIC(38,4)  DEFAULT 0 ENCODE zstd
	,ee_rm_ytd NUMERIC(38,4)  DEFAULT 0 ENCODE zstd
	,we_rm_itd NUMERIC(38,4)  DEFAULT 0 ENCODE zstd
	,ee_rm_itd NUMERIC(38,4)  DEFAULT 0 ENCODE zstd
	,policy_changes_id INTEGER  DEFAULT 0 ENCODE zstd
	,PRIMARY KEY (factpolicycoverage_id)
)
DISTSTYLE AUTO
 DISTKEY (policy_id)
 SORTKEY (
	month_id
	)
;

COMMENT ON TABLE fsbi_dw_spinn.fact_policycoverage IS ' 	Source: 	The same info as in PolicySummaryStats but build independently in DW	DW Table type:	Fact Monthly Summary table	Table description:	Monthly summaries at coverage level plus monthly policy state of coverages and risks (limits, deductibles) Months are based on accounting dates. You need to aggregate amounts from this table.';

-- Column comments

COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.month_id IS 'Foreign Key (link)  to dim_month.month_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.producer_id IS 'Foreign Key (link)  to dim_producer.producer_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.product_id IS 'Foreign Key (link)  to dim_product.product_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.company_id IS 'Foreign Key (link)  to dim_legalentity_other.legalentity_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.firstinsured_id IS 'Foreign Key (link)  to dim_insured.insured_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.policy_id IS 'Foreign Key (link)  to dim_policy.policy_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.policyextension_id IS 'Foreign Key (link)  to dim_policyextension.policyextension_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.policyeffectivedate_id IS 'Foreign Key (link)  to dim_time.time_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.policyexpirationdate_id IS 'Foreign Key (link)  to dim_time.time_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.policystatus_id IS 'Foreign Key (link)  to dim_status.status_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.coverage_id IS 'Foreign Key (link)  to dim_coverage.coverage_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.coverageeffectivedate_id IS 'Foreign Key (link)  to dim_time.time_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.coverageexpirationdate_id IS 'Foreign Key (link)  to dim_time.time_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.policymasterterritory_id IS 'Foreign Key (link)  to dim_territory.territory_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.primaryriskterritory_id IS 'Foreign Key (link)  to dim_territory.territory_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.limit_id IS 'Foreign Key (link)  to dim_limit.limit_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.deductible_id IS 'Foreign Key (link)  to dim_deductible.deductible_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.class_id IS 'Foreign Key (link)  to dim_classification.class_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.primaryrisk_id IS 'Foreign Key (link)  to dim_coveredrisk.coveredrisk_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.primaryriskextension_id IS 'Foreign Key (link)  to dim_coveredriskextension.coveredriskextension_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.primaryriskgeography_id IS 'Foreign Key (link)  to dim_geography.geography_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.primaryriskaddress_id IS 'Foreign Key (link)  to dim_address.address_id ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.vehicle_id IS 'Foreign Key (link)  to dim_vehicle.vehicle_id	  Use this column to get attributes effective at the moment of a policy term expiration date or current state of the policy if it`s still active. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.driver_id IS 'Foreign Key (link)  to dim_driver.driver_id	  Use this column to get attributes effective at the moment of a policy term expiration date or current state of the policy if it`s still active. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.building_id IS 'Foreign Key (link)  to dim_building.building_id	  Use this column to get attributes effective at the moment of a policy term expiration date or current state of the policy if it`s still active. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.location_id IS 'Foreign Key (link)  to dim_location.location_id	  Use this column to get attributes effective at the moment of a policy term expiration date or current state of the policy if it`s still active. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.month_vehicle_id IS 'Foreign Key (link)  to dim_vehicle.vehicle_id	  Use this column to get attributes effective at the end of the specific month. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.month_driver_id IS 'Foreign Key (link)  to dim_driver.driver_id	  Use this column to get attributes effective at the end of the specific month. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.month_building_id IS 'Foreign Key (link)  to dim_building.building_id	  Use this column to get attributes effective at the end of the specific month. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.month_location_id IS 'Foreign Key (link)  to dim_location.location_id	  Use this column to get attributes effective at the end of the specific month. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.insuredage IS 'Age of the first insured. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.policynewissuedind IS '"Identifies if a policy is a new policy that was *issued* for the given month and year.  Valid values are:1 = New policy issued in the month 0 = Not new in the month"';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.policyrenewedissuedind IS '"Identifies if a policy is a renewal policy that was *issued* for the given month and year.  Valid values are:1 = Renewal issued in the month 0 = Not renewed in the month"';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.policycancelledissuedind IS '"Identifies if a policy that was *issued* a cancellation for the given month and year.  Valid values are:1 = Cancellation issued  in the month 0 = Not cancelled in the month"';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.policynonrenewalissuedind IS '"Identifies if a policy was a non-renewed policy that was *issued* in the given month and year.  Valid values are:1 = Non-renewal issued in the month 0 = Not non-renewed in the month"';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.policyendorsementissuedind IS '"Identifies if a policy had an endorsement that was *issued* for the given month and year.  Valid values are:1 = Endorsement issued in the month 0 = No endorsement issued in the month"';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.comm_amt IS 'Month-to-date producer commission amount';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.comm_amt_ytd IS 'Year-to-date producer commission amount';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.comm_amt_itd IS 'Inception-to-date producer commission amount';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.wrtn_prem_amt IS 'Month-to-date written premium amount for this coverage. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.wrtn_prem_amt_ytd IS 'Year-to-date written premium amount for this coverage. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.wrtn_prem_amt_itd IS 'Inception-to-date written premium amount for this coverage. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.gross_wrtn_prem_amt IS 'Month-to-date gross written premium amount for this coverage.  Does not include cancellation or reinstatement premium. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.gross_wrtn_prem_amt_ytd IS 'Month-to-date written premium amount for this coverage.  Does not include cancellation or reinstatement premium. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.gross_wrtn_prem_amt_itd IS 'Month-to-date written premium amount for this coverage.  Does not include cancellation or reinstatement premium. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.orig_wrtn_prem_amt IS 'Premium written for the policy when it was issued (does not include endorsement/amendment or audit premium)';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.orig_wrtn_prem_amt_ytd IS 'Year-to-date premium written for the policy when it was issued (does not include endorsement/amendment or audit premium)';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.orig_wrtn_prem_amt_itd IS 'Inception-to-date premium written for the policy when it was issued (does not include endorsement/amendment or audit premium)';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.term_prem_amt IS 'Full Inforced amount. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.term_prem_amt_ytd IS 'Year-to-date Inforced amount. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.term_prem_amt_itd IS 'Inception-to-date full Inforced amount. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.earned_prem_amt IS 'Month-to-date earned premium amount. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.earned_prem_amt_ytd IS 'Year-to-date earned premium amount. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.earned_prem_amt_itd IS 'Inception-to-date earned premium amount. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.unearned_prem IS 'Amount of premium unearned (left to be earned)';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.gross_earned_prem_amt IS 'Month-to-date gross earned premium amount for this coverage.  Does not include cancellation or reinstatement premium. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.gross_earned_prem_amt_ytd IS 'Year-to-date gross earned premium amount for this coverage.  Does not include cancellation or reinstatement premium. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.gross_earned_prem_amt_itd IS 'Inception-to-date gross earned premium amount for this coverage.  Does not include cancellation or reinstatement premium. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.endorse_prem_amt IS 'Month-to-date endorsement premium amount';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.endorse_prem_amt_ytd IS 'Year-to-date endorsement premium amount';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.endorse_prem_amt_itd IS 'Inception-to-date endorsement premium amount';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.cncl_prem_amt IS 'Month-to-date cancellation premium amount. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.cncl_prem_amt_ytd IS 'Year-to-date cancellation premium amount. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.cncl_prem_amt_itd IS 'Inception-to-date cancellation premium amount. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.rein_prem_amt_ytd IS 'Year-to-date reinstated premium amount. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.rein_prem_amt_itd IS 'Inception-to-date reinstated premium amount. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.rein_prem_amt IS 'Month-to-date reinstated premium amount. ';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.fees_amt IS 'Month-to-date fees collected on a policy';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.fees_amt_ytd IS 'Year-to-date fees collected on a policy';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.fees_amt_itd IS 'Inception-to-date fees collected on a policy';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.we IS 'Written Exposures based on  1 month = 1 exposure per policy term/coverage/Risk';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.ee IS 'Earned Exposures based on  1 month = 1 exposure per policy term/coverage/Risk';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.we_ytd IS 'Year To Date Written Exposures based on  1 month = 1 exposure per policy term/coverage/Risk';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.ee_ytd IS 'Year To Date Earned Exposures based on  1 month = 1 exposure per policy term/coverage/Risk';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.we_itd IS 'Inception To Date Written Exposures based on  1 month = 1 exposure per policy term/coverage/Risk';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.ee_itd IS 'Inception To Date Earned Exposures based on  1 month = 1 exposure per policy term/coverage/Risk';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.we_rm IS 'Written Exposures  (fractional) based on term length, since what day a policy is effective in a month and number of days in a month. E.g. 1 month exposure can be 0.03 or 1.018 per policy term/coverage/Risk';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.ee_rm IS 'Earned Exposures  (fractional) based on term length, since what day a policy is effective in a month and number of days in a month. E.g. 1 month exposure can be 0.03 or 1.018 per policy term/coverage/Risk';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.we_rm_ytd IS 'Year To Date Written Exposures  (fractional) based on term length, since what day a policy is effective in a month and number of days in a month. E.g. 1 month exposure can be 0.03 or 1.018 per policy term/coverage/Risk';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.ee_rm_ytd IS 'Year To Date Earned Exposures  (fractional) based on term length, since what day a policy is effective in a month and number of days in a month. E.g. 1 month exposure can be 0.03 or 1.018 per policy term/coverage/Risk';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.we_rm_itd IS 'Inception To Date Written Exposures  (fractional) based on term length, since what day a policy is effective in a month and number of days in a month. E.g. 1 month exposure can be 0.03 or 1.018 per policy term/coverage/Risk';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.ee_rm_itd IS 'Inception To Date Earned Exposures  (fractional) based on term length, since what day a policy is effective in a month and number of days in a month. E.g. 1 month exposure can be 0.03 or 1.018 per policy term/coverage/Risk';
COMMENT ON COLUMN fsbi_dw_spinn.fact_policycoverage.policy_changes_id IS 'NOT READY FOR USE yet. Reference to DIM_POLICY_CHANGES (variable policy level attributes). DIM_POLICY_CHANGES is updated after this table is populated';
