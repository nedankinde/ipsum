defmodule IpsumWeb.PostLive.Index do
  use IpsumWeb, :live_view

  alias Ipsum.Posts
  alias Ipsum.Posts.Post

  @impl true
  def mount(_params, session, socket) do
    user =
      case session do
        %{"user_token" => token} -> Ipsum.Accounts.get_user_by_session_token(token)
        _ -> nil
      end

    {:ok,
     socket
     |> assign(:current_user, user)
     |> stream(:posts, Posts.list_posts())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    post = Posts.get_post!(id)

    if can_modify_post?(socket.assigns.current_user, post) do
      socket
      |> assign(:page_title, "Edit Post")
      |> assign(:post, post)
    else
      socket
      |> put_flash(:error, "You cannot edit this post")
      |> push_navigate(to: ~p"/posts")
    end
  end

  defp apply_action(socket, :new, params) do
    user_id = socket.assigns.current_user && socket.assigns.current_user.id

    IO.inspect(params)

    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{id: Ecto.UUID.generate(), user_id: user_id, body: params["body"]})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
  end

  @impl true
  def handle_info({IpsumWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    {:noreply, stream_insert(socket, :posts, post)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Posts.get_post!(id)

    if can_modify_post?(socket.assigns.current_user, post) do
      {:ok, _} = Posts.delete_post(post)
      {:noreply, stream_delete(socket, :posts, post)}
    else
      {:noreply,
       socket
       |> put_flash(:error, "You cannot delete this post")
       |> push_navigate(to: ~p"/posts")}
    end
  end

  defp can_modify_post?(%Ipsum.Accounts.User{id: user_id}, %Post{user_id: post_user_id}) do
    user_id == post_user_id
  end
end
