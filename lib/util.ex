require Logger

defmodule Plug.OnMaintenance.Util do
  @on_maintenance_db ".on_maintenance.sqlite3"
  @message "Application on scheduled maintenance."

  def on_maintenance? do
    {:ok, db} = Sqlitex.open(@on_maintenance_db)

    query = "SELECT id, on_maintenance FROM on_maintenance_configs ORDER BY id DESC LIMIT 1"
    rows = Enum.map(Sqlitex.query!(db, query), &(&1[:on_maintenance]))

    hd(rows) == 1
  end

  def enable_maintenance(retry_after \\ 0) do
    Logger.info "Putting application in maintenace mode."
    do_enable_maintenance(true, retry_after)
  end

  def disable_maintenance do
    Logger.info "Disabling maintenance mode for application."
    do_enable_maintenance(false)
  end

  def message do
    Application.get_env(:on_maintenance, :message) || @message
  end

  def on_maintenance_db, do: @on_maintenance_db

  def retry_after_header do
    {:ok, db} = Sqlitex.open(@on_maintenance_db)

    query = "SELECT id, retry_after FROM on_maintenance_configs ORDER BY id DESC LIMIT 1"
    rows = Enum.map(Sqlitex.query!(db, query), &(&1[:retry_after]))

    rows |> hd() |> to_string()
  end

  defp do_enable_maintenance(enable, retry_after_val \\ 0) do
    {:ok, db} = Sqlitex.open(@on_maintenance_db)

    created_at = DateTime.utc_now() |> DateTime.to_iso8601()
    on_maintenance = if enable, do: "1", else: "0"
    retry_after = if enable, do: to_string(retry_after_val), else: "0"

    :ok = Sqlitex.exec(db, "INSERT INTO on_maintenance_configs (on_maintenance, retry_after, created_at, updated_at) VALUES (" <> on_maintenance <> "," <> retry_after <> ", '" <> created_at <> "', '" <> created_at <> "')")
  end
end
