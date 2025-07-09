-- ================================
-- DROP TABLES IF THEY EXIST
-- ================================
BEGIN
   FOR tbl IN (
      SELECT table_name FROM user_tables
      WHERE table_name IN (
         'DOCTOR', 'PHARMACOMPANY', 'PHARMACY', 'DRUG','PRESCRIPTIONDRUG',
         'PHARMACYDRUG','PATIENT','PRESCRIPTION','CONTRACT'
      )
   ) LOOP
      EXECUTE IMMEDIATE 'DROP TABLE "' || tbl.table_name || '" CASCADE CONSTRAINTS';
   END LOOP;
END;
/

-- ================================
-- CREATE TABLES
-- ================================
CREATE TABLE Doctor (
    AadharID         VARCHAR2(12) PRIMARY KEY,
    Name             VARCHAR2(100) NOT NULL,
    Specialty        VARCHAR2(100),
    YearsExperience  NUMBER(2) CHECK (YearsExperience >= 0)
);

CREATE TABLE Patient (
    AadharID      VARCHAR2(12) PRIMARY KEY,
    Name          VARCHAR2(100) NOT NULL,
    Address       VARCHAR2(200),
    Age           NUMBER(3) CHECK (Age > 0),
    PrimaryPhysID VARCHAR2(12) NOT NULL,
    CONSTRAINT fk_patient_primary_phys
        FOREIGN KEY (PrimaryPhysID) REFERENCES Doctor(AadharID)
);

CREATE TABLE PharmaCompany (
    Name        VARCHAR2(100) PRIMARY KEY,
    PhoneNumber VARCHAR2(15)
);

CREATE TABLE Pharmacy (
    Name        VARCHAR2(100) PRIMARY KEY,
    Address     VARCHAR2(200),
    Phone       VARCHAR2(15)
);

CREATE TABLE Drug (
    TradeName        VARCHAR2(100),
    Formula          VARCHAR2(200),
    PharmaName       VARCHAR2(100) NOT NULL,
    PRIMARY KEY (TradeName, PharmaName),
    CONSTRAINT fk_drug_pharma
        FOREIGN KEY (PharmaName) REFERENCES PharmaCompany(Name)
);

CREATE TABLE PharmacyDrug (
    PharmacyName VARCHAR2(100),
    TradeName    VARCHAR2(100),
    PharmaName   VARCHAR2(100),
    Price        NUMBER(8,2) CHECK (Price >= 0),
    PRIMARY KEY (PharmacyName, TradeName, PharmaName),
    CONSTRAINT fk_pd_pharmacy
        FOREIGN KEY (PharmacyName) REFERENCES Pharmacy(Name),
    CONSTRAINT fk_pd_drug
        FOREIGN KEY (TradeName, PharmaName) REFERENCES Drug(TradeName, PharmaName)
);

CREATE TABLE Prescription (
    PrescID      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    PatientID    VARCHAR2(12) NOT NULL,
    DoctorID     VARCHAR2(12) NOT NULL,
    PrescDate    DATE NOT NULL,
    CONSTRAINT uq_presc UNIQUE (PatientID, DoctorID, PrescDate),
    CONSTRAINT fk_presc_patient
        FOREIGN KEY (PatientID) REFERENCES Patient(AadharID),
    CONSTRAINT fk_presc_doctor
        FOREIGN KEY (DoctorID) REFERENCES Doctor(AadharID)
);

CREATE TABLE PrescriptionDrug (
    PrescID      NUMBER,
    TradeName    VARCHAR2(100),
    PharmaName   VARCHAR2(100),
    Quantity     NUMBER(5) CHECK (Quantity > 0),
    PRIMARY KEY (PrescID, TradeName, PharmaName),
    CONSTRAINT fk_pd_presc
        FOREIGN KEY (PrescID) REFERENCES Prescription(PrescID),
    CONSTRAINT fk_psd_drug
        FOREIGN KEY (TradeName, PharmaName) REFERENCES Drug(TradeName, PharmaName)
);

CREATE TABLE Contract (
    PharmacyName   VARCHAR2(100) NOT NULL,
    PharmaName     VARCHAR2(100) NOT NULL,
    StartDate      DATE NOT NULL,
    EndDate        DATE,
    Content        VARCHAR2(500),
    Supervisor     VARCHAR2(12),
    CONSTRAINT fk_contract_pharmacy
        FOREIGN KEY (PharmacyName) REFERENCES Pharmacy(Name),
    CONSTRAINT fk_contract_pharma
        FOREIGN KEY (PharmaName) REFERENCES PharmaCompany(Name)
);

-- ================================
-- INSERT SAMPLE DATA
-- ================================
INSERT INTO Doctor VALUES ('D1001', 'Sonal Mehra', 'Cardiology', 18);
INSERT INTO Doctor VALUES ('D1002', 'Ravindra Nair', 'Dermatology', 11);
INSERT INTO Doctor VALUES ('D1003', 'Pranav Sethi', 'General Medicine', 7);

INSERT INTO Patient VALUES ('P2101', 'Aarav Bansal', 'Sector 21, Gurgaon', 29, 'D1001');
INSERT INTO Patient VALUES ('P2102', 'Mitali Rao', 'Indiranagar, Bangalore', 42, 'D1002');
INSERT INTO Patient VALUES ('P2103', 'Shivam Desai', 'Salt Lake, Kolkata', 36, 'D1003');
INSERT INTO Patient VALUES ('P2104', 'Nisha Verma', 'Baner, Pune', 51, 'D1001');

INSERT INTO PharmaCompany VALUES ('Zyphar Labs', '022-44556677');
INSERT INTO PharmaCompany VALUES ('Asterion Pharma', '040-22334455');
INSERT INTO PharmaCompany VALUES ('Medivista', '011-33445566');

INSERT INTO Pharmacy VALUES ('Nova Central', 'Connaught Place, Delhi', '011-1234567');
INSERT INTO Pharmacy VALUES ('Nova South', 'Koramangala, Bangalore', '080-2345678');
INSERT INTO Pharmacy VALUES ('Nova East', 'Salt Lake, Kolkata', '033-3456789');

INSERT INTO Drug VALUES ('Cardiozol', 'C17H21NO4', 'Zyphar Labs');
INSERT INTO Drug VALUES ('Dermaclear', 'C12H22O11', 'Asterion Pharma');
INSERT INTO Drug VALUES ('MediCough', 'C8H9NO2', 'Medivista');
INSERT INTO Drug VALUES ('Zypharin', 'C13H18O2', 'Zyphar Labs');
INSERT INTO Drug VALUES ('Asteflox', 'C14H19NO2', 'Asterion Pharma');
INSERT INTO Drug VALUES ('Panacure', 'C16H13ClN2O', 'Medivista');
INSERT INTO Drug VALUES ('Zolstat', 'C15H11NO2', 'Zyphar Labs');
INSERT INTO Drug VALUES ('Astrevit', 'C10H15NO', 'Asterion Pharma');
INSERT INTO Drug VALUES ('Neurovex', 'C20H25N3O', 'Medivista');
INSERT INTO Drug VALUES ('Imunol', 'C18H21NO3', 'Zyphar Labs');


INSERT INTO PharmacyDrug VALUES ('Nova Central', 'Cardiozol', 'Zyphar Labs', 178.50);
INSERT INTO PharmacyDrug VALUES ('Nova Central', 'Dermaclear', 'Asterion Pharma', 95.00);
INSERT INTO PharmacyDrug VALUES ('Nova Central', 'MediCough', 'Medivista', 52.00);
INSERT INTO PharmacyDrug VALUES ('Nova Central', 'Zypharin', 'Zyphar Labs', 210.00);
INSERT INTO PharmacyDrug VALUES ('Nova Central', 'Asteflox', 'Asterion Pharma', 125.00);
INSERT INTO PharmacyDrug VALUES ('Nova Central', 'Panacure', 'Medivista', 82.00);
INSERT INTO PharmacyDrug VALUES ('Nova Central', 'Zolstat', 'Zyphar Labs', 119.00);
INSERT INTO PharmacyDrug VALUES ('Nova Central', 'Astrevit', 'Asterion Pharma', 67.00);
INSERT INTO PharmacyDrug VALUES ('Nova Central', 'Neurovex', 'Medivista', 151.00);
INSERT INTO PharmacyDrug VALUES ('Nova Central', 'Imunol', 'Zyphar Labs', 176.00);
INSERT INTO PharmacyDrug VALUES ('Nova South', 'Dermaclear', 'Asterion Pharma', 97.00);
INSERT INTO PharmacyDrug VALUES ('Nova South', 'Asteflox', 'Asterion Pharma', 130.00);
INSERT INTO PharmacyDrug VALUES ('Nova South', 'MediCough', 'Medivista', 54.00);
INSERT INTO PharmacyDrug VALUES ('Nova South', 'Cardiozol', 'Zyphar Labs', 179.00);
INSERT INTO PharmacyDrug VALUES ('Nova South', 'Zypharin', 'Zyphar Labs', 209.00);
INSERT INTO PharmacyDrug VALUES ('Nova South', 'Panacure', 'Medivista', 85.00);
INSERT INTO PharmacyDrug VALUES ('Nova South', 'Zolstat', 'Zyphar Labs', 117.00);
INSERT INTO PharmacyDrug VALUES ('Nova South', 'Astrevit', 'Asterion Pharma', 69.00);
INSERT INTO PharmacyDrug VALUES ('Nova South', 'Neurovex', 'Medivista', 149.00);
INSERT INTO PharmacyDrug VALUES ('Nova South', 'Imunol', 'Zyphar Labs', 178.00);
INSERT INTO PharmacyDrug VALUES ('Nova East', 'Cardiozol', 'Zyphar Labs', 180.00);
INSERT INTO PharmacyDrug VALUES ('Nova East', 'Zypharin', 'Zyphar Labs', 210.00);
INSERT INTO PharmacyDrug VALUES ('Nova East', 'MediCough', 'Medivista', 53.00);
INSERT INTO PharmacyDrug VALUES ('Nova East', 'Dermaclear', 'Asterion Pharma', 96.00);
INSERT INTO PharmacyDrug VALUES ('Nova East', 'Asteflox', 'Asterion Pharma', 131.00);
INSERT INTO PharmacyDrug VALUES ('Nova East', 'Panacure', 'Medivista', 83.00);
INSERT INTO PharmacyDrug VALUES ('Nova East', 'Zolstat', 'Zyphar Labs', 121.00);
INSERT INTO PharmacyDrug VALUES ('Nova East', 'Astrevit', 'Asterion Pharma', 70.00);
INSERT INTO PharmacyDrug VALUES ('Nova East', 'Neurovex', 'Medivista', 150.00);
INSERT INTO PharmacyDrug VALUES ('Nova East', 'Imunol', 'Zyphar Labs', 172.00);

INSERT INTO Prescription (PatientID, DoctorID, PrescDate)
    VALUES ('P2101', 'D1001', DATE '2025-04-10');
INSERT INTO Prescription (PatientID, DoctorID, PrescDate)
    VALUES ('P2102', 'D1002', DATE '2025-04-12');
INSERT INTO Prescription (PatientID, DoctorID, PrescDate)
    VALUES ('P2103', 'D1003', DATE '2025-04-11');
INSERT INTO Prescription (PatientID, DoctorID, PrescDate)
    VALUES ('P2104', 'D1001', DATE '2025-04-13');

INSERT INTO PrescriptionDrug VALUES (1, 'Cardiozol', 'Zyphar Labs', 2);
INSERT INTO PrescriptionDrug VALUES (1, 'MediCough', 'Medivista', 1);
INSERT INTO PrescriptionDrug VALUES (2, 'Dermaclear', 'Asterion Pharma', 1);
INSERT INTO PrescriptionDrug VALUES (3, 'MediCough', 'Medivista', 2);
INSERT INTO PrescriptionDrug VALUES (3, 'Zypharin', 'Zyphar Labs', 1);
INSERT INTO PrescriptionDrug VALUES (4, 'Cardiozol', 'Zyphar Labs', 1);

INSERT INTO Contract (PharmacyName, PharmaName, StartDate, EndDate, Content, Supervisor)
    VALUES ('Nova Central', 'Zyphar Labs', DATE '2024-07-01', DATE '2026-07-01', 'Supply of cardiac drugs', 'D1001');
INSERT INTO Contract (PharmacyName, PharmaName, StartDate, EndDate, Content, Supervisor)
    VALUES ('Nova South', 'Asterion Pharma', DATE '2024-06-15', DATE '2026-06-15', 'Dermatology products supply', 'D1002');
INSERT INTO Contract (PharmacyName, PharmaName, StartDate, EndDate, Content, Supervisor)
    VALUES ('Nova East', 'Medivista', DATE '2024-08-10', DATE '2026-08-10', 'Cough and cold medicines', 'D1003');
INSERT INTO Contract (PharmacyName, PharmaName, StartDate, EndDate, Content, Supervisor)
    VALUES ('Nova East', 'Zyphar Labs', DATE '2025-01-01', DATE '2027-01-01', 'Exclusive cardiac drugs', 'D1001');

-- ================================
-- PROCEDURES FOR ADD, DELETE, UPDATE
-- ================================

-- Doctor
CREATE OR REPLACE PROCEDURE add_doctor(
    p_aadharid IN VARCHAR2,
    p_name IN VARCHAR2,
    p_specialty IN VARCHAR2,
    p_years_exp IN NUMBER,
    p_first_patient_id IN VARCHAR2
) IS
BEGIN
    INSERT INTO Doctor VALUES (p_aadharid, p_name, p_specialty, p_years_exp);
END;
/

CREATE OR REPLACE PROCEDURE delete_doctor(p_aadharid IN VARCHAR2) IS
BEGIN
    DELETE FROM Doctor WHERE AadharID = p_aadharid;
END;
/

CREATE OR REPLACE PROCEDURE update_doctor(
    p_aadharid IN VARCHAR2,
    p_name IN VARCHAR2,
    p_specialty IN VARCHAR2,
    p_years_exp IN NUMBER
) IS
BEGIN
    UPDATE Doctor
    SET Name = p_name, Specialty = p_specialty, YearsExperience = p_years_exp
    WHERE AadharID = p_aadharid;
END;
/

CREATE OR REPLACE TRIGGER no_patient_doctor
BEFORE DELETE ON Patient
FOR EACH ROW
DECLARE
    patient_count INTEGER;
BEGIN
    -- Count OTHER patients with the same doctor (excluding the one being deleted)
    SELECT COUNT(*) INTO patient_count
    FROM Patient
    WHERE PrimaryPhysID = :OLD.PrimaryPhysID
    AND AadharID != :OLD.AadharID;

    IF patient_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cannot delete the last patient of a doctor.');
    END IF;
END;
/

-- Patient
CREATE OR REPLACE PROCEDURE add_patient(
    p_aadharid IN VARCHAR2,
    p_name IN VARCHAR2,
    p_address IN VARCHAR2,
    p_age IN NUMBER,
    p_primary_phys IN VARCHAR2
) IS
BEGIN
    INSERT INTO Patient VALUES (p_aadharid, p_name, p_address, p_age, p_primary_phys);
END;
/
CREATE OR REPLACE PROCEDURE delete_patient(p_aadharid IN VARCHAR2) IS
BEGIN
    DELETE FROM Patient WHERE AadharID = p_aadharid;
END;
/
CREATE OR REPLACE PROCEDURE update_patient(
    p_aadharid IN VARCHAR2,
    p_name IN VARCHAR2,
    p_address IN VARCHAR2,
    p_age IN NUMBER,
    p_primary_phys IN VARCHAR2
) IS
BEGIN
    UPDATE Patient
    SET Name = p_name, Address = p_address, Age = p_age, PrimaryPhysID = p_primary_phys
    WHERE AadharID = p_aadharid;
END;
/

-- PharmaCompany
CREATE OR REPLACE PROCEDURE add_pharmaco(p_name IN VARCHAR2, p_phone IN VARCHAR2) IS
BEGIN
    INSERT INTO PharmaCompany VALUES (p_name, p_phone);
END;
/
CREATE OR REPLACE PROCEDURE delete_pharmaco(p_name IN VARCHAR2) IS
BEGIN
    DELETE FROM PharmaCompany WHERE Name = p_name;
END;
/
CREATE OR REPLACE PROCEDURE update_pharmaco(p_name IN VARCHAR2, p_phone IN VARCHAR2) IS
BEGIN
    UPDATE PharmaCompany SET PhoneNumber = p_phone WHERE Name = p_name;
END;
/

-- Pharmacy
CREATE OR REPLACE PROCEDURE add_pharmacy(
    p_name IN VARCHAR2,
    p_address IN VARCHAR2,
    p_phone IN VARCHAR2
) IS
BEGIN
    INSERT INTO Pharmacy VALUES (p_name, p_address, p_phone);
    dbms_output.put_line('Atleast 10 drugs must be added to PHARMACYDRUG table for this newly created Pharmacy');
END;
/
CREATE OR REPLACE PROCEDURE delete_pharmacy(p_name IN VARCHAR2) IS
BEGIN
    DELETE FROM Pharmacy WHERE Name = p_name;
END;
/
CREATE OR REPLACE PROCEDURE update_pharmacy(
    p_name IN VARCHAR2,
    p_address IN VARCHAR2,
    p_phone IN VARCHAR2
) IS
BEGIN
    UPDATE Pharmacy SET Address = p_address, Phone = p_phone WHERE Name = p_name;
END;
/

-- Drug
CREATE OR REPLACE PROCEDURE add_drug(
    p_tradename IN VARCHAR2,
    p_formula IN VARCHAR2,
    p_pharmaname IN VARCHAR2
) IS
BEGIN
    INSERT INTO Drug VALUES (p_tradename, p_formula, p_pharmaname);
END;
/
CREATE OR REPLACE PROCEDURE delete_drug(
    p_tradename IN VARCHAR2,
    p_pharmaname IN VARCHAR2
) IS
BEGIN
    DELETE FROM Drug WHERE TradeName = p_tradename AND PharmaName = p_pharmaname;
END;
/
CREATE OR REPLACE PROCEDURE update_drug(
    p_tradename IN VARCHAR2,
    p_pharmaname IN VARCHAR2,
    p_formula IN VARCHAR2
) IS
BEGIN
    UPDATE Drug SET Formula = p_formula WHERE TradeName = p_tradename AND PharmaName = p_pharmaname;
END;
/

-- PharmacyDrug
CREATE OR REPLACE PROCEDURE add_pharmacydrug(
    p_pharmacyname IN VARCHAR2,
    p_tradename IN VARCHAR2,
    p_pharmaname IN VARCHAR2,
    p_price IN NUMBER
) IS
BEGIN
    INSERT INTO PharmacyDrug VALUES (p_pharmacyname, p_tradename, p_pharmaname, p_price);
END;
/
CREATE OR REPLACE PROCEDURE delete_pharmacydrug(
    p_pharmacyname IN VARCHAR2,
    p_tradename IN VARCHAR2,
    p_pharmaname IN VARCHAR2
) IS
BEGIN
    DELETE FROM PharmacyDrug WHERE PharmacyName = p_pharmacyname AND TradeName = p_tradename AND PharmaName = p_pharmaname;
END;
/
CREATE OR REPLACE PROCEDURE update_pharmacydrug(
    p_pharmacyname IN VARCHAR2,
    p_tradename IN VARCHAR2,
    p_pharmaname IN VARCHAR2,
    p_price IN NUMBER
) IS
BEGIN
    UPDATE PharmacyDrug SET Price = p_price
    WHERE PharmacyName = p_pharmacyname AND TradeName = p_tradename AND PharmaName = p_pharmaname;
END;
/

CREATE OR REPLACE TRIGGER prevent_understocked_pharmacy
BEFORE DELETE ON PharmacyDrug
FOR EACH ROW
DECLARE
    drug_count INTEGER;
BEGIN
    -- Count the current number of drugs for this pharmacy
    SELECT COUNT(*) INTO drug_count
    FROM PharmacyDrug
    WHERE PharmacyName = :OLD.PharmacyName;
    
    -- If we currently have 10 or fewer drugs, prevent deletion
    -- as it would reduce count below the required minimum of 10
    IF drug_count <= 10 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Cannot delete drug - pharmacy must maintain at least 10 drugs.');
    END IF;
END;
/

-- Prescription
CREATE OR REPLACE PROCEDURE add_prescription(
    p_patientid IN VARCHAR2,
    p_doctorid IN VARCHAR2,
    p_prescdate IN DATE
) IS
BEGIN
    INSERT INTO Prescription (PatientID, DoctorID, PrescDate)
    VALUES (p_patientid, p_doctorid, p_prescdate);
END;
/
CREATE OR REPLACE PROCEDURE delete_prescription(p_prescid IN NUMBER) IS
BEGIN
    DELETE FROM Prescription WHERE PrescID = p_prescid;
END;
/
CREATE OR REPLACE PROCEDURE update_prescription(
    p_prescid IN NUMBER,
    p_patientid IN VARCHAR2,
    p_doctorid IN VARCHAR2,
    p_prescdate IN DATE
) IS
BEGIN
    UPDATE Prescription
    SET PatientID = p_patientid, DoctorID = p_doctorid, PrescDate = p_prescdate
    WHERE PrescID = p_prescid;
END;
/

-- PrescriptionDrug
CREATE OR REPLACE PROCEDURE add_prescriptiondrug(
    p_prescid IN NUMBER,
    p_tradename IN VARCHAR2,
    p_pharmaname IN VARCHAR2,
    p_quantity IN NUMBER
) IS
BEGIN
    INSERT INTO PrescriptionDrug VALUES (p_prescid, p_tradename, p_pharmaname, p_quantity);
END;
/
CREATE OR REPLACE PROCEDURE delete_prescriptiondrug(
    p_prescid IN NUMBER,
    p_tradename IN VARCHAR2,
    p_pharmaname IN VARCHAR2
) IS
BEGIN
    DELETE FROM PrescriptionDrug WHERE PrescID = p_prescid AND TradeName = p_tradename AND PharmaName = p_pharmaname;
END;
/
CREATE OR REPLACE PROCEDURE update_prescriptiondrug(
    p_prescid IN NUMBER,
    p_tradename IN VARCHAR2,
    p_pharmaname IN VARCHAR2,
    p_quantity IN NUMBER
) IS
BEGIN
    UPDATE PrescriptionDrug SET Quantity = p_quantity
    WHERE PrescID = p_prescid AND TradeName = p_tradename AND PharmaName = p_pharmaname;
END;
/

-- Contract
CREATE OR REPLACE PROCEDURE add_contract(
    p_pharmacyname IN VARCHAR2,
    p_pharmaname IN VARCHAR2,
    p_startdate IN DATE,
    p_enddate IN DATE,
    p_content IN VARCHAR2,
    p_supervisor IN VARCHAR2
) IS
BEGIN
    INSERT INTO Contract (PharmacyName, PharmaName, StartDate, EndDate, Content, Supervisor)
    VALUES (p_pharmacyname, p_pharmaname, p_startdate, p_enddate, p_content, p_supervisor);
END;
/
CREATE OR REPLACE PROCEDURE delete_contract(
    p_pharmacyname IN VARCHAR2,
    p_pharmaname IN VARCHAR2,
    p_startdate IN DATE
) IS
BEGIN
    DELETE FROM Contract WHERE PharmacyName = p_pharmacyname AND PharmaName = p_pharmaname AND StartDate = p_startdate;
END;
/
CREATE OR REPLACE PROCEDURE update_contract(
    p_pharmacyname IN VARCHAR2,
    p_pharmaname IN VARCHAR2,
    p_startdate IN DATE,
    p_enddate IN DATE,
    p_content IN VARCHAR2,
    p_supervisor IN VARCHAR2
) IS
BEGIN
    UPDATE Contract SET EndDate = p_enddate, Content = p_content, Supervisor = p_supervisor
    WHERE PharmacyName = p_pharmacyname AND PharmaName = p_pharmaname AND StartDate = p_startdate;
END;
/

-- ================================
-- REPORT/QUERY PROCEDURES (SPEC REQUIRED)
-- ================================

-- 2. Prescriptions of a patient in a given period
CREATE OR REPLACE PROCEDURE report_prescriptions_in_period(
    p_patientid IN VARCHAR2,
    p_start IN DATE,
    p_end IN DATE
) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Prescriptions for patient ' || p_patientid || ' from ' || p_start || ' to ' || p_end || ':');
    FOR rec IN (
        SELECT PrescID, DoctorID, PrescDate
        FROM Prescription
        WHERE PatientID = p_patientid AND PrescDate BETWEEN p_start AND p_end
        ORDER BY PrescDate
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('PrescID: ' || rec.PrescID || ', DoctorID: ' || rec.DoctorID || ', Date: ' || rec.PrescDate);
    END LOOP;
END;
/

-- 3. Details of a prescription for a patient on a given date
CREATE OR REPLACE PROCEDURE report_prescription_details(
    p_patientid IN VARCHAR2,
    p_date IN DATE
) IS
    v_prescid NUMBER;
BEGIN
    SELECT PrescID INTO v_prescid
    FROM Prescription
    WHERE PatientID = p_patientid AND PrescDate = p_date;

    DBMS_OUTPUT.PUT_LINE('Prescription ID: ' || v_prescid);
    FOR rec IN (
        SELECT pd.TradeName, pd.PharmaName, pd.Quantity
        FROM PrescriptionDrug pd
        WHERE pd.PrescID = v_prescid
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Drug: ' || rec.TradeName || ' (' || rec.PharmaName || '), Quantity: ' || rec.Quantity);
    END LOOP;
END;
/

-- 4. Details of drugs produced by a pharmaceutical company
CREATE OR REPLACE PROCEDURE report_drugs_by_company(
    p_pharmaname IN VARCHAR2
) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Drugs produced by ' || p_pharmaname || ':');
    FOR rec IN (
        SELECT TradeName, Formula
        FROM Drug
        WHERE PharmaName = p_pharmaname
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('TradeName: ' || rec.TradeName || ', Formula: ' || rec.Formula);
    END LOOP;
END;
/

-- 5. Stock position of a pharmacy
CREATE OR REPLACE PROCEDURE report_pharmacy_stock(
    p_pharmacyname IN VARCHAR2
) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Stock at pharmacy ' || p_pharmacyname || ':');
    FOR rec IN (
        SELECT TradeName, PharmaName, Price
        FROM PharmacyDrug
        WHERE PharmacyName = p_pharmacyname
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Drug: ' || rec.TradeName || ' (' || rec.PharmaName || '), Price: ' || rec.Price);
    END LOOP;
END;
/

-- 6. Contact details of a pharmacy-pharmaceutical company
CREATE OR REPLACE PROCEDURE report_contract_details(
    p_pharmacyname IN VARCHAR2,
    p_pharmaname IN VARCHAR2
) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Contracts between ' || p_pharmacyname || ' and ' || p_pharmaname || ':');
    FOR rec IN (
        SELECT StartDate, EndDate, Content, Supervisor
        FROM Contract
        WHERE PharmacyName = p_pharmacyname AND PharmaName = p_pharmaname
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Start: ' || rec.StartDate || ', End: ' || rec.EndDate || ', Supervisor: ' || rec.Supervisor || ', Content: ' || rec.Content);
    END LOOP;
END;
/

-- 7. List of patients for a given doctor
CREATE OR REPLACE PROCEDURE report_patients_for_doctor(
    p_doctorid IN VARCHAR2
) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Patients for doctor ' || p_doctorid || ':');
    FOR rec IN (
        SELECT AadharID, Name
        FROM Patient
        WHERE PrimaryPhysID = p_doctorid
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('PatientID: ' || rec.AadharID || ', Name: ' || rec.Name);
    END LOOP;
END;
/