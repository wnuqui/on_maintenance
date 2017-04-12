defmodule Plug.OnMaintenance.TestCase do
  @moduledoc """
  This module defines the test case to be used by Plug.OnMaintenance tests.
  Such tests rely on `ExUnit.Case` and `Plug.Test`.
  """

  use ExUnit.CaseTemplate

  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case
      use Plug.Test
      import Mock
    end
  end
end
