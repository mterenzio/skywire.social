defmodule Skywire.BlueskyClient do
  use WebSockex

  @firehose_url "wss://jetstream2.us-east.bsky.network/subscribe?wantedCollections=app.bsky.feed.post"

  def start_link(_opts \\ []) do
    WebSockex.start_link(@firehose_url, __MODULE__, %{}, name: __MODULE__)
  end

  # Handle incoming frames (messages)
  def handle_frame({:text, msg}, state) do
    IO.puts("🔥 Received message:")
    IO.inspect(msg)

    with {:ok, decoded} <- Jason.decode(msg),
        %{"kind" => "commit", "commit" => %{"collection" => "app.bsky.feed.post", "record" => record}} <- decoded,
        %{"text" => text, "createdAt" => created_at} <- record do

      post = %{"text" => text, "createdAt" => created_at}
      Phoenix.PubSub.broadcast(Skywire.PubSub, "posts", {:new_post, post})

    else
      _ -> IO.puts("⚠️ Message did not match expected structure")
    end

    {:ok, state}
  end

  def handle_connect(_conn, state) do
    IO.puts("✅ Connected to Bluesky firehose.")
    {:ok, state}
  end

  def handle_disconnect(_reason, state) do
    IO.puts("⚠️ Disconnected from Bluesky.")
    {:ok, state}
  end
end


