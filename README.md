# 🏥 Healthcare Management System (HMS) – SQL Project

## 📌 Overview

I have successfully developed a comprehensive **Healthcare Management System (HMS)** that utilizes a master ERP table for managing patient information. This project has provided me with hands-on experience in data cleaning, database design, and advanced SQL programming, simulating real-world challenges in handling healthcare data.

## 🎯 Objectives Achieved

- **Data Cleaning & Standardization**: Identified and corrected data quality issues in the provided master dataset, including standardizing city and state entries, formatting phone numbers, removing duplicate records, and handling missing values appropriately.

- **Database Design**: Designed a normalized relational database schema based on the master table, ensuring data integrity and efficient data management.

- **SQL Programming**: Developed SQL scripts to create the necessary database tables and populated them with cleaned data.

- **Advanced SQL Techniques**: Implemented views, stored procedures, and triggers to enhance database functionality and maintain data consistency.

- **Data Analysis**: Executed complex queries to extract meaningful insights from the data, aiding in decision-making processes.

## 🗂️ Project Structure

### 1. ERP Master Patient Table

- **Execution**: Loaded the provided SQL file to create and populate the `ERP_Master_Patient` table in the database.

- **Data Cleaning Tasks**:
  - Standardized entries in the `city` and `state` columns.
  - Formatted phone numbers to a uniform format.
  - Removed duplicate rows based on a unique combination of key fields (e.g., patient ID, name, date of birth).
  - Handled missing or null values by inferring data where possible or replacing with placeholders such as "Unknown" or "N/A".

### 2. Tables Created

Developed the following normalized tables:

- `Patients`
- `Doctors`
- `Nurses`
- `Billing`
- `Insurance`
- `Rooms`
- `MedicalStaff`
- `VitalSigns`
- `Admissions`

Each table includes appropriate primary keys, foreign keys, and constraints to maintain data integrity.

### 3. Stored Procedures

Implemented stored procedures for:

- Loading data into the `Patients` table from the master table, ensuring no duplicate records are inserted.
- Updating patient information based on their unique patient ID.
- Managing billing information with validations to ensure related patient data is accurate before making changes.
- Allocating rooms to patients upon admission, checking for available rooms and updating the `Rooms` table accordingly.
- Recording patient discharge and updating the room's availability status.
- Processing payments and updating billing records, ensuring that payments do not exceed the total amount due.

### 4. Views

Created views to simplify data retrieval:

- **Patient Summary**: Aggregates essential patient information for quick access.
- **Doctor Assignments**: Displays the number of patients each doctor is responsible for.
- **Billing Summary**: Combines patient details with their billing information to provide a comprehensive overview of outstanding payments and billing history.
- **Room Availability**: Shows all rooms along with their current occupancy status.
- **Patient Room Allocation**: Links patients with their assigned rooms, showing which patients are currently occupying which rooms and their admission dates.
- **Patient-Doctor Assignments**: Illustrates the relationship between patients and their assigned doctors, including the doctor's specialty for quick reference.

### 5. Data Integrity and Referential Integrity

Ensured robust data integrity by:

- Defining primary keys for unique identification of records.
- Establishing foreign keys to enforce relationships between tables.
- Implementing check constraints to enforce valid values in specific columns.
- Considering cascading updates and deletes to maintain referential integrity when records are modified or removed.

### 6. Additional Implementations

- **Window Functions**: Created queries using window functions to calculate the average length of stay for patients.
- **Triggers**: Designed a trigger that logs updates made to patient records into an audit table to track changes.
- **Recursive Common Table Expressions (CTEs)**: Utilized recursive CTEs to explore hierarchical data, such as family relationships based on emergency contacts stored in the `Patients` table.

## 📁 Deliverables

- SQL scripts for data cleaning, table creation, and data manipulation.
- SQL scripts for stored procedures, views, functions, and triggers.
- Screenshots and outputs from queries demonstrating the analysis performed.
- A comprehensive final report summarizing the project, findings, and challenges faced.

## 🛠️ Technologies Used

- **Database**: Microsoft SQL Server
- **SQL Dialect**: T-SQL
