defmodule Summerizer.User do
  @enforce_keys [:id, :name, :plan]
  defstruct [:id, :name, :plan]
end
