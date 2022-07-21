"""Based on https://dune.com/queries/1078624"""
from duneapi.api import DuneAPI
from duneapi.types import DuneQuery, Network

query_string = """
with decoded_value as (
    select 
        call_tx_hash as tx_hash,
        substring(trim('"' from ("desc" -> 'dstToken')::text) from 3) as token, 
        ltrim(substring(split_part(data::text, '4470bdb947', 2) from 65 for 64), '0') as value
    from oneinch_v4."AggregationRouterV4_call_swap"
    where call_success = true
    and call_tx_hash = '\\x72094b793adf4304a0a2c1021c1724c9a30d219719b2b9a0ba92bbb84272e7db'
)

select * from decoded_value
where value != ''
limit 100
"""

if __name__ == "__main__":
    dune = DuneAPI.new_from_environment()
    query = DuneQuery.from_environment(
        raw_sql=query_string,
        network=Network.MAINNET
    )
    results = dune.fetch(query)

    for rec in results:
        value = int(rec["value"], 16)
        print(value)
