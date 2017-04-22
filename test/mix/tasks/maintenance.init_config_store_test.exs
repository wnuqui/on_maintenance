Mix.shell(Mix.Shell.Process)

defmodule  Mix.Tasks.Maintenance.InitConfigStoreTest do
  use ExUnit.Case
  import Plug.OnMaintenance.Util, only: [on_maintenance_db: 0]

  setup do
    File.rm on_maintenance_db()
    on_exit fn ->
      File.rm on_maintenance_db()
    end
  end

  describe "run/1" do
    test "creates sqlite database file" do
      refute File.exists?(on_maintenance_db())
      Mix.Tasks.Maintenance.InitConfigStore.run([])
      assert File.exists?(on_maintenance_db())
    end

    test "creates on_maintenance_configs table with 1 record" do
      Mix.Tasks.Maintenance.InitConfigStore.run([])

      {:ok, db} = Sqlitex.open(on_maintenance_db())
      query = "SELECT id FROM on_maintenance_configs"
      records = Sqlitex.query!(db, query)
      assert length(records) == 1
    end

    test "prints log to shell" do
      Mix.Tasks.Maintenance.InitConfigStore.run([])

      assert_received {:mix_shell, :info, [info]}

      assert info == \
      """
      .on_maintenance.sqlite3 db is created to store "on maintenance" configurations
      """
    end
  end

  describe "initial configuration" do
    setup do
      Mix.Tasks.Maintenance.InitConfigStore.run([])

      {:ok, db} = Sqlitex.open(on_maintenance_db())
      query = "SELECT id, on_maintenance, retry_after FROM on_maintenance_configs"
      config = Sqlitex.query!(db, query)
      %{config: config}
    end

    test "on_maintenance is 0", %{config: config} do
      [[id: _, on_maintenance: on_maintenance, retry_after: _]] = config
      assert on_maintenance == 0
    end

    test "retry_after is 0", %{config: config} do
      [[id: _, on_maintenance: _, retry_after: retry_after]] = config
      assert retry_after == 0
    end
  end
end
