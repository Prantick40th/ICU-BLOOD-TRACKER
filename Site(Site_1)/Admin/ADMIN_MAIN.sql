SET VERIFY OFF;
SET SERVEROUTPUT ON;

--TAKE INPUT FROM USERS
ACCEPT ADMINPERMISSION NUMBER PROMPT "press 1 for login  : "
ACCEPT ADMINHOSPITALNAME CHAR PROMPT "enter your hospital name :"
ACCEPT ADMINEMAIL CHAR PROMPT "enter your email :"
ACCEPT ADMINPASSWORD CHAR PROMPT "enter your password :"
ACCEPT PATIENTREMOVE NUMBER PROMPT "if you want to release patient press 2 :"
ACCEPT PATIENTREMOVEID NUMBER PROMPT "enter the patientid :"

--CREATE PACKAGE
CREATE OR REPLACE PACKAGE adminpack AS
	FUNCTION adminfunc(N IN NUMBER,
		 H_NAME IN JOINTABLE.HospitalName%TYPE,
		 A_EMAIL IN ADMINTABLE.AdminEmail%TYPE,
		 A_PASSWORD IN ADMINTABLE.Password%TYPE,
		 A IN NUMBER,
		 B IN PATIENTINFOTABLE.PatientId%TYPE)
    RETURN NUMBER;
END adminpack;
/

--CREATE PACKAGE BODY
CREATE OR REPLACE PACKAGE BODY adminpack AS
	FUNCTION adminfunc(N IN NUMBER,
		H_NAME IN JOINTABLE.HospitalName%TYPE,
		A_EMAIL IN ADMINTABLE.AdminEmail%TYPE,
		A_PASSWORD IN ADMINTABLE.Password%TYPE,
		A IN NUMBER,
		B IN PATIENTINFOTABLE.PatientId%TYPE)
	RETURN NUMBER
IS 
	CHECKNUMBER NUMBER;
	ID PATIENTINFOTABLE.HospitalId%TYPE;
	ICUNUMBER NUMBER;
	FLAG NUMBER;
	S varchar2(10);
	new_S varchar2(10);
	DATANOTMATCH EXCEPTION;
	ALREADYREMOVED EXCEPTION;
	
BEGIN 

--press 1 for login

IF N=1 THEN 
CHECKNUMBER:=0;
FLAG:=0;
S:='NO';

FOR R IN (SELECT * FROM JOINTABLE) LOOP
	IF R.HospitalName=H_NAME AND R.AdminEmail= A_EMAIL AND R.Password=A_PASSWORD THEN
		CHECKNUMBER:=1;
		ID:=R.HospitalId;
		
        FOR R IN (SELECT * FROM PATIENTINFOTABLE) LOOP
            IF R.HospitalId=ID then
               DBMS_OUTPUT.PUT_LINE('---------Patient ID: '||R.PatientId||'-----------');
               DBMS_OUTPUT.PUT_LINE('Name: '||R.PatientName);
               DBMS_OUTPUT.PUT_LINE('Email: '||R.PatientEmail);
	           DBMS_OUTPUT.PUT_LINE('Address: '||R.Address);
	           DBMS_OUTPUT.PUT_LINE('Contact: '||R.PhoneNumber);
	           DBMS_OUTPUT.PUT_LINE('Status: '||R.ADMITTEDSTATUS);
			   DBMS_OUTPUT.PUT_LINE('--------------------------');
			     IF B= R.PatientId THEN
			     FLAG:=1;
			     END IF;
            END IF;
        END LOOP;
		   
--press 2 for release patient
		   
	    IF A=2 AND FLAG =1 THEN 
	      ICUNUMBER:=R.IcuBedCapacity;
          ICUNUMBER:=ICUNUMBER+1;
		  
		  SELECT PATIENTINFOTABLE.ADMITTEDSTATUS into new_S FROM PATIENTINFOTABLE where PATIENTINFOTABLE.PatientId=B;
		  
		  IF new_s = 'NO' THEN 
			RAISE ALREADYREMOVED;
			EXIT;
		  END IF;
	
	      UPDATE HOSPITALINFOTABLE@site2 SET HOSPITALINFOTABLE.IcuBedCapacity=ICUNUMBER WHERE HOSPITALINFOTABLE.HospitalId=ID;
	      UPDATE PATIENTINFOTABLE SET PATIENTINFOTABLE.ADMITTEDSTATUS=S WHERE PATIENTINFOTABLE.PatientId=B;
		  
		  DBMS_OUTPUT.PUT_LINE(' ');
	      DBMS_OUTPUT.PUT_LINE('-------------Upadated PatientId: ' ||B||'------------');
		  DBMS_OUTPUT.PUT_LINE('DATA UPDATED TO STATUS: NO'); 
	    END IF;
    EXIT;
				
	ELSIF CHECKNUMBER=0 THEN 
		RAISE DATANOTMATCH;	
    END IF;
			
END LOOP;
END IF;

RETURN 1;

--EXCEPTION RAISE
EXCEPTION
WHEN DATANOTMATCH THEN
     DBMS_OUTPUT.PUT_LINE('DATA NOT MATCH WITH GIVEN DATA AND EXCEPTION RAISE' );
WHEN ALREADYREMOVED THEN
	DBMS_OUTPUT.PUT_LINE('DATA REMOVED ALREADY AND EXCEPTION RAISE' );
		
RETURN 1;

	END adminfunc;
END adminpack;
 /
 
 --CREATE TRIGGER
 CREATE OR REPLACE TRIGGER admintri1
 BEFORE UPDATE
 ON PATIENTINFOTABLE
 DECLARE
 BEGIN
   DBMS_OUTPUT.PUT_LINE('TRIGGER AND SUCCESSFULLY UPDATE DATA');
 END;
/
 
DECLARE
	N  NUMBER;
	H_NAME  JOINTABLE.HospitalName%TYPE;
	A_EMAIL  ADMINTABLE.AdminEmail%TYPE;
	A_PASSWORD  ADMINTABLE.Password%TYPE;
	A NUMBER;
	B PATIENTINFOTABLE.PatientId%TYPE;
	R NUMBER;

BEGIN
	N:= &ADMINPERMISSION;
	H_NAME:= '& ADMINHOSPITALNAME';
	A_EMAIL:='&ADMINEMAIL';
	A_PASSWORD:= '&ADMINPASSWORD';
	A:=&PATIENTREMOVE;
	B:=&PATIENTREMOVEID;

	R:=adminpack.adminfunc(N,H_NAME,A_EMAIL,A_PASSWORD,A,B);
END;
/
COMMIT;