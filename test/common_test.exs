defmodule CommonTest do
  use Plug.OnMaintenance.EnabledTestCase

  describe "retry_after is not nil" do
    setup do
      with_mocks [
        {Plug.OnMaintenance.Util, [:passthrough],
        [on_maintenance?: fn() -> true end, retry_after_header: fn() -> "300" end]}
      ] do

        conn = build_conn("/test", "text/plain")
        {:ok, conn: conn}

      end
    end

    test "status is 503", %{conn: conn} do
      assert {503, _, _} = sent_resp(conn)
    end

    test "retry-header is 300(default)", %{conn: conn} do
      assert get_resp_header(conn, "retry-after") == ["300"]
    end

    test "state is sent", %{conn: conn} do
      assert conn.state == :sent
    end
  end

  describe "retry_after is nil" do
    setup do
      with_mocks [
        {Plug.OnMaintenance.Util, [:passthrough],
        [on_maintenance?: fn() -> true end, retry_after_header: fn() -> nil end]}
      ] do

        conn = build_conn("/test", "text/plain")
        {:ok, conn: conn}

      end
    end

    test "status is 503", %{conn: conn} do
      assert {503, _, _} = sent_resp(conn)
    end

    test "retry-header is 300(default)", %{conn: conn} do
      assert get_resp_header(conn, "retry-after") == []
    end

    test "state is sent", %{conn: conn} do
      assert conn.state == :sent
    end
  end
end
