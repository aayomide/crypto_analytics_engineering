with coins_raw as (
    select 
        *,
        row_number() over(partition by id, name) as rn 
    from {{ source('staging', 'coins_table') }}
    where id is not null 

)

select * from coins_raw

-- dbt build --m <model.sql> --var 'is_test_run: false'
-- {% if var('is_test_run', default=true) %}

--   limit 100

-- {% endif %}