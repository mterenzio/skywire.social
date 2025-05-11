# lib/skywire_web/live/post_feed_live.ex
defmodule SkywireWeb.PostFeedLive do
  use SkywireWeb, :live_view

  # Subscribe to the "posts" topic when the LiveView is mounted
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Skywire.PubSub, "posts")

    {:ok, assign(socket, posts: [])}
  end

  # Handle new posts broadcasted from the Bluesky client via PubSub
  def handle_info({:new_post, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] |> Enum.take(50) end)}
  end

  # Render the posts on the page
  def render(assigns) do
    ~H"""
    <div id="post-feed">
      <%= for post <- @posts do %>
        <div class="post-card">
          <p><%= post["text"] %></p>
          <p><%= post["createdAt"] %></p>
        </div>
      <% end %>
    </div>
    """
  end
end

