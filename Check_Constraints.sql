
-- ***************************************************************
--              Check Constraints
-- ***************************************************************

-- =============================================
-- Check Constraints for Patients Table
-- =============================================
-- Valid gender values
ALTER TABLE Patients
ADD CONSTRAINT CHK_Patients_Gender
CHECK (gender IN ('Male', 'Female', 'Other', 'Unknown'));

-- Valid blood type values
ALTER TABLE Patients
ADD CONSTRAINT CHK_Patients_BloodType
CHECK (blood_type IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Unknown'));

-- Ensure DOB is not in the future
ALTER TABLE Patients
ADD CONSTRAINT CHK_Patients_DOB
CHECK (dob <= GETDATE());

-- Valid phone number format (basic check)
ALTER TABLE Patients
ADD CONSTRAINT CHK_Patients_PhoneNumber
CHECK (phone_number LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' OR 
       phone_number LIKE '([0-9][0-9][0-9]) [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' OR
       phone_number IS NULL);

-- Ensure discharge date is after admission date
ALTER TABLE Patients
ADD CONSTRAINT CHK_Patients_DischargeDateAfterAdmission
CHECK (discharge_date IS NULL OR admission_date IS NULL OR discharge_date >= admission_date);

-- Valid vital signs ranges
ALTER TABLE Patients
ADD CONSTRAINT CHK_Patients_Weight
CHECK (weight IS NULL OR (weight > 0 AND weight < 700)); -- in pounds

ALTER TABLE Patients
ADD CONSTRAINT CHK_Patients_Height
CHECK (height IS NULL OR (height > 0 AND height < 108)); -- in inches (9 feet max)

-- =============================================
-- Check Constraints for Doctors Table
-- =============================================
ALTER TABLE Doctors
ADD CONSTRAINT CHK_Doctors_PhoneNumber
CHECK (phone_number LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' OR 
       phone_number LIKE '([0-9][0-9][0-9]) [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' OR
       phone_number IS NULL);

ALTER TABLE Doctors
ADD CONSTRAINT CHK_Doctors_Email
CHECK (email LIKE '%@%.%' OR email IS NULL);

-- =============================================
-- Check Constraints for Nurses Table
-- =============================================
ALTER TABLE Nurses
ADD CONSTRAINT CHK_Nurses_PhoneNumber
CHECK (phone_number LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' OR 
       phone_number LIKE '([0-9][0-9][0-9]) [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' OR
       phone_number IS NULL);

ALTER TABLE Nurses
ADD CONSTRAINT CHK_Nurses_Email
CHECK (email LIKE '%@%.%' OR email IS NULL);

-- =============================================
-- Check Constraints for Billing Table
-- =============================================
ALTER TABLE Billing
ADD CONSTRAINT CHK_Billing_TotalAmount
CHECK (total_amount >= 0);

ALTER TABLE Billing
ADD CONSTRAINT CHK_Billing_AmountPaid
CHECK (amount_paid >= 0);

ALTER TABLE Billing
ADD CONSTRAINT CHK_Billing_AmountPaidNotExceedTotal
CHECK (amount_paid <= total_amount);

ALTER TABLE Billing
ADD CONSTRAINT CHK_Billing_DueDateNotBeforeBillingDate
CHECK (due_date >= billing_date);


ALTER TABLE Billing
ADD CONSTRAINT CHK_Billing_PaymentMethod
CHECK (payment_method IN ('Cash', 'Credit Card', 'Debit Card', 'Check', 'Insurance', 'Wire Transfer', 'Online Payment', NULL));

-- =============================================
-- Check Constraints for Insurance Table
-- =============================================
ALTER TABLE Insurance
ADD CONSTRAINT CHK_Insurance_AnnualDeductible
CHECK (annual_deductible >= 0);

ALTER TABLE Insurance
ADD CONSTRAINT CHK_Insurance_MaxOutOfPocket
CHECK (max_out_of_pocket >= 0);

ALTER TABLE Insurance
ADD CONSTRAINT CHK_Insurance_CoverageEndDate
CHECK (coverage_end_date >= coverage_start_date);

ALTER TABLE Insurance
ADD CONSTRAINT CHK_Insurance_PlanType
CHECK (plan_type IN ('HMO', 'PPO', 'EPO', 'POS', 'HDHP', 'Medicare', 'Medicaid', 'Other', NULL));

-- =============================================
-- Check Constraints for Rooms Table
-- =============================================


ALTER TABLE Rooms
ADD CONSTRAINT CHK_Rooms_CurrentOccupancy
CHECK (current_occupancy >= 0 AND current_occupancy <= capacity);

ALTER TABLE Rooms
ADD CONSTRAINT CHK_Rooms_RoomType
CHECK (room_type IN ('Standard', 'Private', 'Semi-Private', 'ICU', 'Operating', 'Emergency', 'Isolation', 'Maternity', 'Pediatric', 'Psychiatric', NULL));

-- =============================================
-- Check Constraints for MedicalStaff Table
-- =============================================


ALTER TABLE MedicalStaff
ADD CONSTRAINT CHK_MedicalStaff_PhoneNumber
CHECK (phone_number LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' OR 
       phone_number LIKE '([0-9][0-9][0-9]) [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' OR
       phone_number IS NULL);

ALTER TABLE MedicalStaff
ADD CONSTRAINT CHK_MedicalStaff_Email
CHECK (email LIKE '%@%.%' OR email IS NULL);

-- =============================================
-- Check Constraints for VitalSigns Table
-- =============================================
ALTER TABLE VitalSigns
ADD CONSTRAINT CHK_VitalSigns_BloodPressure
CHECK (blood_pressure IS NULL OR blood_pressure > 0);



ALTER TABLE VitalSigns
ADD CONSTRAINT CHK_VitalSigns_Weight
CHECK (weight IS NULL OR (weight > 0 AND weight < 700));

ALTER TABLE VitalSigns
ADD CONSTRAINT CHK_VitalSigns_Height
CHECK (height IS NULL OR (height > 0 AND height < 108));



ALTER TABLE VitalSigns
ADD CONSTRAINT CHK_VitalSigns_RecordedAt
CHECK (recorded_at <= GETDATE());

-- =============================================
-- Check Constraints for Admissions Table
-- =============================================
ALTER TABLE Admissions
ADD CONSTRAINT CHK_Admissions_DischargeDateAfterAdmission
CHECK (discharge_date IS NULL OR discharge_date >= admission_date);

ALTER TABLE Admissions
ADD CONSTRAINT CHK_Admissions_AdmissionDate
CHECK (admission_date <= GETDATE());