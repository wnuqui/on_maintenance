defmodule HtmlTest do
  use Plug.OnMaintenance.EnabledTestCase

  setup do
    with_mocks [
      {Plug.OnMaintenance.Util, [:passthrough],
      [on_maintenance?: fn() -> true end, retry_after_header: fn() -> "300" end]}
    ] do

      conn = build_conn("/test", "text/html")
      {:ok, conn: conn}

    end
  end

  test "content-type is html", %{conn: conn} do
    assert ["text/html" <> _] = get_resp_header(conn, "content-type")
  end

  test "message", %{conn: conn} do
    {_, _, body} = sent_resp(conn)
    assert body == "<html><body>Application on scheduled maintenance.</body></html>"
  end
end
