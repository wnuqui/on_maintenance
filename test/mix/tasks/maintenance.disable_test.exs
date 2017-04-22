Mix.shell(Mix.Shell.Process)

defmodule  Mix.Tasks.Maintenance.DisableTest do
  use ExUnit.Case
  import Plug.OnMaintenance.Util

  setup do
    File.rm on_maintenance_db()
    Mix.Tasks.Maintenance.InitConfigStore.run([])
    on_exit fn ->
      File.rm on_maintenance_db()
    end
  end

  describe "run/1" do
    setup do
      assert_received {:mix_shell, :info, [_]}
      {:ok, db} = Sqlitex.open(on_maintenance_db())
      Mix.Tasks.Maintenance.Disable.run([])
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
end
