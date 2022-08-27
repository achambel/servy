defmodule Servy.PledgeServer do
  @process_name :pledge_server

  # act as a server
  def listen_loop(state) do
    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)
        most_recent_pledges = Enum.take(state, 2)
        new_state = [{name, amount} | most_recent_pledges]
        send(sender, {:response, id})

        listen_loop(new_state)

      {sender, :recent_pledges} ->
        send(sender, {:response, state})
        listen_loop(state)

      {sender, :total_pledged} ->
        total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
        send(sender, {:response, total})
        listen_loop(state)

        # unexpected ->
        #   IO.puts("Unexpected message arrived: #{inspect(unexpected)}")
        #   listen_loop(state)
    end
  end

  # the client interface
  def start do
    IO.puts("Starting the pledge server...")

    pid = spawn(__MODULE__, :listen_loop, [[]])
    Process.register(pid, @process_name)

    pid
  end

  def create_pledge(name, amount) do
    send(@process_name, {self(), :create_pledge, name, amount})

    receive do
      {:response, status} -> status
    end
  end

  def recent_pledges() do
    send(@process_name, {self(), :recent_pledges})

    receive do
      {:response, pledges} -> pledges
    end
  end

  def total_pledged() do
    send(@process_name, {self(), :total_pledged})

    receive do
      {:response, total} -> total
    end
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE 
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

# alias Servy.PledgeServer
#
# PledgeServer.start()
#
# PledgeServer.create_pledge("larry", 10) |> IO.puts()
# PledgeServer.create_pledge("moe", 20) |> IO.puts()
# PledgeServer.create_pledge("curly", 30) |> IO.puts()
# PledgeServer.create_pledge("daisy", 40) |> IO.puts()
# PledgeServer.create_pledge("grace", 50) |> IO.puts()
# PledgeServer.create_pledge("bruce", 60) |> IO.puts()
#
# PledgeServer.recent_pledges() |> IO.inspect()
