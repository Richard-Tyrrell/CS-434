-- Problem 1

-- 1. import to make tables
-- done...
-- 2. SELECT * FROM file_name;

SELECT * FROM patient;
/
SELECT * FROM vitamind_primary;
/

-- Problem 2

-- a. list # of occurrences for each withdrawal year in vitaminD_primary
-- withdrawal year: vitd_draw_seasonal_year

select vitd_draw_seasonal_year, 
count(vitd_draw_seasonal_year) as num_of_occurrences 
from vitamind_primary 
group by vitd_draw_seasonal_year 
order by vitd_draw_seasonal_year asc;
/
-- this will get each year and the number of occurrences...

-- b. pick from 1996 and explain each column with the PDF

select * from vitamind_primary where vitd_draw_seasonal_year = 1996;
/

-- c. show all patient PLCO_IDs where...
    -- first vitamin D study is colon cancer
        -- vitd_study = 13
    -- vitamin D season of blood collection is between June and August
        -- vitd_draw_season = 3
    -- measurement of 25-dihydroxyvitamin D3 in ng/ml is > 30
        -- vitd_OH25D_ng_ml > 30
    -- blood collection time of the day is <= 10
        -- vitd_draw_time <= 10
  
declare  
    cursor CUR_measure_more_than_30 is 
        select plco_id from vitamind_primary 
        where vitd_study = 13 
        and vitd_draw_season = 3 
        and vitd_OH25D_ng_ml > 30 
        and vitd_draw_time <= 10
        and rownum <= 10;
    patient_id varchar2(26);
    
begin
    dbms_output.put_line('Printing PLCO_ID numbers...');
    open CUR_measure_more_than_30;
    loop
        fetch CUR_measure_more_than_30 into patient_id;
        if CUR_measure_more_than_30 % found then
            dbms_output.put_line(patient_id);
        else
            exit;
        end if;
    end loop;
    close CUR_measure_more_than_30;
end;
/
        
-- Problem 3
        
-- show all patient PLCO_IDs, ages, #_of_days and income levels where...
    -- sqx form status is compliant and valid
        -- patient has sqx_status = 1, sqx_substatus = 1 and sqx_valid = 1
    -- show: plco_id, sqx_age, sqx_days, sqx_income
    
-- said the blank at the end was fine

begin 
   for new_patient in
        (select plco_id, sqx_age, sqx_days, sqx_income 
        from patient 
        where sqx_status = 1 and sqx_valid = 1 and rownum <= 10) 
   loop
        dbms_output.put_line('PLCO_ID= ' || 
        new_patient.plco_id || chr(9) || chr(9) 
        || 'Age = ' || new_patient.sqx_age || chr(9) 
        || '#_of_days = ' || new_patient.sqx_days || 
        chr(9) || 'income level = ' || new_patient.sqx_income);
   end loop; 
end; 
/

-- show all patient...
    -- PLCO_IDs
    -- ages
        -- this comes from sqx (patient) table...
    -- number of days from randomization to completion date
        -- this comes from vitamind_primary table...
    -- income level
        -- this comes from sqx (patient) table...
-- patients must have...
    -- vitamin d season of blood collection between june and august
    -- measurement of 25-dihydroxyvitamin D3 in ng/ml is > 20
        -- vitd_OH25D_ng_ml again
    -- blood collection time of day is <= 10
    
begin 
   for a_patient in
        (select p.plco_id, p.sqx_age, v.vitd_drawdays, p.sqx_income
        from patient p, vitamind_primary v
        where p.plco_id=v.plco_id 
        and v.vitd_draw_season = 3 
        and v.vitd_OH25D_ng_ml > 20 
        and v.vitd_draw_time <= 10 
        and rownum <= 10) 
   loop
        if a_patient.sqx_age is not null then
            if a_patient.sqx_income = 2 then
                dbms_output.put_line('PLCO_ID= ' || 
                a_patient.plco_id
                || lpad('Age = ' , 10) || a_patient.sqx_age
                || lpad('#_of_days = ' , 24) || a_patient.vitd_drawdays
                || lpad('income = "$20,000-$49,000"', 30)); -- 2 = $20k-$49k
            elsif a_patient.sqx_income = 3 then
                dbms_output.put_line('PLCO_ID= ' || 
                a_patient.plco_id 
                || lpad('Age = ' , 10) || a_patient.sqx_age
                || lpad('#_of_days = ' , 24) || a_patient.vitd_drawdays
                || lpad('income = "$50,000-$99,000"', 30)); -- 3 = $50k-$99k
            elsif a_patient.sqx_income is null then
                dbms_output.put_line('PLCO_ID= ' || 
                a_patient.plco_id
                || lpad('Age = ' , 10) || a_patient.sqx_age
                || lpad('#_of_days = ' , 24) || a_patient.vitd_drawdays 
                || lpad('income = "Not known"', 26));
            end if;         
        else
            dbms_output.put_line('PLCO_ID= ' || 
            a_patient.plco_id
            || lpad('Age = "Not known"' , 21)
            || lpad('#_of_days = ' , 15) || a_patient.vitd_drawdays 
            || lpad('income = "Not known"', 26));
        end if;
   end loop; 
end; 
/

-- tabs worked way worse compared to spaces... still couldn't get it to
-- align perfectly, though.
-- I show the first 10 rows; there are 1077 rows without rownum <= 10
-- cannot have them all in one snippet...

-- Problem 4

-- a. write function MYPRIME to see if number n is prime

create or replace function MYPRIME(num in number)
return boolean -- data type to be returned
as
begin
    if num <= 1 then
        return false;
    end if;
    for i in 2..SQRT(num)
    loop
        if MOD(num, i) = 0 then -- num % i == 0
            return false;
            exit;
        end if;
    end loop;
    return true; -- prime if it reaches here
end;
/

declare
    z boolean;
begin
    z := MYPRIME(3); -- calls function with value 3, so it will test whether 3 is prime (it is...)
    dbms_output.put_line('z returned ' || case when z then 'true' else 'false' end); 
    -- case works like (?, :) operator in C++, or  (if something, return true else return false)
    -- whatever was returned from the function gets stored in z
    -- so we can just print z
end;
/

-- b. write function MYPERFECT to see if number n is perfect

create or replace function MYPERFECT(num in number)
return boolean -- data type to be returned
as
 total number;
begin
    total := 0;
    if num <= 1 then
        return false; -- perfect numbers exclude themselves; 1 is not perfect
    end if;
    for i in 1 .. num
    loop
        if MOD(num, i) = 0 and i != num then -- num % i == 0
            total := total + i;
        end if;
    end loop;
    if total = num then
        return true;
    end if;
    return false; -- not perfect if it reaches here
end;
/

declare
    q boolean;
begin
    q := MYPERFECT(28); -- calls function with value 6, so it will test whether 6 is perfect (it is...)
    dbms_output.put_line('q returned ' || case when q then 'true' else 'false' end); 
end;
/

-- c. list all perfect numbers from 1 to 10,000 using for loop

declare
    result boolean;
begin
    for i in 1 .. 10000
    loop
        result := MYPERFECT(i);
        if result then
            dbms_output.put_line(i || ' is a perfect number.');
        end if;
    end loop;
end;
/

-- d. list all even perfect numbers from 1 to 10,000 using formula
-- perfectnumber(n) = 2^(prime-1) * (2^(prime) - 1)

declare
    result boolean;
    result2 boolean;
    val number; -- for each perfect number
    quantity number; -- to test if a prime number yields a prime from the quantity (2^(prime) - 1)
begin
    for i in 1 .. 10000
    loop
        result := MYPRIME(i);
        if result then
            quantity := POWER(2,i) - 1;
            result2 := MYPRIME(quantity);
            if result2 then
                val := POWER(2,(i-1)) * quantity;
                if val < 10000 then -- the value itself cannot be > 10000!!!
                    dbms_output.put_line(val || ' is a perfect number.');
                else
                    exit;
                end if;
            end if;
        end if;
    end loop;
end;
/