defmodule IpsumWeb.PostLive.Show do
  alias Ipsum.Accounts.User
  alias IpsumWeb.Components.Post
  use IpsumWeb, :live_view

  alias Ipsum.Posts
  alias Ipsum.Accounts

  @impl true
  def mount(_params, session, socket) do
    user =
      case session do
        %{"user_token" => token} -> Ipsum.Accounts.get_user_by_session_token(token)
        _ -> nil
      end

    {:ok, socket |> assign(:current_user, user)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    try do
      case Ecto.UUID.cast(id) do
        {:ok, uuid} ->
          post = Posts.get_post!(uuid)
          found_user = Accounts.get_user!(post.user_id)
          current_user = socket.assigns.current_user

          {:noreply,
           socket
           |> assign(:page_title, page_title(socket.assigns.live_action))
           |> assign(:post, post)
           |> assign(:posted_by, found_user)
           |> assign(:is_creator, current_user && found_user.id == current_user.id)}

        :error ->
          {:noreply,
           socket
           |> put_flash(:error, "Invalid post ID")
           |> push_navigate(to: "/")}
      end
    rescue
      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Post not found")
         |> push_navigate(to: "/")}
    end
  end

  defp page_title(:show), do: "Show Post"
  defp page_title(:edit), do: "Edit Post"
end
