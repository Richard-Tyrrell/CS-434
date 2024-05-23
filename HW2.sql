SELECT * FROM patient;
/
SELECT * FROM vitamind_primary;
/

-- Problem 1a

-- implicit cursor
-- show all patient...
    -- PLCO_IDs
    -- ages
        -- this comes from sqx (patient) table...
    -- number of days from randomization to completion date
        -- this comes from vitamind_primary table...
    -- eligibility and compliance of the form (sqx_status)
        -- this comes from sqx (patient) table...
-- patients must have...
    -- vitamin d study group is colon
        -- vitd_study = 13
    -- vitamin d seasonal calendar year of blood collection is 2000
        -- vitd_draw_seasonal_year = 2000
    -- # of 25-hydroxyvitamind d measure (ng/ml) is > 20
        -- vitd_OH25D_ng_ml again
    
begin 
   for new_patient in
        (select p.plco_id, p.sqx_age, p.sqx_days, p.sqx_status
        from patient p, vitamind_primary v
        where p.plco_id=v.plco_id 
        and v.vitd_study = 13
        and v.vitd_draw_seasonal_year = 2000 
        and v.vitd_OH25D_ng_ml > 20 
        and rownum <= 10) 
   loop
        if new_patient.sqx_age is not null then
            if new_patient.sqx_days is null then
                if new_patient.sqx_status = 1 then
                    dbms_output.put_line(
                    'PLCO_ID= ' || new_patient.plco_id
                    || '     Age = ' || new_patient.sqx_age
                    || '           #_of_days = unknown'
                    || '        Eligibility of the form = Valid');
                elsif new_patient.sqx_status = 3 then
                    dbms_output.put_line(
                    'PLCO_ID= ' || new_patient.plco_id
                    || '     Age = ' || new_patient.sqx_age
                    || '           #_of_days = unknown'
                    || '     Eligibility of the form = Non-eligible');
                elsif new_patient.sqx_status = 4 then
                    dbms_output.put_line(
                    'PLCO_ID= ' || new_patient.plco_id
                    || '     Age = ' || new_patient.sqx_age
                    || '           #_of_days = unknown'
                    || '     Eligibility of the form = Non-compliant');
                else
                    dbms_output.put_line(
                    'PLCO_ID= ' || new_patient.plco_id
                    || '     Age = ' || new_patient.sqx_age
                    || '           #_of_days = unknown'
                    || '     Eligibility of the form = Invalid');
                end if;
            else
                if new_patient.sqx_status = 1 then
                    dbms_output.put_line(
                    'PLCO_ID= ' || new_patient.plco_id
                    || '     Age = ' || new_patient.sqx_age
                    || '           #_of_days = ' || new_patient.sqx_days
                    || '        Eligibility of the form = Valid');
                elsif new_patient.sqx_status = 3 then
                    dbms_output.put_line(
                    'PLCO_ID= ' || new_patient.plco_id
                    || '     Age = ' || new_patient.sqx_age
                    || '           #_of_days = ' || new_patient.sqx_days
                    || '     Eligibility of the form = Non-eligible');
                elsif new_patient.sqx_status = 4 then
                    dbms_output.put_line(
                    'PLCO_ID= ' || new_patient.plco_id
                    || '     Age = ' || new_patient.sqx_age
                    || '           #_of_days = ' || new_patient.sqx_days
                    || '     Eligibility of the form = Non-compliant');
                else
                    dbms_output.put_line(
                    'PLCO_ID= ' || new_patient.plco_id
                    || '     Age = ' || new_patient.sqx_age
                    || '           #_of_days = ' || new_patient.sqx_days
                    || '     Eligibility of the form = Invalid');
                end if;
            end if;
        else
            if new_patient.sqx_days is null then
                if new_patient.sqx_status = 1 then
                    dbms_output.put_line(
                    'PLCO_ID= ' || new_patient.plco_id
                    || '     Age = unknown'
                    || '      #_of_days = unknown'
                    || '     Eligibility of the form = Valid');
                elsif new_patient.sqx_status = 3 then
                    dbms_output.put_line(
                    'PLCO_ID= ' || new_patient.plco_id
                    || '     Age = unknown'
                    || '      #_of_days = unknown'
                    || '     Eligibility of the form = Non-eligible');
                elsif new_patient.sqx_status = 4 then
                    dbms_output.put_line(
                    'PLCO_ID= ' || new_patient.plco_id
                    || '     Age = unknown'
                    || '      #_of_days = unknown'
                    || '     Eligibility of the form = Non-compliant');
                else
                    dbms_output.put_line(
                    'PLCO_ID= ' || new_patient.plco_id
                    || '     Age = unknown'
                    || '      #_of_days = unknown'
                    || '     Eligibility of the form = Invalid');
                end if;
            else
                if new_patient.sqx_status = 1 then
                    dbms_output.put_line(
                    'PLCO_ID= ' || new_patient.plco_id
                    || '     Age = unknown'
                    || '           #_of_days = ' || new_patient.sqx_days
                    || '     Eligibility of the form = Valid');
                elsif new_patient.sqx_status = 3 then
                    dbms_output.put_line(
                    'PLCO_ID= ' || new_patient.plco_id
                    || '     Age = unknown'
                    || '           #_of_days = ' || new_patient.sqx_days
                    || '     Eligibility of the form = Non-eligible');
                elsif new_patient.sqx_status = 4 then
                    dbms_output.put_line(
                    'PLCO_ID= ' || new_patient.plco_id
                    || '     Age = unknown'
                    || '           #_of_days = ' || new_patient.sqx_days
                    || '     Eligibility of the form = Non-compliant');
                else
                    dbms_output.put_line(
                    'PLCO_ID= ' || new_patient.plco_id
                    || '     Age = unknown'
                    || '           #_of_days = ' || new_patient.sqx_days
                    || '     Eligibility of the form = Invalid');
                end if;
            end if;        
        end if;
   end loop; 
end; 
/

-- Problem 1b

-- syntax: create table [table name] as (query table);

create table VITAMIN_ML as (
select plco_id, vitd_oh25d_ng_ml, vitd_oh125d_pg_ml
from vitamind_primary
where vitd_oh125d_pg_ml != 'N'
);
/

select * from VITAMIN_ML
where rownum <= 10;
/

-- next, use pl/sql to add a new column to the table
-- execute immediate...

begin 
   execute immediate 'alter table VITAMIN_ML add (SUM number)';
end; 
/

-- finally, use cursor (does not specify explicit or implicit, so either one?)
-- use explicit just as practice...
-- to add vitd_oh25d_ng_ml and vitd_oh125d_pg_ml, then store it into sum column
-- of the row

declare
    cursor milliliters is
        select vitd_oh25d_ng_ml, vitd_oh125d_pg_ml from VITAMIN_ML for update;
begin
    for new_sum in milliliters 
    loop
        update VITAMIN_ML
            set sum = new_sum.vitd_oh25d_ng_ml + new_sum.vitd_oh125d_pg_ml
            where current of milliliters;
    end loop;
end;
/

-- Problem 2a

-- any time vitd_is_case is set to 1 by update, write a message to output window, but only if...
    -- the vitamin d study group is prostate
        -- vitd_study_group = 3
    -- the vitamin d seasonal calendar year of blood collection is 2003
        -- vitd_draw_seasonal_year = 2003
-- message should print the plco_id that was updated

create or replace trigger vitD
before update of vitd_is_case
on vitaminD_primary
for each row
when (new.vitd_is_case = 1)
begin
    if :old.vitd_study_group = 3 and :old.vitd_draw_seasonal_year = 2003 then
        dbms_output.put_line('ATTENTION ATTENTION!!! 
        First Vitamin D Case Status for the patient PLCO_ID: '
        || :old.plco_id);
    end if;
end;
/
-- testing 2a
-- HW2 says for vitaminD table, but it was declared as vitamind_primary in HW1?

update vitaminD_primary 
set vitd_is_case = 1
where PLCO_ID = 'R-137042-8';
/

-- Problem 2b

-- any time vitd_is_case is set to 1 by update, write a message to output window, but only if...
    -- the vitamin d study group is colon
        -- vitd_study_group = 8
    -- the vitamin d seasonal calendar year of blood collection is 2000
        -- vitd_draw_seasonal_year = 2000
    -- # of 1,25 dihydroxyvitamin D3 measures > 20
        -- vitd_OH125D_pg_ml > 20
-- message should print...
    -- plco_id that was updated
    -- age
    -- # of randomization days from completion
    -- eligibility of the form
    -- whether it is a completed, valid form
        -- check if form is eligible; if yes, print valid and yes
            -- if no, print the validity of form and no

create or replace trigger vitDPatient
before update
on vitaminD_primary
for each row
when (new.VITD_IS_CASE = 1)
begin
    -- vitd_oh125d_pg_ml: takes varchar2
    -- so, CANNOT directly compare to number...
    -- the comparison is ambiguous
    -- use TO_NUMBER????
    
    -- edit: probably a typo in the assignment; vitd_oh25d_ng_ml works fine...
    -- also, for the two given test cases, both have value N for 125d column
    -- so they will never print anything...
    
    if :old.vitd_study_group = 8 and :old.vitd_draw_seasonal_year = 2000 and :old.vitd_oh25d_ng_ml > 20 then
        for next_patient in 
        (select p.sqx_age, p.sqx_days, p.sqx_status
            from patient p
            where p.plco_id=:old.plco_id)
        loop
            if next_patient.sqx_age is not null then
                if next_patient.sqx_days is null then
                    if next_patient.sqx_status = 1 then
                        dbms_output.put_line(
                        'PLCO_ID:                   ' || :old.plco_id);
                        dbms_output.put_line(
                        'Age:                       ' || next_patient.sqx_age);
                        dbms_output.put_line(
                        'Number of days:            Unknown');
                        dbms_output.put_line(
                        'Eligibility of the form:   Valid');
                        dbms_output.put_line(
                        'Completed valid form: Yes');
                    elsif next_patient.sqx_status = 3 then
                        dbms_output.put_line(
                        'PLCO_ID:                   ' || :old.plco_id);
                        dbms_output.put_line(
                        'Age:                       ' || next_patient.sqx_age);
                        dbms_output.put_line(
                        'Number of days:            Unknown');
                        dbms_output.put_line(
                        'Eligibility of the form:   Non-eligible');
                        dbms_output.put_line(
                        'Completed valid form: No');
                    elsif next_patient.sqx_status = 4 then
                        dbms_output.put_line(
                        'PLCO_ID:                   ' || :old.plco_id);
                        dbms_output.put_line(
                        'Age:                       ' || next_patient.sqx_age);
                        dbms_output.put_line(
                        'Number of days:            Unknown');
                        dbms_output.put_line(
                        'Eligibility of the form:   Non-compliant');
                        dbms_output.put_line(
                        'Completed valid form: No');
                    else
                        dbms_output.put_line(
                        'PLCO_ID:                   ' || :old.plco_id);
                        dbms_output.put_line(
                        'Age:                       ' || next_patient.sqx_age);
                        dbms_output.put_line(
                        'Number of days:            Unknown');
                        dbms_output.put_line(
                        'Eligibility of the form:   Invalid');
                        dbms_output.put_line(
                        'Completed valid form: No');
                    end if;
                else
                    if next_patient.sqx_status = 1 then
                        dbms_output.put_line(
                        'PLCO_ID:                   ' || :old.plco_id);
                        dbms_output.put_line(
                        'Age:                       ' || next_patient.sqx_age);
                        dbms_output.put_line(
                        'Number of days:            ' || next_patient.sqx_days);
                        dbms_output.put_line(
                        'Eligibility of the form:   Valid');
                        dbms_output.put_line(
                        'Completed valid form:      Yes');
                    elsif next_patient.sqx_status = 3 then
                        dbms_output.put_line(
                        'PLCO_ID:                   ' || :old.plco_id);
                        dbms_output.put_line(
                        'Age:                       ' || next_patient.sqx_age);
                        dbms_output.put_line(
                        'Number of days:            ' || next_patient.sqx_days);
                        dbms_output.put_line(
                        'Eligibility of the form:   Non-eligible');
                        dbms_output.put_line(
                        'Completed valid form:      No');
                    elsif next_patient.sqx_status = 4 then
                        dbms_output.put_line(
                        'PLCO_ID:                   ' || :old.plco_id);
                        dbms_output.put_line(
                        'Age:                       ' || next_patient.sqx_age);
                        dbms_output.put_line(
                        'Number of days:            ' || next_patient.sqx_days);
                        dbms_output.put_line(
                        'Eligibility of the form:   Non-compliant');
                        dbms_output.put_line(
                        'Completed valid form:      No');
                    else
                        dbms_output.put_line(
                        'PLCO_ID:                   ' || :old.plco_id);
                        dbms_output.put_line(
                        'Age:                       ' || next_patient.sqx_age);
                        dbms_output.put_line(
                        'Number of days:            ' || next_patient.sqx_days);
                        dbms_output.put_line(
                        'Eligibility of the form:   Invalid');
                        dbms_output.put_line(
                        'Completed valid form:      No');
                    end if;
                end if;
            else
                if next_patient.sqx_days is null then
                    if next_patient.sqx_status = 1 then
                        dbms_output.put_line(
                        'PLCO_ID                   ' || :old.plco_id);
                        dbms_output.put_line(
                        'Age:                       Unknown');
                        dbms_output.put_line(
                        'Number of days:            Unknown');
                        dbms_output.put_line(
                        'Eligibility of the form:   Valid');
                        dbms_output.put_line(
                        'Completed valid form:      Yes');
                    elsif next_patient.sqx_status = 3 then
                        dbms_output.put_line(
                        'PLCO_ID:                   ' || :old.plco_id);
                        dbms_output.put_line(
                        'Age:                       Unknown');
                        dbms_output.put_line(
                        'Number of days:            Unknown');
                        dbms_output.put_line(
                        'Eligibility of the form:   Non-eligible');
                        dbms_output.put_line(
                        'Completed valid form:      No');
                    elsif next_patient.sqx_status = 4 then
                        dbms_output.put_line(
                        'PLCO_ID:                   ' || :old.plco_id);
                        dbms_output.put_line(
                        'Age:                       Unknown');
                        dbms_output.put_line(
                        'Number of days:            Unknown');
                        dbms_output.put_line(
                        'Eligibility of the form:   Non-compliant');
                        dbms_output.put_line(
                        'Completed valid form:      No');
                    else
                        dbms_output.put_line(
                        'PLCO_ID:                   ' || :old.plco_id);
                        dbms_output.put_line(
                        'Age:                       Unknown');
                        dbms_output.put_line(
                        'Number of days:            Unknown');
                        dbms_output.put_line(
                        'Eligibility of the form:   Invalid');
                        dbms_output.put_line(
                        'Completed valid form:      No');
                    end if;
                else
                    if next_patient.sqx_status = 1 then
                        dbms_output.put_line(
                        'PLCO_ID:                   ' || :old.plco_id);
                        dbms_output.put_line(
                        'Age:                       Unknown');
                        dbms_output.put_line(
                        'Number of days:            ' || next_patient.sqx_days);
                        dbms_output.put_line(
                        'Eligibility of the form:   Valid');
                        dbms_output.put_line(
                        'Completed valid form:      Yes');
                    elsif next_patient.sqx_status = 3 then
                        dbms_output.put_line(
                        'PLCO_ID:                   ' || :old.plco_id);
                        dbms_output.put_line(
                        'Age:                       Unknown');
                        dbms_output.put_line(
                        'Number of days:            ' || next_patient.sqx_days);
                        dbms_output.put_line(
                        'Eligibility of the form:   Non-eligible');
                        dbms_output.put_line(
                        'Completed valid form:      No');
                    elsif next_patient.sqx_status = 4 then
                        dbms_output.put_line(
                        'PLCO_ID:                   ' || :old.plco_id);
                        dbms_output.put_line(
                        'Age:                       Unknown');
                        dbms_output.put_line(
                        'Number of days:            ' || next_patient.sqx_days);
                        dbms_output.put_line(
                        'Eligibility of the form:   Non-compliant');
                        dbms_output.put_line(
                        'Completed valid form:      No');
                    else
                        dbms_output.put_line(
                        'PLCO_ID:                   ' || :old.plco_id);
                        dbms_output.put_line(
                        'Age:                       Unknown');
                        dbms_output.put_line(
                        'Number of days:            ' || next_patient.sqx_days);
                        dbms_output.put_line(
                        'Eligibility of the form:   Invalid');
                        dbms_output.put_line(
                        'Completed valid form:      No');
                    end if;
                end if;
            end if;
        end loop;
    end if;
end;
/

-- testing 2b
-- again, HW2 says for vitaminD table, but it was declared as vitamind_primary in HW1?

update vitaminD_primary 
set vitd_is_case = 1
where PLCO_ID = 'F-068845-0'; -- originally 1
/
update vitaminD_primary 
set vitd_is_case = 1
where PLCO_ID = 'D-008687-8'; -- originally 1
/

-- Problem 2c

-- any time vitd_is_case is set to 1 by update, update the table VitDTrack, but only if...
    -- the vitamin d study group is colon
        -- vitd_study_group = 8
    -- the vitamin d seasonal calendar year of blood collection is 2000
        -- vitd_draw_seasonal_year = 2000
    -- # of 1,25 dihydroxyvitamin D3 measures > 20
        -- vitd_OH125D_pg_ml > 20
            -- but we will assume it is vitd_OH25D_ng_ml, like in problem 2b...
            
-- assume the table exists?
-- should it make the table if it doesn't exist?
    -- https://stackoverflow.com/questions/15436942/oracle-create-table-if-it-does-not-exist
        -- seems too in-depth for this particular problem... so just make the table first
    -- if it doesn't, should it also insert values from vitamind_primary?
        -- should it insert ALL values?

-- making the table...
create table VitDTrack(
PLCO_ID varchar2(26),
Age number,
NumberOfDays number,
Eligibility number,
Valid number
);
/

-- what does it mean by update?
    -- all of the values are already there from making the table...
        -- so maybe make the table as empty first?
        -- then update means insert?
        
create or replace trigger vitDPatient2
before update
on vitaminD_primary
for each row
when (new.VITD_IS_CASE = 1)
begin   
    if :old.vitd_study_group = 8 and :old.vitd_draw_seasonal_year = 2000 and :old.vitd_oh25d_ng_ml > 20 then
        for next_patient in 
        (select p.plco_id as PLCO_ID, 
            p.sqx_age as Age, 
            p.sqx_days as NumberOfDays, 
            p.sqx_status as Eligibility, 
            p.sqx_valid as Valid
            from patient p
            where p.plco_id=:old.plco_id)
        loop
            insert into vitdtrack values(next_patient.PLCO_ID, next_patient.Age, next_patient.NumberOfDays, next_patient.Eligibility, next_patient.Valid);
        end loop;
    end if;
end;
/

-- testing 2c

update vitaminD_primary 
set vitd_is_case = 1
where PLCO_ID = 'A-152738-4'; -- originally 0
/
update vitaminD_primary 
set vitd_is_case = 1
where PLCO_ID = 'C-020899-3'; -- originally 0
/

select * from vitdtrack;
/