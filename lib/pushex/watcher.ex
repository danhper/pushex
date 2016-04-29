defmodule Pushex.Watcher do
  @moduledoc false

  use GenServer
  require Logger

  @name __MODULE__

  def start_link(m, f, a) do
    import Supervisor.Spec
    child = worker(__MODULE__, [], function: :watcher, restart: :transient)
    options = [strategy: :simple_one_for_one, name: @name]
    case Supervisor.start_link([child], options) do
      {:ok, _res} = ok ->
        _ = for {mod, handler, args} <- apply(m, f, a) do
            watch(mod, handler, args)
        end
        ok
    end
  end

  def watch(mod, handler, args) do
    case Supervisor.start_child(@name, [mod, handler, args]) do
      {:ok, _pid} = res ->
        res
      {:error, _reason} = err ->
        err
    end
  end

  def watcher(mod, handler, args) do
    GenServer.start_link(__MODULE__, {mod, handler, args})
  end

  def init({mod, handler, args}) do
    ref = Process.monitor(mod)
    case GenEvent.add_mon_handler(mod, handler, args) do
      :ok ->
        {:ok, {mod, handler, ref}}
      {:error, :ignore} ->
        send(self(), {:gen_event_EXIT, handler, :normal})
        {:ok, {mod, handler, ref}}
      {:error, reason} ->
        {:stop, reason}
    end
  end

  @doc false
  def handle_info({:gen_event_EXIT, handler, reason}, {_, handler, _} = state)
      when reason in [:normal, :shutdown] do
    {:stop, reason, state}
  end

  def handle_info({:gen_event_EXIT, handler, reason}, {mod, handler, _} = state) do
    _ = Logger.error "GenEvent handler #{inspect handler} installed at #{inspect mod}\n" <>
      "** (exit) #{format_exit(reason)}"
    {:stop, reason, state}
  end

  def handle_info({:DOWN, ref, _, _, reason}, {mod, handler, ref} = state) do
    _ = Logger.error "GenEvent handler #{inspect handler} installed at #{inspect mod}\n" <>
      "** (exit) #{format_exit(reason)}"
    {:stop, reason, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp format_exit({:EXIT, reason}), do: Exception.format_exit(reason)
  defp format_exit(reason), do: Exception.format_exit(reason)
end
