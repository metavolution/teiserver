defmodule Central.Dev do
  @moduledoc false
  @behaviour Bodyguard.Policy

  import Teiserver.Account.AuthLib, only: [allow?: 2]

  # def colours, do: Teiserver.Helper.StylingHelper.colours(:success2)
  def icon, do: "fa-solid fa-power-off"

  def authorize(_, conn, _), do: allow?(conn, "admin.dev")
end
