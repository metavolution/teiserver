defmodule TeiserverWeb.General.GeneralControllerTest do
  use CentralWeb.ConnCase

  alias Central.Helpers.GeneralTestLib

  setup do
    GeneralTestLib.conn_setup(Teiserver.TeiserverTestLib.player_permissions())
    |> Teiserver.TeiserverTestLib.conn_setup()
  end

  test "index", %{conn: conn} do
    conn = get(conn, "/")

    # assert html_response(conn, 200) =~ "Account"
    assert redirected_to(conn) == Routes.general_page_path(conn, :index)
  end
end
