defmodule Mix.Tasks.Maintenance.InitConfigStore do
  use Mix.Task
  import Plug.OnMaintenance.Util

  @shortdoc "Create .on_maintenance.sqlite3 database."

  @moduledoc """
  Creates ".on_maintenance.sqlite3" database which contains only 1 table.

  Table ".on_maintenance_configs" will be initialized with 1 row of data:
  - **0** value for **on_maintenance** column means the application is not in maintenance mode.
  - **0** value for **retry_after** column means **0** `retry-after` header for 503 response.
    This value is not applicable since **on_maintenance** is **0**.
    When **on_maintenance** is **1**, **retry_after** must be **> 0**.
    This value is the expected duration of maintenance in seconds.

  ## Example
      mix maintenance.init_config_store
  """

  def run(_argv) do
    {:ok, _}  = File.open(on_maintenance_db(), [:write])
    {:ok, db} = Sqlitex.open(on_maintenance_db())

    :ok = Sqlitex.exec(db, create_table_sql())

    on_maintenance = "0"
    retry_after = "0"
    created_at = DateTime.utc_now() |> DateTime.to_iso8601()

    :ok = Sqlitex.exec(db, insert_record_sql(on_maintenance, retry_after, created_at))

    records = Sqlitex.query!(db, select_sql())
    records = Enum.map(records, &(&1[:on_maintenance]))

    if hd(records) == 0 do
      Mix.shell.info """
      .on_maintenance.sqlite3 db is created to store "on maintenance" configurations
      """
    end
  end

  defp create_table_sql do
    """
    CREATE TABLE on_maintenance_configs (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      on_maintenance INTEGER NOT NULL,
      retry_after INTEGER NOT NULL,
      created_at datetime NOT NULL,
      updated_at datetime NOT NULL
    )
    """
  end
end
