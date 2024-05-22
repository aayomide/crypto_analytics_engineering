{{ config(materialized='table') }}

with coins_data as (
    select 
        *
    from {{ ref('stg_coinsdata') }}

)


select
    name,
    symbol,
    coin_id,
    explorer,   
    supply,
    max_supply
    
from coins_data
