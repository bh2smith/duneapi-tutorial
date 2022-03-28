-- LGNO transfer event has reversed to and from: https://github.com/gnosis/token-lock/issues/29
with lgno_sourced_transfers as (
  -- Incoming
  select evt_tx_hash,
    evt_block_time,
    evt_block_number,
    "from" as account,
    value
  from gnosis_chain."TokenLock_evt_Transfer"
  where "from" != '\xd4Ca39f78Bf14BfaB75226AC833b1858dB16f9a1'
  union all
  -- Outgoing
  select evt_tx_hash,
    evt_block_time,
    evt_block_number,
    "to" as account,
    -1 * value as value
  from gnosis_chain."TokenLock_evt_Transfer"
  where "to" != '\xd4Ca39f78Bf14BfaB75226AC833b1858dB16f9a1'
),
lgno_balances as (
  select account,
    sum(value) as amount
  from lgno_sourced_transfers
  group by account
),
-- LGNO
total_lgno as (
  select sum(amount) / 10 ^ 18 as total_locked
  from lgno_balances
),
mgno_sourced_transfers as (
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
mgno_balances as (
  select account,
    sum(value) as amount
  from mgno_sourced_transfers
  where evt_block_number < 1644944444
  group by account
),
total_mgno as (
  select sum(amount) / 10 ^ 18 / 32 as total_locked
  from mgno_balances
  where amount > 0
)
select sum(total_locked) as total_locked
from (
    select total_locked
    from total_lgno
    union
    select total_locked
    from total_mgno
  ) as _