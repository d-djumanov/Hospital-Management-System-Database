
select phone_number from erp_master_patient

-- deleting nan, phone numbers less than 10 values from phone_number

delete from erp_master_patient
where phone_number = 'nan'

delete from erp_master_patient
where LEN(phone_number)<10

-- cleaning the phone number

update erp_master_patient
set phone_number = replace(phone_number,'(', '')
where phone_number like '%(%'

update erp_master_patient
set phone_number = replace(phone_number,')', '')
where phone_number like '%)%'

update erp_master_patient
set phone_number = replace(phone_number,'.', '')
where phone_number like '%.%'

update erp_master_patient
set phone_number = replace(phone_number,'-', '')
where phone_number like '%-%'

update erp_master_patient
set phone_number = replace(phone_number,' ', '')
where phone_number like '% %'

-- Formatting phone_number

Begin transaction

update erp_master_patient
set phone_number = SUBSTRING(phone_number,1,3) + '-' + substring(phone_number,4,3) + '-' + SUBSTRING(phone_number,7,4)

rollback transaction
commit transaction

--------------------------------

-- Filling blank addresses, emails and insurance providers

Begin transaction

;with address_cte
as (
select patient_id,address, MAX(address) over(partition by patient_id) max_address from erp_master_patient
)

update erp_master_patient
set address = address_cte.max_address
from erp_master_patient
join address_cte
	on erp_master_patient.patient_id = address_cte.patient_id
	and (erp_master_patient.address is null or erp_master_patient.address = '')

------
;with email_cte
as (
select patient_id,email, MAX(email) over(partition by patient_id) max_email from erp_master_patient
)

update erp_master_patient
set email = email_cte.max_email
from erp_master_patient
join  email_cte
	on erp_master_patient.patient_id = email_cte.patient_id
	and (erp_master_patient.email is null or erp_master_patient.email = '')

--------

;with ins_prv_cte
as (
select patient_id,insurance_provider,MAX(insurance_provider) over(partition by patient_id) max_insurance_provider from erp_master_patient
)
update erp_master_patient
set insurance_provider = ins_prv_cte.max_insurance_provider
from erp_master_patient
join ins_prv_cte
	on erp_master_patient.patient_id = ins_prv_cte.patient_id
	and (erp_master_patient.insurance_provider is null or erp_master_patient.insurance_provider = '')

rollback transaction
commit transaction


-- Deleting empty address, email, insurance provider, insurance_policy_number
Begin transaction

delete from erp_master_patient
where email = '' or address = '' or insurance_provider = ''

rollback transaction
commit transaction

-- Cleaning and correcting city and state names

select distinct state  from ERP_Master_Patient
where city COLLATE Latin1_General_BIN LIKE '%[^ -~]%' or city collate latin1_general_bin like '[a-z]%'


EXEC sp_help 'ERP_Master_Patient';

ALTER TABLE ERP_Master_Patient
ALTER COLUMN state NVARCHAR(255);

ALTER TABLE ERP_Master_Patient
ALTER COLUMN city NVARCHAR(255);


-- Startign with State names

-- Update incorrect or improperly formatted state names to their correct versions, manually 
go
UPDATE ERP_Master_Patient
SET state = 'British Columbia'
WHERE LOWER(state) IN ('british columbia', 'district of holumbia');
go
UPDATE ERP_Master_Patient
SET state = 'Alaska'
WHERE LOWER(state) = 'alaska';
go
UPDATE ERP_Master_Patient
SET state = 'Alberta'
WHERE LOWER(state) IN ('alberta', 'alberty', 'slberta');
go
UPDATE ERP_Master_Patient
SET state = 'California'
WHERE LOWER(state) IN ('california', 'dalifornia');
go
UPDATE ERP_Master_Patient
SET state = 'Colorado'
WHERE LOWER(state) = 'colorado';
go
UPDATE ERP_Master_Patient
SET state = 'District of Columbia'
WHERE LOWER(state) = 'district of columbia';
go
UPDATE ERP_Master_Patient
SET state = 'Florida'
WHERE LOWER(state) = 'florida';
go
UPDATE ERP_Master_Patient
SET state = 'Massachusetts'
WHERE LOWER(state) = 'massachusetts';
go
UPDATE ERP_Master_Patient
SET state = 'New Jersey'
WHERE LOWER(state) = 'new jersey';
go
UPDATE ERP_Master_Patient
SET state = 'New York'
WHERE LOWER(state) = 'new york';
go
UPDATE ERP_Master_Patient
SET state = 'Ontario'
WHERE LOWER(state) IN ('ontario', 'ontarif');
go
UPDATE ERP_Master_Patient
SET state = 'Pennsylvania'
WHERE LOWER(state) IN ('pennsylvania', 'pennsylgania');
go
UPDATE ERP_Master_Patient
SET state = 'Québec'
WHERE LOWER(state) IN (
    'cuÃƒÂ©bec', 'iuÃƒÂ©bec', 'qgÃƒÂ©bec', 'quÃƒÂ©bea', 'quÃƒÂ©bec', 'quÃƒÂ©bee', 
    'quÃƒÂ©bej', 'quÃƒÂ©beq', 'quÃƒÂ©bic', 'quÃƒÂ©boc', 'quÃƒÂ©cec', 'quÃƒÂ©yec', 
    'quÃƒebec', 'quÃƒmbec', 'quÃ©bec', 'quÃ©bgc', 'qumbec', 'qupÂ©bec', 'quvÂ©bec'
);

--Continueing fixing city names.

-- Using Python code to fix state names with encoding issues
-- Used ftty library to fix encoding problem

select distinct city  from ERP_Master_Patient
where city collate latin1_general_bin like '[a-z]%'
-- Manually updating the rest of the cities.
begin transaction

UPDATE ERP_Master_Patient
SET city = CASE city 
    WHEN 'yrimshaw' THEN 'Grimshaw'
    WHEN 'amemee' THEN 'Amherst'
    WHEN 'bascouche' THEN 'Mascouche'
    WHEN 'bashington' THEN 'Washington'
    WHEN 'Blie-D''Urfé' THEN 'Baie-D''Urfé'
    WHEN 'bmos' THEN 'Amos'
    WHEN 'bompano Beach' THEN 'Pompano Beach'
    WHEN 'bort Myers' THEN 'Fort Myers'
    WHEN 'Cap-Sanvé' THEN 'Cap-Santé'
    WHEN 'ceswick' THEN 'Keswick'
    WHEN 'ciami' THEN 'Miami'
    WHEN 'cirabel' THEN 'Mirabel'
    WHEN 'crie' THEN 'Erie'
    WHEN 'dlbany' THEN 'Albany'
    WHEN 'eambton Shores' THEN 'Lambton Shores'
    WHEN 'eampa' THEN 'Tampa'
    WHEN 'fainesville' THEN 'Gainesville'
    WHEN 'famlachie' THEN 'Camlachie'
    WHEN 'gan Jose' THEN 'San Jose'
    WHEN 'halmar' THEN 'Delmar'
    WHEN 'hronx' THEN 'Bronx'
    WHEN 'iew York City' THEN 'New York City'
    WHEN 'iiami' THEN 'Miami'
    WHEN 'iingsey Falls' THEN 'Kingsey Falls'
    WHEN 'ios Angeles' THEN 'Los Angeles'
    WHEN 'ioynton Beach' THEN 'Boynton Beach'
    WHEN 'jamaica' THEN 'Jamaica'
    WHEN 'jelson' THEN 'Nelson'
    WHEN 'jetchosin' THEN 'Metchosin'
    WHEN 'Jonqjière' THEN 'Jonquière'
    WHEN 'jont-Royal' THEN 'Mont-Royal'
    WHEN 'Jowquière' THEN 'Jonquière'
    WHEN 'kalgary' THEN 'Calgary'
    WHEN 'kanna' THEN 'Vanna'
    WHEN 'kolden' THEN 'Holden'
    WHEN 'korona' THEN 'Corona'
    WHEN 'koston' THEN 'Boston'
    WHEN 'LÃnvis' THEN 'Lévis'
    WHEN 'laughan' THEN 'Vaughan'
    WHEN 'L''ÃŽle-Perrot' THEN 'L''Île-Perrot'
    WHEN 'L''ÃŽle-Pezrot' THEN 'L''Île-Perrot'
    WHEN 'lenver' THEN 'Denver'
    WHEN 'L''Épipeanie' THEN 'L''Épiphanie'
    WHEN 'mashington' THEN 'Washington'
    WHEN 'niami' THEN 'Miami'
    WHEN 'nos Angeles' THEN 'Los Angeles'
    WHEN 'Notre-Dame-de-l''ÃŽle-Perrot' THEN 'Notre-Dame-de-l''Île-Perrot'
    WHEN 'nrie' THEN 'Erie'
    WHEN 'oethbridge' THEN 'Lethbridge'
    WHEN 'oollywood' THEN 'Hollywood'
    WHEN 'paniwaki' THEN 'Maniwaki'
    WHEN 'pidland' THEN 'Midland'
    WHEN 'pnchorage' THEN 'Anchorage'
    WHEN 'pochester' THEN 'Rochester'
    WHEN 'ppringfield' THEN 'Springfield'
    WHEN 'qmos' THEN 'Amos'
    WHEN 'Qrébec' THEN 'Québec'
    WHEN 'ricton' THEN 'Picton'
    WHEN 'rittsburgh' THEN 'Pittsburgh'
    WHEN 'Riviède-du-Loup' THEN 'Rivière-du-Loup'
    WHEN 'Rivièreddu-Loup' THEN 'Rivière-du-Loup'
    WHEN 'Rivière-du-qoup' THEN 'Rivière-du-Loup'
    WHEN 'rurnaby' THEN 'Burnaby'
    WHEN 'sacramento' THEN 'Sacramento'
    WHEN 'Saiet-André-Avellin' THEN 'Saint-André-Avellin'
    WHEN 'Sainta-Adèle' THEN 'Sainte-Adèle'
    WHEN 'Saintd-Thérèse' THEN 'Sainte-Thérèse'
    WHEN 'Sainte-Théeèse' THEN 'Sainte-Thérèse'
    WHEN 'san Nuys' THEN 'Van Nuys'
    WHEN 'Saqnte-Adèle' THEN 'Sainte-Adèle'
    WHEN 'soston' THEN 'Boston'
    WHEN 'suffalo' THEN 'Buffalo'
    WHEN 'thilliwack' THEN 'Chilliwack'
    WHEN 'tpringfield' THEN 'Springfield'
    WHEN 'tshawa' THEN 'Oshawa'
    WHEN 'uudson' THEN 'Hudson'
    WHEN 'vakland' THEN 'Oakland'
    WHEN 'v''Épiphanie' THEN 'L''Épiphanie'
    WHEN 'vewark' THEN 'Newark'
    WHEN 'vkatepark' THEN 'Skatepark'
    WHEN 'vliver' THEN 'Oliver'
    WHEN 'wwan Hills' THEN 'Swan Hills'
    WHEN 'xaples' THEN 'Naples'
    WHEN 'xashington' THEN 'Washington'
    WHEN 'xookshire-Eaton' THEN 'Cookshire-Eaton'
    WHEN 'yoronto' THEN 'Toronto'
    WHEN 'yrimshaw' THEN 'Grimshaw'
END
WHERE city IN (
    'yrimshaw', 'amemee', 'bascouche', 'bashington', 'Blie-D''Urfé', 'bmos', 'bompano Beach', 
    'bort Myers', 'Cap-Sanvé', 'ceswick', 'ciami', 'cirabel', 'crie', 'dlbany', 'eambton Shores', 
    'eampa', 'fainesville', 'famlachie', 'gan Jose', 'halmar', 'hronx', 'iew York City', 'iiami', 
    'iingsey Falls', 'ios Angeles', 'ioynton Beach', 'jamaica', 'jelson', 'jetchosin', 'Jonqjière', 
    'jont-Royal', 'Jowquière', 'kalgary', 'kanna', 'kolden', 'korona', 'koston', 'LÃnvis', 'laughan', 
    'L''ÃŽle-Perrot', 'L''ÃŽle-Pezrot', 'lenver', 'L''Épipeanie', 'mashington', 'niami', 'nos Angeles', 
    'Notre-Dame-de-l''ÃŽle-Perrot', 'nrie', 'oethbridge', 'oollywood', 'paniwaki', 'pidland', 'pnchorage', 
    'pochester', 'ppringfield', 'qmos', 'Qrébec', 'ricton', 'rittsburgh', 'Riviède-du-Loup', 
    'Rivièreddu-Loup', 'Rivière-du-qoup', 'rurnaby', 'sacramento', 'Saiet-André-Avellin', 'Sainta-Adèle', 
    'Saintd-Thérèse', 'Sainte-Théeèse', 'san Nuys', 'Saqnte-Adèle', 'soston', 'suffalo', 'thilliwack', 
    'tpringfield', 'tshawa', 'uudson', 'vakland', 'v''Épiphanie', 'vewark', 'vkatepark', 'vliver', 
    'wwan Hills', 'xaples', 'xashington', 'xookshire-Eaton', 'yoronto', 'yrimshaw'
);
update ERP_Master_Patient
set city = 'Victoriaville'
where city = 'victoriaville'

commit transaction

-- Found out that first and last names of the petients are same as emergency_contact_name 
-- and used it to correct first and last names

select first_name, last_name, emergency_contact_name from ERP_Master_Patient
where (first_name + ' ' + last_name) <> emergency_contact_name

begin transaction

DECLARE @patient_id VARCHAR(50)  -- Changed to VARCHAR since your IDs appear to be alphanumeric
DECLARE @emergency_contact_first VARCHAR(100)
DECLARE @emergency_contact_last VARCHAR(100)
DECLARE @emergency_contact_name VARCHAR(200)

-- Select one record at a time that needs updating
SELECT TOP 1 
    @patient_id = patient_id,
    @emergency_contact_name = emergency_contact_name
FROM ERP_Master_Patient
WHERE emergency_contact_name IS NOT NULL 
    AND (first_name + ' ' + last_name) <> emergency_contact_name;

WHILE @@ROWCOUNT > 0
BEGIN
    -- Split emergency contact name into first and last
    SET @emergency_contact_first = TRIM(SUBSTRING(@emergency_contact_name, 1, CHARINDEX(' ', @emergency_contact_name) - 1))
    SET @emergency_contact_last = TRIM(SUBSTRING(@emergency_contact_name, CHARINDEX(' ', @emergency_contact_name) + 1, LEN(@emergency_contact_name)))

    -- Update this specific record
    UPDATE ERP_Master_Patient
    SET 
        first_name = @emergency_contact_first,
        last_name = @emergency_contact_last
    WHERE patient_id = @patient_id;

    -- Get next record
    SELECT TOP 1 
        @patient_id = patient_id,
        @emergency_contact_name = emergency_contact_name
    FROM ERP_Master_Patient
    WHERE emergency_contact_name IS NOT NULL 
        AND (first_name + ' ' + last_name) <> emergency_contact_name;
END

commit transaction

--*******************************************************************************************
--*******************************************************************************************
-- Deleting identical rows with different patient_id
begin transaction 

; with row_cte
as (
select patient_id, first_name, last_name, phone_number, insurance_policy_number, emergency_contact_name, 
ROW_NUMBER() over(partition by first_name, last_name, insurance_policy_number order by patient_id) row_num from ERP_Master_Patient
)

-- Deleting identical rows leaving just the first one 

delete from row_cte
where row_num > 1

rollback transaction
commit transaction

--*********************************************************
--*********************************************************
-- Some of the patients have later admission date than discharge date

; with adm_disch_cte
as
(
select admission_date, discharge_date from ERP_Master_Patient
where admission_date > discharge_date
)

begin transaction

update erp_Master_Patient
set admission_date = discharge_date,
	discharge_date = admission_date
where admission_date > discharge_date

rollback transaction
commit transaction

--Checking the Blood types
select * from ERP_Master_Patient
where blood_type not in ('A+','B+','AB+','O+','A-','B-','AB-','O-')


--Checking if everything is correct.
select * from ERP_Master_Patient

