defmodule Plug.OnMaintenance.EnabledTestCase do
  @moduledoc """
  This module defines the test case to be used by Plug.OnMaintenance "enabled" tests.
  Such tests rely on `Plug.OnMaintenance.TestCase`, `Plug.OnMaintenance.EnabledTestCase` and `Plug.OnMaintenance.Util`.
  """

  use ExUnit.CaseTemplate
  import Plug.Conn

  defmacro __using__(_opts) do
    quote do
      use Plug.OnMaintenance.TestCase
      import Plug.OnMaintenance.EnabledTestCase
      import Plug.OnMaintenance.Util, only: [enable_maintenance: 1]
    end
  end

  def build_conn(path, accept) do
    conn = Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :get, path, "")
    |> put_req_header("accept", accept)
    |> Router.call([])

    conn
  end
end
