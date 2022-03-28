from duneapi.dashboard import DuneDashboard
from duneapi.api import DuneAPI

dashboard = DuneDashboard.from_file(
    api=DuneAPI.new_from_environment(),
    filename="./src/dashboards/locked_gno_dashboard.json",
)
# dashboard.update()
# print("Updated", dashboard)
