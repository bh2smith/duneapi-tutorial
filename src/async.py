import time
from dotenv import load_dotenv
from duneapi.api import DuneAPI
from duneapi.types import DuneRecord, DuneQuery, QueryResults
from duneapi.response import pre_validate_response


def try_get_results(dune: DuneAPI, job_id: str) -> list[DuneRecord] | None:
    queue_position_post = DuneQuery.get_queue_position(job_id)
    queue_position = dune.post_dune_request(queue_position_post)
    if queue_position.json()["data"]["jobs_by_pk"] is not None:
        print(f"Job ID {job_id} not ready yet!")
        print(queue_position.json())
        time.sleep(1)
        return None

    response = dune.post_dune_request(DuneQuery.find_result_by_job(job_id))
    return QueryResults(response.json()["data"]).data


def mock_async_fetch(dune: DuneAPI, query_ids: list[int]) -> list[DuneRecord]:
    query_job_map = {}
    job_ids = []
    for q_id in query_ids:
        j_id = dune.execute(q_id)
        query_job_map[q_id] = j_id
        job_ids.append(j_id)
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
    block_count_id = 1102138
    tx_count_id = 1102144
    results = mock_async_fetch(
        DuneAPI.new_from_environment(), [block_count_id, tx_count_id]
    )
    print(results)
