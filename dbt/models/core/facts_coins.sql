{{ config(materialized='table') }}

with coins_data as (
    select 
        *
    from {{ ref('stg_coinsdata') }}

)

select
    -- identifiers
    coin_id,
    name,
    rank,
    price_usd,
    change_percent_24Hr,
    market_cap_usd,
    volume_usd_24Hr,
    vwap_24Hr
    
from coins_data
