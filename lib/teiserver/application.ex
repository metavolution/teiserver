defmodule Teiserver.Application do
  @moduledoc false
  def children() do
    children = [
      # Ranch servers
      %{
        id: Teiserver.SSLTcpServer,
        start: {Teiserver.TcpServer, :start_link, [[ssl: true]]}
      },
      %{
        id: Teiserver.RawTcpServer,
        start: {Teiserver.TcpServer, :start_link, [[]]}
      },

      # Caches
      concache_perm_sup(:id_counters),
      concache_perm_sup(:lists),
      concache_perm_sup(:users_lookup_name_with_id),
      concache_perm_sup(:users_lookup_id_with_name),
      concache_perm_sup(:users_lookup_id_with_email),
      concache_perm_sup(:users),
      concache_perm_sup(:clients),
      concache_perm_sup(:battles),
      concache_perm_sup(:teiserver_queues),
      concache_perm_sup(:rooms),
      concache_sup(:teiserver_clan_cache_bang),
      concache_sup(:teiserver_login_count),

      # Matchmaking
      concache_perm_sup(:teiserver_queue_pids),
      {DynamicSupervisor, strategy: :one_for_one, name: Teiserver.Game.QueueSupervisor},
      {DynamicSupervisor, strategy: :one_for_one, name: Teiserver.Game.QueueMatchSupervisor},

      # Director mode
      concache_perm_sup(:teiserver_consul_pids),
      {DynamicSupervisor, strategy: :one_for_one, name: Teiserver.Director.DynamicSupervisor},

      # Telemetry
      {Teiserver.Telemetry.TelemetryServer, name: Teiserver.Telemetry.TelemetryServer},
    ]

    # Agent mode stuff, should not be enabled in prod
    children = if Application.get_env(:central, Teiserver)[:enable_agent_mode] do
      children ++
        [
          {Registry, keys: :unique, name: Teiserver.Agents.ServerRegistry},
          {DynamicSupervisor, strategy: :one_for_one, name: Teiserver.Agents.DynamicSupervisor},
        ]
    else
      children
    end

    # Some stuff doesn't work with the tests
    # but we're not that fussed about having it automatically
    # tested
    if Application.get_env(:central, Teiserver)[:enable_hooks] do
      children ++
        [
          {Teiserver.HookServer, name: Teiserver.HookServer}
        ]
    else
      children
    end
  end

  defp concache_sup(name) do
    Supervisor.child_spec(
      {
        ConCache,
        [
          name: name,
          ttl_check_interval: 10_000,
          global_ttl: 60_000,
          touch_on_read: true
        ]
      },
      id: {ConCache, name}
    )
  end

  defp concache_perm_sup(name) do
    Supervisor.child_spec(
      {
        ConCache,
        [
          name: name,
          ttl_check_interval: false
        ]
      },
      id: {ConCache, name}
    )
  end
end
