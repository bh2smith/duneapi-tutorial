with sourced_transfers as (
  -- Incoming
  select evt_tx_hash,
    evt_block_time,
    evt_block_number,
    "to" as account,
    value
  from erc20."ERC20_evt_Transfer"
  where contract_address = '\x722fc4DAABFEaff81b97894fC623f91814a1BF68'
  union all
  -- Outgoing
  select evt_tx_hash,
    evt_block_time,
    evt_block_number,
    "from" as account,
    -1 * value as value
  from erc20."ERC20_evt_Transfer"
  where contract_address = '\x722fc4DAABFEaff81b97894fC623f91814a1BF68'
),
balances as (
  select account,
    sum(value) as amount
  from sourced_transfers
  where evt_block_number < 1644944444
  group by account
)
select sum(amount) / 10 ^ 18 / 32 as locked_gno
from balances
where account = '\x0b98057ea310f4d31f2a452b414647007d1645d9'