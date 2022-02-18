defmodule Teiserver.Protocols.Tachyon.V1.UserIn do
  alias Teiserver.{User}
  alias Teiserver.Protocols.Tachyon.V1.Tachyon
  import Teiserver.Protocols.Tachyon.V1.TachyonOut, only: [reply: 4]

  @spec do_handle(String.t(), Map.t(), Map.t()) :: Map.t()
  def do_handle("query", %{"query" => _query}, state) do
    state
  end

  def do_handle("list_users_from_ids", %{"id_list" => id_list}, state) do
    users = User.list_users(id_list)
      |> Enum.filter(fn u -> u != nil end)
      |> Enum.map(fn u -> Tachyon.convert_object(:user, u) end)

    reply(:user, :user_list, users, state)
  end

  def do_handle("list_friend_ids", _, state) do
    friend_list = User.get_user_by_id(state.userid).friends
    reply(:user, :friend_id_list, friend_list, state)
  end

  def do_handle(cmd, data, state) do
    reply(:system, :error, %{location: "auth.handle", error: "No match for cmd: '#{cmd}' with data '#{Kernel.inspect data}'"}, state)
  end
end