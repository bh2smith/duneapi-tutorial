-- LGNO transfer event has reversed to and from: https://github.com/gnosis/token-lock/issues/29
with sourced_transfers as (
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
balances as (
  select account,
    sum(value) as amount
  from sourced_transfers
  group by account
)
select concat('0x', encode(account, 'hex')) as account,
  amount / 10 ^ 18 as amount
from balances
where amount > 0
order by amount desc