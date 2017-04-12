defmodule JsonTest do
  use Plug.OnMaintenance.EnabledTestCase

  setup do
    with_mocks [
      {Plug.OnMaintenance.Util, [:passthrough],
      [on_maintenance?: fn() -> true end, retry_after_header: fn() -> "300" end]}
    ] do

      conn = build_conn("/test", "application/json")
      {:ok, conn: conn}

    end
  end

  test "content-type is json", %{conn: conn} do
    assert ["application/json" <> _] = get_resp_header(conn, "content-type")
  end

  test "message", %{conn: conn} do
    {_, _, body} = sent_resp(conn)
    assert body == Poison.encode!(%{message: "Application on scheduled maintenance."})
  end
end
