defmodule IpsumWeb.CreatePost do
  use IpsumWeb, :live_component
  alias Ipsum.Posts
  alias Phoenix.PubSub

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
         socket
         |> assign(:post_content, "")
         |> assign(:post_changeset, %{})
         |> assign(:show_post_modal, false)
         |> stream_insert(:posts, post, at: 0)}

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
end
