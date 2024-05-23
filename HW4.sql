-- Problem 1

-- first, need table... one column

create table VITAMIND_JSON(
	VITAMIND CLOB
    constraint c3 check (VITAMIND is JSON)
);
/

-- THIS ONE IS FOR MONGODB

create table VITAMIND_JSON_TEMP(
	VITAMIND CLOB
);
/

begin
    for some_patient in 
    (select plco_id,
    vitd_OH25D_ng_ml,
    vitd_is_case,
    vitd_draw_time,
    vitd_drawdays,
    vitd_draw_seasonal_year
    from vitamind_primary
    where vitd_study = 13
    and vitd_draw_season = 3
    and vitd_OH25D_ng_ml > 30
    and vitd_draw_time <= 10
    )
    loop
        if some_patient.plco_id is not null then
            insert into VITAMIND_JSON_TEMP values( 
               '{ 
                  PLCO_ID : "' || some_patient.plco_id || '", 
                  VITD_OH25D_NG_ML : ' || some_patient.vitd_OH25D_ng_ml || ', 
                  VITD_IS_CASE : ' || some_patient.vitd_is_case || ',
                  VITD_DRAW_TIME : ' || some_patient.vitd_draw_time || ',
                  VITD_DRAWDAYS : ' || some_patient.vitd_drawdays || ',
                  VITD_DRAW_SEASONAL_YEAR : ' || some_patient.vitd_draw_seasonal_year || ',
                }'
            );
        end if;
    end loop;
end;
/

-- need to insert data into vitamind_json from vitamind_primary

-- from vitamind_primary, need all...
    -- plco_ids
    -- 25-hydroxy measures (ng/ml)
        -- vitd_OH25D_ng_ml
    -- first vitamin d case status
        -- vitd_is_case
    -- time of day of blood collection
        -- vitd_draw_time
    -- days from randomization to blood collection
        -- vitd_drawdays
    -- seasonal calendar year of blood collection
        -- vitd_draw_seasonal_year
-- select the above where...
    -- first vitamin d study is colon cancer
        -- vitd_study = 13
    -- vitamin d season of blood collection is between June and August
        -- vitd_draw_season = 3
    -- 1,25-dihydroxy measure (pg/ml) > 30
        -- vitd_OH125D_pg_ml > 30
    -- blood collection time of day <= 10
        -- vitd_draw_time <= 10

select plco_id,
vitd_OH25D_ng_ml,
vitd_is_case,
vitd_draw_time,
vitd_drawdays,
vitd_draw_seasonal_year
from vitamind_primary
where vitd_study = 13
and vitd_draw_season = 3
and vitd_OH25D_ng_ml > 30 -- changed from 125D_pg_ml, since it gives an error
and vitd_draw_time <= 10;
/

-- this is query to base the table on...

-- then insert...

begin
    for some_patient in 
    (select plco_id,
    vitd_OH25D_ng_ml,
    vitd_is_case,
    vitd_draw_time,
    vitd_drawdays,
    vitd_draw_seasonal_year
    from vitamind_primary
    where vitd_study = 13
    and vitd_draw_season = 3
    and vitd_OH25D_ng_ml > 30
    and vitd_draw_time <= 10
    )
    loop
        if some_patient.plco_id is not null then
            insert into VITAMIND_JSON values( 
               '{ 
                  "PLCO_ID" : "' || some_patient.plco_id || '", 
                  "vitd_OH25D_ng_ml" : ' || some_patient.vitd_OH25D_ng_ml || ', 
                  "vitd_is_case" : ' || some_patient.vitd_is_case || ',
                  "vitd_draw_time" : ' || some_patient.vitd_draw_time || ',
                  "vitd_drawdays" : ' || some_patient.vitd_drawdays || ',
                  "vitd_draw_seasonal_year" : ' || some_patient.vitd_draw_seasonal_year || ',
                }'
            );
        end if;
    end loop;
end;
/

-- and select...
    -- get all the data just inserted and display it properly w/ alias
    
select v.VITAMIND.PLCO_ID,
v.VITAMIND.vitd_OH25D_ng_ml,
v.VITAMIND.vitd_is_case,
v.VITAMIND.vitd_draw_time,
v.VITAMIND.vitd_drawdays,
v.VITAMIND.vitd_draw_seasonal_year
from vitamind_json v
where rownum <= 10;
/

select v.VITAMIND.PLCO_ID, -- comparing for problem 3 (mongodb)
v.VITAMIND.vitd_OH25D_ng_ml,
v.VITAMIND.vitd_is_case,
v.VITAMIND.vitd_draw_time,
v.VITAMIND.vitd_drawdays,
v.VITAMIND.vitd_draw_seasonal_year
from vitamind_json v;
/

-- Problem 2

-- first, need another table... one column

create table LYMPHOMA_JSON (
	LYMPHOMAJSON CLOB
    constraint c4 check (LYMPHOMAJSON is JSON)
);
/

-- ALSO FOR MONGO DB

create table LYMPHOMA_JSON_TEMP (
	LYMPHOMAJSON CLOB
);
/

begin
    for new_patient in 
    (select plco_id,
    match_agelevel,
    vitd_OH25D_ng_ml,
    cell,
    sample_drawdays,
    sample_season,
    sample_time,
    sample_yr
    from lymphoma
    where match_gender = 'M'
    and cell > 90
    and (match_agelevel >= 2 and match_agelevel <= 3)
    and vitd_OH25D_ng_ml < 25
    )
    loop
        if new_patient.plco_id is not null then
            insert into LYMPHOMA_JSON_TEMP values( 
               '{ 
                  PLCO_ID : "' || new_patient.plco_id || '", 
                  MATCH_AGELEVEL : ' || new_patient.match_agelevel || ', 
                  VITD_OH25D_NG_ML : ' || new_patient.vitd_oh25d_ng_ml || ',
                  CELL : ' || new_patient.cell || ',
                  SAMPLE_DRAWDAYS : ' || new_patient.sample_drawdays || ',
                  SAMPLE_SEASON : ' || new_patient.sample_season || ',
                  SAMPLE_TIME : ' || new_patient.sample_time || ',
                  SAMPLE_YR : ' || new_patient.sample_yr || ',
                }'
            );
        end if;
    end loop;
end;
/

-- need to insert data into lymphoma_json from lymphoma
-- ... lymphoma doesn't exist yet; import it first
-- imported

-- from lymphoma, need all...
    -- plco ids
    -- age level
        -- match_agelevel
    -- 25-hydroxyvitamin D measure (ng/ml)
        -- vitd_OH25D_ng_ml
    -- matched cell value
        -- cell
    -- sample draw days
        -- sample_drawdays
    -- season
        -- sample_season
    -- time
        -- sample_time
    -- year
        -- sample_yr
-- select the above where...
    -- patient is male
        -- match_gender = "M"
    -- matched cell value > 90
        -- cell > 90
    -- age level between 2 and 3
        -- match_agelevel >= 2 and match_agelevel <= 3
    -- 25-hydroxyvitamind D measure < 25
        -- vitd_OH25D_ng_ml < 25
    
select plco_id,
match_agelevel,
vitd_OH25D_ng_ml,
cell,
sample_drawdays,
sample_season,
sample_time,
sample_yr
from lymphoma
where match_gender = 'M'
and cell > 90
and (match_agelevel >= 2 and match_agelevel <= 3)
and vitd_OH25D_ng_ml < 25;
/

-- this is query to base the table on...

-- then insert...

begin
    for new_patient in 
    (select plco_id,
    match_agelevel,
    vitd_OH25D_ng_ml,
    cell,
    sample_drawdays,
    sample_season,
    sample_time,
    sample_yr
    from lymphoma
    where match_gender = 'M'
    and cell > 90
    and (match_agelevel >= 2 and match_agelevel <= 3)
    and vitd_OH25D_ng_ml < 25
    )
    loop
        if new_patient.plco_id is not null then
            insert into LYMPHOMA_JSON values( 
               '{ 
                  "PLCO_ID" : "' || new_patient.plco_id || '", 
                  "match_agelevel" : ' || new_patient.match_agelevel || ', 
                  "vitd_OH25D_ng_ml" : ' || new_patient.vitd_OH25D_ng_ml || ',
                  "cell" : ' || new_patient.cell || ',
                  "sample_drawdays" : ' || new_patient.sample_drawdays || ',
                  "sample_season" : ' || new_patient.sample_season || ',
                  "sample_time" : ' || new_patient.sample_time || ',
                  "sample_yr" : ' || new_patient.sample_yr || ',
                }'
            );
        end if;
    end loop;
end;
/

-- and select again...
    -- get all the data just inserted and display it properly w/ alias
    
select L.LYMPHOMAJSON.PLCO_ID,
L.LYMPHOMAJSON.match_agelevel,
L.LYMPHOMAJSON.vitd_OH25D_ng_ml,
L.LYMPHOMAJSON.cell,
L.LYMPHOMAJSON.sample_drawdays,
L.LYMPHOMAJSON.sample_season,
L.LYMPHOMAJSON.sample_time,
L.LYMPHOMAJSON.sample_yr
from LYMPHOMA_JSON L
where rownum <= 10;
/

-- for problem 5, need the whole json table

select v.VITAMIND.PLCO_ID,
v.VITAMIND.vitd_OH25D_ng_ml,
v.VITAMIND.vitd_is_case,
v.VITAMIND.vitd_draw_time,
v.VITAMIND.vitd_drawdays,
v.VITAMIND.vitd_draw_seasonal_year
from vitamind_json v;
/

-- and same for problem 6...

select L.LYMPHOMAJSON.PLCO_ID,
L.LYMPHOMAJSON.match_agelevel,
L.LYMPHOMAJSON.vitd_OH25D_ng_ml,
L.LYMPHOMAJSON.cell,
L.LYMPHOMAJSON.sample_drawdays,
L.LYMPHOMAJSON.sample_season,
L.LYMPHOMAJSON.sample_time,
L.LYMPHOMAJSON.sample_yr
from LYMPHOMA_JSON L;
/