-- Problem 1a

SELECT * FROM lung_treatment;
/

-- Problem 1b

create type treatment as object(
    trt_numc number,
    trt_familyc number,
    neoadjuvant number,
    trt_days number
);
/

-- above is the type...
-- need a table for the type as well...
create type treat_table as table of treatment;
/
-- edit: didn't work; would have needed "BULK COLLECT", which we haven't used.
-- https://stackoverflow.com/questions/42844699/ora-00932-on-oracle-function-with-a-udt

-- Problem 1c

create table LUNG_VITD__PATIENTS(
    PLCO_ID varchar2(26),
    TREATMENT_INFO treatment,
    primary key (PLCO_ID)
);
/

-- Problem 1d

-- need two queries... trying to get all the data at once will make more appear
-- first one will get the 524 IDs...

select distinct plco_id
from lung_treatment
where plco_id in
(select distinct V.plco_id from vitamind_primary V);
/

-- the above works

-- second one will get the data for those IDs...

select trt_numl, trt_familyl, neoadjuvant, trt_days
from lung_treatment
where plco_id = 'A-146285-3' and rownum <= 1;
/

-- this will also work... but we will need to loop through each PLCO_ID
-- so store it into a variable

-- then we use the program to insert

declare
    current_id varchar2(26);
begin
    for lung_and_vitd_patient in 
        (
        select distinct plco_id
        from lung_treatment
        where plco_id in
        (select distinct V.plco_id from vitamind_primary V)
        )
    loop
    if lung_and_vitd_patient.plco_id is not null then
        current_id := lung_and_vitd_patient.plco_id;
        for patient_info in 
            (
            select trt_numl, trt_familyl, neoadjuvant, trt_days
            from lung_treatment
            where plco_id = current_id and rownum <= 1
            )
        loop
            insert into lung_vitd__patients
            values(
            current_id,
            treatment(
            patient_info.trt_numl,
            patient_info.trt_familyl,
            patient_info.neoadjuvant,
            patient_info.trt_days
            )
            );
        end loop;
    end if;
    end loop;
end;
/

select 
lvp.plco_id, 
lvp.treatment_info.trt_numc as trt_numc, 
lvp.treatment_info.trt_familyc as trt_familyc,
lvp.treatment_info.neoadjuvant as neoadjuvant,
lvp.treatment_info.trt_days as trt_days
from lung_vitd__patients lvp 
where rownum <= 10;
/

-- Problem 2a

select plco_id, -- varchar2
sqx_age, -- number
sqx_days, -- number
sqx_income, -- number
sqx_bmi_curc, -- number
sqx_height -- number
from patient 
where sqx_valid = 1 
and rownum <= 10;
/

-- this is query to base the table on...
-- first, need table... one column

create table PATIENT_XML(
	patient_info xmltype
);
/

-- now the PL/SQL program...

declare
    current_id varchar2(26);
    current_age number; -- specific number
    current_days number; -- specific number
    current_income number;
    -- can be null, so (null) = "Blank"
    -- 1="< $20,000" 
    -- 2="$20,000-$49,000" 
    -- 3="$50,000-$99,000" 
    -- 4="$100,000-$200,000" 
    -- 5=">$200,000" 
    -- 6="Prefer not to Answer"
    current_bmi number;
    -- can be null, so (null) = "Blank"
    -- 1="0-18.5" 
    -- 2="> 18.5-25" 
    -- 3="> 25-30" 
    -- 4="> 30"
    current_height number;
    -- specific number
    -- can be null, so (null) = "Blank"
begin
    for new_patient in 
        (
        select plco_id, sqx_age, sqx_days, sqx_income, sqx_bmi_curc, sqx_height 
        from patient 
        where sqx_valid = 1
        )
    loop
    if new_patient.plco_id is not null then
        current_id := new_patient.plco_id;
        current_age := new_patient.sqx_age; 
        current_days := new_patient.sqx_days; 
        current_income := new_patient.sqx_income; -- can be null
        current_bmi := new_patient.sqx_bmi_curc; -- can be null
        current_height := new_patient.sqx_height; -- can be null
        -- 000, 001, 010, 011, 100, 101, 110, 111
        if current_income is not null 
        and current_bmi is not null 
        and current_height is not null then -- 111
            insert into PATIENT_XML values(
                XMLType.createXML(
                '<patient>
                    <PLCO_ID>' || current_id || '</PLCO_ID>
                    <sqx_age>' || current_age || '</sqx_age>
                    <sqx_days>' || current_days || '</sqx_days>
                    <sqx_income>' || current_income || '</sqx_income>
                    <sqx_bmi_curc>' || current_bmi || '</sqx_bmi_curc>
                    <sqx_height>' || current_height || '</sqx_height>
                </patient>'
            )
            );
        elsif current_income is not null 
        and current_bmi is not null 
        and current_height is null then -- 110
            insert into PATIENT_XML values(
                XMLType.createXML(
                '<patient>
                    <PLCO_ID>' || current_id || '</PLCO_ID>
                    <sqx_age>' || current_age || '</sqx_age>
                    <sqx_days>' || current_days || '</sqx_days>
                    <sqx_income>' || current_income || '</sqx_income>
                    <sqx_bmi_curc>' || current_bmi || '</sqx_bmi_curc>
                    <sqx_height>null</sqx_height>
                </patient>'
            )
            );
        elsif current_income is not null 
        and current_bmi is null 
        and current_height is not null then -- 101
            insert into PATIENT_XML values(
                XMLType.createXML(
                '<patient>
                    <PLCO_ID>' || current_id || '</PLCO_ID>
                    <sqx_age>' || current_age || '</sqx_age>
                    <sqx_days>' || current_days || '</sqx_days>
                    <sqx_income>' || current_income || '</sqx_income>
                    <sqx_bmi_curc>null</sqx_bmi_curc>
                    <sqx_height>' || current_height || '</sqx_height>
                </patient>'
            )
            );
        elsif current_income is not null 
        and current_bmi is null 
        and current_height is null then -- 100
            insert into PATIENT_XML values(
                XMLType.createXML(
                '<patient>
                    <PLCO_ID>' || current_id || '</PLCO_ID>
                    <sqx_age>' || current_age || '</sqx_age>
                    <sqx_days>' || current_days || '</sqx_days>
                    <sqx_income>' || current_income || '</sqx_income>
                    <sqx_bmi_curc>null</sqx_bmi_curc>
                    <sqx_height>null</sqx_height>
                </patient>'
            )
            );
        elsif current_income is null 
        and current_bmi is not null 
        and current_height is not null then -- 011
            insert into PATIENT_XML values(
                XMLType.createXML(
                '<patient>
                    <PLCO_ID>' || current_id || '</PLCO_ID>
                    <sqx_age>' || current_age || '</sqx_age>
                    <sqx_days>' || current_days || '</sqx_days>
                    <sqx_income>null</sqx_income>
                    <sqx_bmi_curc>' || current_bmi || '</sqx_bmi_curc>
                    <sqx_height>' || current_height || '</sqx_height>
                </patient>'
            )
            );
        elsif current_income is null 
        and current_bmi is not null 
        and current_height is null then -- 010
            insert into PATIENT_XML values(
                XMLType.createXML(
                '<patient>
                    <PLCO_ID>' || current_id || '</PLCO_ID>
                    <sqx_age>' || current_age || '</sqx_age>
                    <sqx_days>' || current_days || '</sqx_days>
                    <sqx_income>null</sqx_income>
                    <sqx_bmi_curc>' || current_bmi || '</sqx_bmi_curc>
                    <sqx_height>null</sqx_height>
                </patient>'
            )
            );
        elsif current_income is null 
        and current_bmi is null 
        and current_height is not null then -- 001
            insert into PATIENT_XML values(
                XMLType.createXML(
                '<patient>
                    <PLCO_ID>' || current_id || '</PLCO_ID>
                    <sqx_age>' || current_age || '</sqx_age>
                    <sqx_days>' || current_days || '</sqx_days>
                    <sqx_income>null</sqx_income>
                    <sqx_bmi_curc>null</sqx_bmi_curc>
                    <sqx_height>' || current_height || '</sqx_height>
                </patient>'
            )
            );
        elsif current_income is null 
        and current_bmi is null 
        and current_height is null then -- 000
            insert into PATIENT_XML values(
                XMLType.createXML(
                '<patient>
                    <PLCO_ID>' || current_id || '</PLCO_ID>
                    <sqx_age>' || current_age || '</sqx_age>
                    <sqx_days>' || current_days || '</sqx_days>
                    <sqx_income>null</sqx_income>
                    <sqx_bmi_curc>null</sqx_bmi_curc>
                    <sqx_height>null</sqx_height>
                </patient>'
            )
            );
        end if;
    end if;
    end loop;
end;
/

-- verifying that data was inserted correctly...

select p.patient_info.extract('/').getstringval() 
from PATIENT_XML p 
where rownum <= 10;
/

-- Problem 2b

-- just print the table to dbms output...
-- build the query for the for loop...

select 
p.patient_info.extract('//PLCO_ID/text()').getstringval() as PLCO_ID,
p.patient_info.extract('//sqx_age/text()').getstringval() as sqx_age,
p.patient_info.extract('//sqx_days/text()').getstringval() as sqx_days,
p.patient_info.extract('//sqx_income/text()').getstringval() as sqx_income,
p.patient_info.extract('//sqx_bmi_curc/text()').getstringval() as sqx_bmi_curc,
p.patient_info.extract('//sqx_height/text()').getstringval() as sqx_height
from PATIENT_XML p 
where rownum <= 10;
/

-- now the program...
-- just have to fix the income this time, NOT the BMI or height
    -- can be null, so (null) = "Blank"
    -- 1="< $20,000" 
    -- 2="$20,000-$49,000" 
    -- 3="$50,000-$99,000" 
    -- 4="$100,000-$200,000" 
    -- 5=">$200,000" 
    -- 6="Prefer not to Answer"
begin
    for a_patient in 
    (select 
    p.patient_info.extract('//PLCO_ID/text()').getstringval() as plco_id,
    p.patient_info.extract('//sqx_age/text()').getstringval() as sqx_age,
    p.patient_info.extract('//sqx_days/text()').getstringval() as sqx_days,
    p.patient_info.extract('//sqx_income/text()').getstringval() as sqx_income,
    p.patient_info.extract('//sqx_bmi_curc/text()').getstringval() as sqx_bmi_curc,
    p.patient_info.extract('//sqx_height/text()').getstringval() as sqx_height
    from PATIENT_XML p 
    where rownum <= 10
    )
    loop
        if a_patient.sqx_income = 'null' then
            dbms_output.put_line(
            'PLCO_ID                 is ' || a_patient.plco_id || chr(13)
            || 'Age                     is ' || a_patient.sqx_age || chr(13)
            || 'Days to the completion  is ' || a_patient.sqx_days || chr(13)
            || 'Income                  is Blank' || chr(13)
            || 'Current BMI             is ' || a_patient.sqx_bmi_curc || chr(13)
            || 'Current height          is ' || a_patient.sqx_height || chr(13)
            || chr(13)
            );
        elsif a_patient.sqx_income = 1 then
            dbms_output.put_line(
            'PLCO_ID                 is ' || a_patient.plco_id || chr(13)
            || 'Age                     is ' || a_patient.sqx_age || chr(13)
            || 'Days to the completion  is ' || a_patient.sqx_days || chr(13)
            || 'Income                  is < $20,000' || chr(13)
            || 'Current BMI             is ' || a_patient.sqx_bmi_curc || chr(13)
            || 'Current height          is ' || a_patient.sqx_height || chr(13)
            || chr(13)
            );
        elsif a_patient.sqx_income = 2 then
            dbms_output.put_line(
            'PLCO_ID                 is ' || a_patient.plco_id || chr(13)
            || 'Age                     is ' || a_patient.sqx_age || chr(13)
            || 'Days to the completion  is ' || a_patient.sqx_days || chr(13)
            || 'Income                  is $20,000-$49,000' || chr(13)
            || 'Current BMI             is ' || a_patient.sqx_bmi_curc || chr(13)
            || 'Current height          is ' || a_patient.sqx_height || chr(13)
            || chr(13)
            );
        elsif a_patient.sqx_income = 3 then
            dbms_output.put_line(
            'PLCO_ID                 is ' || a_patient.plco_id || chr(13)
            || 'Age                     is ' || a_patient.sqx_age || chr(13)
            || 'Days to the completion  is ' || a_patient.sqx_days || chr(13)
            || 'Income                  is $50,000-$99,000' || chr(13)
            || 'Current BMI             is ' || a_patient.sqx_bmi_curc || chr(13)
            || 'Current height          is ' || a_patient.sqx_height || chr(13)
            || chr(13)
            );
        elsif a_patient.sqx_income = 4 then
            dbms_output.put_line(
            'PLCO_ID                 is ' || a_patient.plco_id || chr(13)
            || 'Age                     is ' || a_patient.sqx_age || chr(13)
            || 'Days to the completion  is ' || a_patient.sqx_days || chr(13)
            || 'Income                  is $100,000-$200,000' || chr(13)
            || 'Current BMI             is ' || a_patient.sqx_bmi_curc || chr(13)
            || 'Current height          is ' || a_patient.sqx_height || chr(13)
            || chr(13)
            );
        elsif a_patient.sqx_income = 5 then
            dbms_output.put_line(
            'PLCO_ID                 is ' || a_patient.plco_id || chr(13)
            || 'Age                     is ' || a_patient.sqx_age || chr(13)
            || 'Days to the completion  is ' || a_patient.sqx_days || chr(13)
            || 'Income                  is >$200,000' || chr(13)
            || 'Current BMI             is ' || a_patient.sqx_bmi_curc || chr(13)
            || 'Current height          is ' || a_patient.sqx_height || chr(13)
            || chr(13)
            );
        elsif a_patient.sqx_income = 6 then
            dbms_output.put_line(
            'PLCO_ID                 is ' || a_patient.plco_id || chr(13)
            || 'Age                     is ' || a_patient.sqx_age || chr(13)
            || 'Days to the completion  is ' || a_patient.sqx_days || chr(13)
            || 'Income                  is Prefer not to Answer' || chr(13)
            || 'Current BMI             is ' || a_patient.sqx_bmi_curc || chr(13)
            || 'Current height          is ' || a_patient.sqx_height || chr(13)
            || chr(13)
            );
        end if;
    end loop;
end;
/

-- Problem 2c

select 
p.patient_info.extract('//PLCO_ID/text()').getstringval() as plco_id,
p.patient_info.extract('//sqx_age/text()').getstringval() as sqx_age,
p.patient_info.extract('//sqx_days/text()').getstringval() as sqx_days,
p.patient_info.extract('//sqx_income/text()').getstringval() as sqx_income,
p.patient_info.extract('//sqx_bmi_curc/text()').getstringval() as sqx_bmi_curc,
p.patient_info.extract('//sqx_height/text()').getstringval() as sqx_height
from PATIENT_XML p 
where p.patient_info.extract('//sqx_age/text()').getstringval() >= 75
and rownum <= 10;
/

-- Problem 3a

select plco_id, -- varchar2
sqx_age, -- number
sqx_days, -- number
sqx_income, -- number
sqx_bmi_curc, -- number
sqx_height -- number
from patient 
where sqx_valid = 1 
and rownum <= 10;
/

-- this is query to base the table on...
-- first, need table... one column

create table PATIENT_JSON(
	PATIENTJSON CLOB
    constraint c2 check (PATIENTJSON is JSON)
);
/

-- this time, just insert four rows

insert into PATIENT_JSON values( 
   '{ 
      "PLCO_ID" : "A-002879-7", 
      "sqx_age" : 75, 
      "sqx_days" : 4337,
      "sqx_income" : 2,
      "sqx_bmi_curc" : 2,
      "sqx_height" : 64,
    }'
); 
/

insert into PATIENT_JSON values( 
   '{ 
      "PLCO_ID" : "A-002978-7", 
      "sqx_age" : 78, 
      "sqx_days" : 2350,
      "sqx_income" : 3,
      "sqx_bmi_curc" : 2,
      "sqx_height" : 72,
    }'
); 
/

insert into PATIENT_JSON values( 
   '{ 
      "PLCO_ID" : "A-003788-9", 
      "sqx_age" : 63, 
      "sqx_days" : 2654,
      "sqx_income" : 2,
      "sqx_bmi_curc" : 3,
      "sqx_height" : 66,
    }'
); 
/

insert into PATIENT_JSON values( 
   '{ 
      "PLCO_ID" : "A-003869-7", 
      "sqx_age" : 63, 
      "sqx_days" : 2938,
      "sqx_income" : 2,
      "sqx_bmi_curc" : 4,
      "sqx_height" : 65,
    }'
); 
/

-- Problem 3b

-- just print the table to dbms output...
-- build the query for the for loop...

select 
p.PATIENTJSON.PLCO_ID,
p.PATIENTJSON.sqx_age,
p.PATIENTJSON.sqx_days,
p.PATIENTJSON.sqx_income,
p.PATIENTJSON.sqx_bmi_curc,
p.PATIENTJSON.sqx_height
from PATIENT_JSON p where p.PATIENTJSON is JSON;
/

-- now the program...
-- again, just have to fix the income this time, NOT the BMI or height
    -- can be null, so (null) = "Blank"
    -- 1="< $20,000" 
    -- 2="$20,000-$49,000" 
    -- 3="$50,000-$99,000" 
    -- 4="$100,000-$200,000" 
    -- 5=">$200,000" 
    -- 6="Prefer not to Answer"
begin
    for next_patient in 
    (select 
    p.PATIENTJSON.PLCO_ID,
    p.PATIENTJSON.sqx_age,
    p.PATIENTJSON.sqx_days,
    p.PATIENTJSON.sqx_income,
    p.PATIENTJSON.sqx_bmi_curc,
    p.PATIENTJSON.sqx_height
    from PATIENT_JSON p where p.PATIENTJSON is JSON
    )
    loop
        if next_patient.sqx_income = 'null' then
            dbms_output.put_line(
            'PLCO_ID                 is ' || next_patient.plco_id || chr(13)
            || 'Age                     is ' || next_patient.sqx_age || chr(13)
            || 'Days to the completion  is ' || next_patient.sqx_days || chr(13)
            || 'Income                  is Blank' || chr(13)
            || 'Current BMI             is ' || next_patient.sqx_bmi_curc || chr(13)
            || 'Current height          is ' || next_patient.sqx_height || chr(13)
            || chr(13)
            );
        elsif next_patient.sqx_income = 1 then
            dbms_output.put_line(
            'PLCO_ID                 is ' || next_patient.plco_id || chr(13)
            || 'Age                     is ' || next_patient.sqx_age || chr(13)
            || 'Days to the completion  is ' || next_patient.sqx_days || chr(13)
            || 'Income                  is < $20,000' || chr(13)
            || 'Current BMI             is ' || next_patient.sqx_bmi_curc || chr(13)
            || 'Current height          is ' || next_patient.sqx_height || chr(13)
            || chr(13)
            );
        elsif next_patient.sqx_income = 2 then
            dbms_output.put_line(
            'PLCO_ID                 is ' || next_patient.plco_id || chr(13)
            || 'Age                     is ' || next_patient.sqx_age || chr(13)
            || 'Days to the completion  is ' || next_patient.sqx_days || chr(13)
            || 'Income                  is $20,000-$49,000' || chr(13)
            || 'Current BMI             is ' || next_patient.sqx_bmi_curc || chr(13)
            || 'Current height          is ' || next_patient.sqx_height || chr(13)
            || chr(13)
            );
        elsif next_patient.sqx_income = 3 then
            dbms_output.put_line(
            'PLCO_ID                 is ' || next_patient.plco_id || chr(13)
            || 'Age                     is ' || next_patient.sqx_age || chr(13)
            || 'Days to the completion  is ' || next_patient.sqx_days || chr(13)
            || 'Income                  is $50,000-$99,000' || chr(13)
            || 'Current BMI             is ' || next_patient.sqx_bmi_curc || chr(13)
            || 'Current height          is ' || next_patient.sqx_height || chr(13)
            || chr(13)
            );
        elsif next_patient.sqx_income = 4 then
            dbms_output.put_line(
            'PLCO_ID                 is ' || next_patient.plco_id || chr(13)
            || 'Age                     is ' || next_patient.sqx_age || chr(13)
            || 'Days to the completion  is ' || next_patient.sqx_days || chr(13)
            || 'Income                  is $100,000-$200,000' || chr(13)
            || 'Current BMI             is ' || next_patient.sqx_bmi_curc || chr(13)
            || 'Current height          is ' || next_patient.sqx_height || chr(13)
            || chr(13)
            );
        elsif next_patient.sqx_income = 5 then
            dbms_output.put_line(
            'PLCO_ID                 is ' || next_patient.plco_id || chr(13)
            || 'Age                     is ' || next_patient.sqx_age || chr(13)
            || 'Days to the completion  is ' || next_patient.sqx_days || chr(13)
            || 'Income                  is >$200,000' || chr(13)
            || 'Current BMI             is ' || next_patient.sqx_bmi_curc || chr(13)
            || 'Current height          is ' || next_patient.sqx_height || chr(13)
            || chr(13)
            );
        elsif next_patient.sqx_income = 6 then
            dbms_output.put_line(
            'PLCO_ID                 is ' || next_patient.plco_id || chr(13)
            || 'Age                     is ' || next_patient.sqx_age || chr(13)
            || 'Days to the completion  is ' || next_patient.sqx_days || chr(13)
            || 'Income                  is Prefer not to Answer' || chr(13)
            || 'Current BMI             is ' || next_patient.sqx_bmi_curc || chr(13)
            || 'Current height          is ' || next_patient.sqx_height || chr(13)
            || chr(13)
            );
        end if;
    end loop;
end;
/