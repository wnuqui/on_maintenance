defmodule Plug.OnMaintenance.Util do
  @on_maintenance_db ".on_maintenance.sqlite3"
  @message "Application on scheduled maintenance."

  def on_maintenance? do
    {:ok, db} = Sqlitex.open(@on_maintenance_db)
    records = Sqlitex.query!(db, select_sql())
    on_maintenance = Enum.map(records, &(&1[:on_maintenance]))

    hd(on_maintenance) == 1
  end

  def enable_maintenance(retry_after) do
    Mix.shell.info "Putting application in maintenance mode."
    do_enable_maintenance(true, retry_after)
  end

  def disable_maintenance do
    Mix.shell.info "Disabling maintenance mode for application."
    do_enable_maintenance(false)
  end

  def message do
    Application.get_env(:on_maintenance, :message) || @message
  end

  def on_maintenance_db, do: @on_maintenance_db

  def retry_after_header do
    {:ok, db} = Sqlitex.open(@on_maintenance_db)

    records = Sqlitex.query!(db, select_sql())
    retry_after = Enum.map(records, &(&1[:retry_after]))

    retry_after = retry_after |> hd()
    if retry_after == 0, do: nil, else: to_string(retry_after)
  end

  def insert_record_sql(on_maintenance, retry_after, created_at) do
    "INSERT INTO on_maintenance_configs ("                  <> "\n" <> \
    "  on_maintenance, retry_after, created_at, updated_at" <> "\n" <> \
    ") " <>  "VALUES (" <> on_maintenance <> ", " <> retry_after <> ", '" <> created_at <> "', '" <> created_at <> "')"
  end

  def select_sql do
    "SELECT id, on_maintenance, retry_after FROM on_maintenance_configs ORDER BY id DESC LIMIT 1"
  end

  defp do_enable_maintenance(enable, retry_after_val \\ 0) do
    {:ok, db} = Sqlitex.open(@on_maintenance_db)

    created_at = DateTime.utc_now() |> DateTime.to_iso8601()
    on_maintenance = if enable, do: "1", else: "0"

    sql = insert_record_sql(on_maintenance, to_string(retry_after_val), created_at)
    :ok = Sqlitex.exec(db, sql)
  end
end
