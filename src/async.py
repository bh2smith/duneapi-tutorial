import time
from dotenv import load_dotenv
from duneapi.api import DuneAPI
from duneapi.types import DuneRecord, DuneQuery, QueryResults


def try_get_results(dune: DuneAPI, job_id: str) -> list[DuneRecord] | None:
    queue_position_post = DuneQuery.get_queue_position(job_id)
    queue_position = dune.post_dune_request(queue_position_post)
    if queue_position.json()["data"]["jobs_by_pk"] is not None:
        print(f"Job ID {job_id} not ready yet!")
        time.sleep(1)
        return None

    response = dune.post_dune_request(DuneQuery.find_result_by_job(job_id))
    return QueryResults(response.json()["data"]).data


def mock_async_fetch(dune: DuneAPI, query_ids: list[int]) -> list[DuneRecord]:
    query_job_map = {}
    job_ids = []
    print(f"Executing queries {query_ids}")
    for q_id in query_ids:
        j_id = dune.execute(q_id)
        query_job_map[q_id] = j_id
        job_ids.append(j_id)

    print(f"Corresponding job IDs for pending query execution {query_job_map}")
    results = {}
    while job_ids:
        # Round robin check for query results.
        j_id = job_ids.pop(0)
        single_result = try_get_results(dune, job_id=j_id)
        if single_result is not None:
            print(f"Found results for {j_id}!")
            results[j_id] = single_result
        else:
            # Push to the back!
            job_ids.append(j_id)
    return {q_id: results[j_id] for q_id, j_id in query_job_map.items()}


if __name__ == "__main__":
    load_dotenv()
    block_count_id = 1102138  # select count(*) from ethereum.blocks
    tx_count_id = 1102144  # select count(*) from ethereum.transactions
    results = mock_async_fetch(
        DuneAPI.new_from_environment(), [block_count_id, tx_count_id]
    )
    print("Results", results)
