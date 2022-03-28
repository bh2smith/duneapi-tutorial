-- For a permanent version of this query please visit: https://dune.xyz/queries/426384
select concat('0x', encode("from", 'hex')) as depositor,
  count(*) as num_deposits
from gnosis_chain."SBCDepositContract_evt_DepositEvent" d
  inner join xdai."transactions" t on hash = evt_tx_hash
where evt_block_number < 20655309
group by "from"
order by num_deposits desc