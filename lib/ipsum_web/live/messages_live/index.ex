defmodule IpsumWeb.MessagesLive.Index do
  alias Ipsum.Accounts
  alias Ipsum.Chats
  use IpsumWeb, :live_view

  def mount(_params, session, socket) do
    socket = socket |> assign(:show_sidebar, false)

    if connected?(socket), do: Phoenix.PubSub.subscribe(Ipsum.PubSub, "chats")

    socket =
      assign_new(socket, :current_user, fn ->
        Ipsum.Accounts.get_user_by_session_token(session["user_token"])
      end)
      |> assign(:show_post_modal, false)

    {:ok,
     assign(
       socket
       |> stream(:posts, [])
       |> stream(:chats, Chats.list_chats(socket.assigns.current_user.id)),
       post_content: "",
       post_changeset: %{}
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="flex lg:gap-1 w-full h-screen overflow-hidden bg-[var(--background)]">
      <div class="flex flexcols">
        <.live_component
          module={IpsumWeb.Components.Sidebar}
          id="sidebar"
          user={assigns[:current_user]}
          active={:messages}
        />
        <.live_component
          module={IpsumWeb.Components.MobileNav}
          id="mobile_nav"
          user={assigns[:current_user]}
          active={:messages}
        />
      </div>

      <div class="w-full bg-[var(--contrast)]">
        <h1 class="text-3xl text-[var(--text)] px-10 py-10 font-bold">Messages</h1>
        <div id="chats" phx-update="stream" class="flex flex-col gap-4">
          <%= for {id, chat} <- @streams.chats do %>
            <div
              id={id}
              class="card mx-10 p-6 hover:bg-[var(--highlight)] transition-all hover:scale-[1.01] flex items-center gap-4"
            >
              <.link
                class="font-bold text-sm text-[var(--secondary)] hover:text-[var(--text)] transition-colors"
                navigate={"/chat/#{chat.id}"}
              >
                <%= if chat.user_1_id == @current_user.id do %>
                  {chat.user_2_id}
                <% else %>
                  {chat.user_1_id}
                <% end %>
              </.link>
            </div>
          <% end %>
        </div>
      </div>

      <%= if assigns[:show_post_modal] do %>
        <div class="fixed inset-0 flex items-center justify-center lg:items-start lg:pt-32 overflow-hidden backdrop-blur-md">
          <div class="absolute inset-0 bg-[var(--background)] opacity-70"></div>
          <div class="relative w-full max-w-lg mx-auto px-4 sm:px-6 lg:px-8 z-10 m-4">
            <.live_component
              module={IpsumWeb.Components.CreatePost}
              id="create_post_modal"
              post_content={@post_content}
              post_changeset={@post_changeset}
              user={@current_user}
              class="w-full max-w-md sm:max-w-lg lg:max-w-xl"
            />
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def handle_event("create_post_modal", _params, socket) do
    IpsumWeb.CreatePost.handle_event("create_post_modal", _params, socket)
  end

  def handle_event("create_post", %{"content" => content}, socket) do
    IpsumWeb.CreatePost.handle_event("create_post", %{"content" => content}, socket)
  end

  def handle_event(
        "post_form_update",
        %{"content" => content},
        socket
      ) do
    IpsumWeb.CreatePost.handle_event(
      "post_form_update",
      %{"content" => content},
      socket
    )
  end

  def handle_info({:post_created, post}, socket) do
    {:noreply, stream_insert(socket, :posts, post, at: 0)}
  end

  def handle_event("toggle_sidebar", _params, socket) do
    {:noreply, socket |> assign(:show_sidebar, !@show_sidebar)}
  end
end
