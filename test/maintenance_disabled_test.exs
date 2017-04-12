defmodule DisabledTest do
  use Plug.OnMaintenance.TestCase

  setup do
    with_mock Plug.OnMaintenance.Util, [:passthrough], [on_maintenance?: fn() -> false end] do
      conn = conn(:get, "/test")
      |> put_req_header("accept", "text/plain")
      |> Router.call([])

      {:ok, conn: conn}
    end
  end

  test "status is 200", %{conn: conn} do
    assert {200, _, _} = sent_resp(conn)
  end

  test "content-type is html", %{conn: conn} do
    assert ["text/html" <> _] = get_resp_header(conn, "content-type")
  end

  test "message", %{conn: conn} do
    {_, _, body} = sent_resp(conn)
    assert body == "<html><body>Hello, World!</body></html>"
  end

  test "no retry-header in response", %{conn: conn} do
    assert get_resp_header(conn, "retry-after") == []
  end

  test "state is sent", %{conn: conn} do
    assert conn.state == :sent
  end
end
