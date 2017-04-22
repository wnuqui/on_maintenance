Mix.shell(Mix.Shell.Process)

defmodule Plug.OnMaintenance.UtilTest do
  use Plug.OnMaintenance.EnabledTestCase
  import Plug.OnMaintenance.Util

  setup do
    File.rm on_maintenance_db()
    Mix.Tasks.Maintenance.InitConfigStore.run([])

    on_exit fn ->
      File.rm on_maintenance_db()
    end
  end

  describe "on_maintenance?/0" do
    test "returns true" do
      enable_maintenance 300
      assert on_maintenance?()
    end

    test "returns false" do
      disable_maintenance()
      refute on_maintenance?()
    end
  end

  describe "enable_maintenance/0" do
    setup do
      assert_received {:mix_shell, :info, [_]}
      {:ok, db} = Sqlitex.open(on_maintenance_db())
      enable_maintenance(300)
      %{db: db }
    end

    test "sets `on_maintenance` column to 1", %{db: db} do
      [[id: _, on_maintenance: on_maintenance, retry_after: _]] =
        Sqlitex.query!(db, select_sql())

      assert on_maintenance == 1
    end

    test "sets `retry_after` column to 300", %{db: db} do
      [[id: _, on_maintenance: _, retry_after: retry_after]] =
        Sqlitex.query!(db, select_sql())

      assert retry_after == 300
    end

    test "prints log to shell" do
      assert_received {:mix_shell, :info, [info]}
      assert info == "Putting application in maintenance mode."
    end
  end

  describe "disable_maintenance/0" do
    setup do
      assert_received {:mix_shell, :info, [_]}
      {:ok, db} = Sqlitex.open(on_maintenance_db())
      disable_maintenance()
      %{db: db }
    end

    test "sets `on_maintenance` column to 0", %{db: db} do
      [[id: _, on_maintenance: on_maintenance, retry_after: _]] =
        Sqlitex.query!(db, select_sql())

      assert on_maintenance == 0
    end

    test "sets `retry_after` column to 0", %{db: db} do
      [[id: _, on_maintenance: _, retry_after: retry_after]] =
        Sqlitex.query!(db, select_sql())

      assert retry_after == 0
    end

    test "prints log to shell" do
      assert_received {:mix_shell, :info, [info]}
      assert info == "Disabling maintenance mode for application."
    end
  end

  describe "retry_after_header?/0" do
    test "returns a value" do
      enable_maintenance 300
      assert retry_after_header() == "300"
    end

    test "returns nil" do
      enable_maintenance 0
      refute retry_after_header()
    end
  end
end
