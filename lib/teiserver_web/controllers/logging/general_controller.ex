defmodule TeiserverWeb.Logging.GeneralController do
  use CentralWeb, :controller

  plug :add_breadcrumb, name: 'Logging', url: '/logging'

  plug(AssignPlug,
    site_menu_active: "logging",
    sub_menu_active: "general"
  )

  plug Bodyguard.Plug.Authorize,
    policy: Teiserver.Logging.LoggingLib,
    action: {Phoenix.Controller, :action_name},
    user: {Teiserver.Account.AuthLib, :current_user}

  @spec index(Plug.Conn.t(), Map.t()) :: Plug.Conn.t()
  def index(conn, _params) do
    render(conn, "index.html")
  end
end
