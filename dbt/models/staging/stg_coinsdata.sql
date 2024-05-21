with coins_raw as (
    select 
        *,
        row_number() over(partition by id, name) as rn 
    from {{ source('staging', 'coins_data_raw') }}
    where id is not null 

),

coins_renamed as (
    select
        -- identifiers
        {{ dbt_utils.surrogate_key(['id']) }} as id,

        -- coin info
        name,
        symbol,
        cast(rank as integer) as rank,
        
        -- timestamp
        -- cast(timestamp as timestamp) as created_datetime,
        
        -- price info
        cast(priceUsd as numeric) as price_usd,
        round(cast(changePercent24Hr as numeric),4) as change_percent_24Hr,

        -- volume info
        cast(volumeUsd24Hr as numeric) as volume_usd_24Hr,
        cast(vwap24Hr as numeric) as vwap_24Hr,
        round(cast(supply as numeric)) as supply,
        round(cast(maxSupply as numeric)) as max_supply,
        cast(marketCapUsd as numeric) as marketCapUsd,

        -- external link to get more coin info
        explorer

    from coins_raw
    where rn = 1        # remove duplicates

)


select * from coins_renamed
order by rank

-- dbt build --vars 'is_test_run: false'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}