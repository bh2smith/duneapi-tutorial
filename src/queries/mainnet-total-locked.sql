-- LGNO transfer event has reversed to and from: https://github.com/gnosis/token-lock/issues/29
with sourced_transfers as (
  -- Incoming
  select evt_tx_hash,
    evt_block_time,
    evt_block_number,
    "from" as account,
    value
  from erc20."ERC20_evt_Transfer"
  where contract_address = '\x4f8AD938eBA0CD19155a835f617317a6E788c868'
    and "from" != '\x4f8AD938eBA0CD19155a835f617317a6E788c868'
  union all
  -- Outgoing
  select evt_tx_hash,
    evt_block_time,
    evt_block_number,
    "to" as account,
    -1 * value as value
  from erc20."ERC20_evt_Transfer"
  where contract_address = '\x4f8AD938eBA0CD19155a835f617317a6E788c868'
    and "to" != '\x4f8AD938eBA0CD19155a835f617317a6E788c868'
),
balances as (
  select account,
    sum(value) as amount
  from sourced_transfers
  group by account
)
select sum(amount) / 10 ^ 18 as total_locked
from balances