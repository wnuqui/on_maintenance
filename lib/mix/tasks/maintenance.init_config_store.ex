require Logger

defmodule Mix.Tasks.Maintenance.InitConfigStore do
  use Mix.Task

  @shortdoc "Create .on_maintenance.sqlite3 database."
  @recursive true

  @moduledoc """
  Creates ".on_maintenance.sqlite3" database which contains only 1 table.
  The table, named "on_maintenance_configs", is initialized with 1 row of data:
    | on_maintenance  | retry_after   |
    | --------------- | ------------- |
    | 0               | 0             |
  - **0** value for **on_maintenance** means the application is not in maintenance mode.
  - **1** value for **retry_after** no `retry-after` header for 503 response.

  ## Example
      mix maintenance.init_config_store
  """

  def run(_argv) do
    {:ok, _} = File.open Plug.OnMaintenance.Util.on_maintenance_db(), [:write]

    {:ok, db} = Sqlitex.open(Plug.OnMaintenance.Util.on_maintenance_db())

    :ok = Sqlitex.exec(db, "CREATE TABLE on_maintenance_configs (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, on_maintenance INTEGER, retry_after INTEGER, created_at datetime NOT NULL, updated_at datetime NOT NULL)")

    now = DateTime.utc_now() |> DateTime.to_iso8601()
    :ok = Sqlitex.exec(db, "INSERT INTO on_maintenance_configs (on_maintenance, retry_after, created_at, updated_at) VALUES (0, 0, '" <> now <> "', '" <> now <> "')")

    query = "SELECT id, on_maintenance FROM on_maintenance_configs ORDER BY id DESC LIMIT 1"
    rows = Enum.map(Sqlitex.query!(db, query), &(&1[:on_maintenance]))

    if hd(rows) == 0 do
      Logger.info "sqlite db created to store application maintenance configurations."
    end
  end
end
