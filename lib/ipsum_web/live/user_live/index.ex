defmodule IpsumWeb.UserLive.Index do
  alias Ipsum.Repo
  alias Ipsum.Posts
  alias Ipsum.Chats
  use IpsumWeb, :live_view
  import Ecto.Query

  def mount(%{"id" => id}, session, socket) do
    socket =
      assign_new(socket, :current_user, fn ->
        Ipsum.Accounts.get_user_by_session_token(session["user_token"])
      end)

    current_user = socket.assigns.current_user
    user = Ipsum.Accounts.get_user!(id)

    socket =
      socket
      |> assign(:user, user)
      |> assign(:show_post_modal, false)
      |> assign(:is_following, Ipsum.Accounts.is_following(current_user.id, user.id))

    {:ok,
     assign(socket |> stream(:posts, Posts.list_posts(user)),
       post_content: "",
       post_changeset: %{}
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="flex lg:gap-1 pb-14 lg:pb-0 w-full h-screen overflow-hidden">
      <div class="h-full flex">
        <.live_component
          module={IpsumWeb.Components.Sidebar}
          id="sidebar"
          user={assigns[:current_user]}
          active={:profile}
        />
        <.live_component
          module={IpsumWeb.Components.MobileNav}
          id="mobile_nav"
          user={assigns[:current_user]}
          active={:messages}
        />
      </div>
      <.live_component
        module={IpsumWeb.Components.Feed}
        id="feed"
        user={assigns[:user]}
        post_content={assigns[:post_content]}
        post_changeset={assigns[:post_changeset]}
        posts={@streams.posts}
        enable_filters={false}
        show_create_post={false}
        show_profile_desc={true}
        is_following={assigns[:is_following]}
      />
      <%!-- <.live_component module={IpsumWeb.Components.RecentChats} id="recent_chats" /> --%>
      <%= if assigns[:show_post_modal] do %>
        <div class="fixed inset-0 flex items-center justify-center lg:items-start lg:pt-32 overflow-hidden backdrop-blur-sm">
          <div class="absolute inset-0 bg-[--darkest] opacity-60"></div>
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

  def handle_event("create_follow", _params, socket) do
    user_1_id = socket.assigns.current_user.id
    user_2_id = socket.assigns.user.id

    if socket.assigns.is_following do
      {:noreply, socket}
    else
      case Ipsum.Accounts.create_follow(user_1_id, user_2_id) do
        {:ok, _follow} ->
          socket = assign(socket, :is_following, true)
          {:noreply, socket}

        {:error, _changeset} ->
          {:noreply, socket}
      end
    end
  end

  def handle_event("remove_follow", _params, socket) do
    user_1_id = socket.assigns.current_user.id
    user_2_id = socket.assigns.user.id

    if !socket.assigns.is_following do
      {:noreply, socket}
    else
      case Ipsum.Accounts.remove_follow(user_1_id, user_2_id) do
        {1, nil} ->
          socket = assign(socket, :is_following, false)
          {:noreply, socket}

        _ ->
          {:noreply, socket}
      end
    end
  end

  def handle_event("create_chat", _params, socket) do
    user_1_id = socket.assigns.current_user.id
    user_2_id = socket.assigns.user.id

    existing_chat =
      Ipsum.Repo.one(
        from c in Ipsum.Chats.Chat,
          where:
            (c.user_1_id == ^user_1_id and c.user_2_id == ^user_2_id) or
              (c.user_1_id == ^user_2_id and c.user_2_id == ^user_1_id),
          limit: 1
      )

    case existing_chat do
      %{id: chat_id} ->
        {:noreply, socket |> push_navigate(to: "/chat/#{chat_id}")}

      _ ->
        chat_attrs = %{user_1_id: user_1_id, user_2_id: user_2_id}

        case Ipsum.Chats.create_chat(chat_attrs) do
          {:ok, chat} ->
            {:noreply, socket |> push_navigate(to: "/chat/#{chat.id}")}

          {:error, _changeset} ->
            {:noreply, socket}
        end
    end
  end

  def handle_event("create_post_modal", _params, socket) do
    {:noreply, socket |> assign(:show_post_modal, true)}
  end

  def handle_event("create_post", %{"content" => content}, socket) do
    post_attrs = %{
      body: content,
      user_id: socket.assigns.current_user.id
    }

    case Posts.create_post(post_attrs) do
      {:ok, post} ->
        Phoenix.PubSub.broadcast(Ipsum.PubSub, "posts", {:post_created, post})

        {:noreply,
         if(post.user_id === socket.assigns.user.id) do
           socket
           |> assign(:post_content, "")
           |> assign(:post_changeset, %{})
           |> assign(:show_post_modal, false)
           |> stream_insert(:posts, post, at: 0)
         else
           socket
           |> assign(:post_content, "")
           |> assign(:post_changeset, %{})
           |> assign(:show_post_modal, false)
         end}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:post_changeset, changeset)}
    end
  end

  def handle_event(
        "post_form_update",
        %{"content" => content},
        socket
      ) do
    {:noreply, socket |> assign(:post_content, content)}
  end

  def handle_info({:post_created, post}, socket) do
    {:noreply, stream_insert(socket, :posts, post, at: 0)}
  end
end
