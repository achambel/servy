defmodule Servy.HttpServer do
  @doc """
  Starts the server on the given `port` of localhost.
  """
  def start(port) when is_integer(port) and port > 1023 do
    # Creates a socket to listen for client connections.
    # `listen_socket` is bound to the listening socket.

    # Socket options (don't worry about these details):
    # `:binary` - open the socket in "binary" mode and deliver data as binaries
    # `packet: :raw` - deliver the entire binary without doing any packet handling
    # `active: false` - receive data when we're ready by calling `:gen_tcp.recv/2`
    # `reuseaddr: true` - allows reusing the address if the listener crashes
    {:ok, listen_socket} =
      :gen_tcp.listen(port, [:binary, backlog: 30, packet: :raw, active: false, reuseaddr: true])

    IO.puts("\n🎧 Listening for connection requests on port #{port}...\n")

    accept_loop(listen_socket)
  end

  @doc """
  Accepts client connections on the `listen_socket`
  """
  def accept_loop(listen_socket) do
    IO.puts("⌛️ Waiting to accept a client connection...\n")

    # Suspends (blocks) and waits for a client connection. When a connection
    # is accepted, `client_socket` is bound to a new client socket.
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)

    IO.puts("⚡️Connection accepted!\n")

    # Receives the request and sends a response over the client socket.
    spawn(fn -> serve(client_socket) end)

    # Loop back tow ait and accept the next connection.
    accept_loop(listen_socket)
  end

  def serve(client_socket) do
    IO.puts("Working on it, pid: #{inspect(self())}")

    client_socket
    |> read_request
    |> Servy.Handler.handle()
    |> write_response(client_socket)
  end

  @doc """
  Receives a request on the `client_socket`.
  """
  def read_request(client_socket) do
    # all available bytes
    {:ok, request} = :gen_tcp.recv(client_socket, 0)

    IO.puts("-> Received request:\n")
    IO.puts(request)

    request
  end

  def generate_response(_request) do
    """
    HTTP/1.1 200 OK\r
    Content-Type: text/plain\r
    Content-Length: 6\r
    \r
    Hello!
    """
  end

  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)

    IO.puts("<- Sent response:\n")
    IO.puts(response)

    # Closes the client socket, ending the connection.
    # Does not close the listen socket!
    :gen_tcp.close(client_socket)
  end
end
