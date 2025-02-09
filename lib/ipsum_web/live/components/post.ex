defmodule IpsumWeb.Components.Post do
  alias Ipsum.Posts
  alias Ipsum.Accounts
  alias IpsumWeb.Components.Button
  use IpsumWeb, :live_component

  def render(assigns) do
    ~H"""
    <div
      id={@id}
      class="post w-full animate-post-enter min-w-[280px] px-3 sm:px-6 py-6 sm:py-12 shadow-lg backdrop-blur-sm bg-opacity-95 hover:brightness-110 transition-all duration-200"
    >
      <% user = Accounts.get_user!(@post.user_id) %>
      <div class="flex items-start gap-3 sm:gap-4 mb-3">
        <div
          class="w-8 h-8 sm:w-12 sm:h-12 bg-[--contrast] rounded-full hover:scale-105 transition-transform duration-300 cursor-pointer shrink-0 shadow-md"
          style={"background: var(--gradient-#{user.gradient})"}
        >
        </div>

        <div class="flex-1">
          <div class="flex flex-col gap-1">
            <a
              class="text-[--text] font-semibold hover:underline transition-colors duration-200 max-w-[140px] sm:max-w-full truncate text-xs sm:text-base"
              href={"/user/#{user.id}"}
            >
              {user.id}
            </a>
            <span class="text-[--secondary] text-[10px] sm:text-xs">2 hours ago</span>
          </div>
        </div>
      </div>

      <div class=" mb-8 sm:mb-12">
        <p class="pt-4 text-xs sm:text-base text-[--text] leading-relaxed">
          {@post.body}
        </p>
      </div>

      <div class="flex border-t border-b border-[--highlight] py-1 mb-4">
        <button class="flex-1 flex items-center justify-center gap-1 sm:gap-2 text-[--secondary] hover:text-[--primary] transition-colors duration-200 py-1 sm:py-2">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="size-4 sm:size-6"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M21 8.25c0-2.485-2.099-4.5-4.688-4.5-1.935 0-3.597 1.126-4.312 2.733-.715-1.607-2.377-2.733-4.313-2.733C5.1 3.75 3 5.765 3 8.25c0 7.22 9 12 9 12s9-4.78 9-12Z"
            />
          </svg>
          <span class="text-xs sm:text-sm">Like</span>
        </button>

        <button class="flex-1 flex items-center justify-center gap-1 sm:gap-2 text-[--secondary] hover:text-[--primary] transition-colors duration-200 py-1 sm:py-2">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="size-4 sm:size-6"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M7.5 8.25h9m-9 3H12m-9.75 1.51c0 1.6 1.123 2.994 2.707 3.227 1.129.166 2.27.293 3.423.379.35.026.67.21.865.501L12 21l2.755-4.133a1.14 1.14 0 0 1 .865-.501 48.172 48.172 0 0 0 3.423-.379c1.584-.233 2.707-1.626 2.707-3.228V6.741c0-1.602-1.123-2.995-2.707-3.228A48.394 48.394 0 0 0 12 3c-2.392 0-4.744.175-7.043.513C3.373 3.746 2.25 5.14 2.25 6.741v6.018Z"
            />
          </svg>
          <span class="text-xs sm:text-sm">Comment</span>
        </button>
      </div>

      <div class="mt-6 sm:mt-8 flex items-center gap-2 sm:gap-3">
        <div
          class="w-6 h-6 sm:w-8 sm:h-8 bg-[--contrast] rounded-full shrink-0"
          style={"background: var(--gradient-#{@current_user.gradient})"}
        >
        </div>
        <form phx-target={@myself} phx-submit="create_comment" class="flex-1">
          <input type="hidden" name="post_id" value={@post.id} />
          <input
            type="text"
            name="content"
            class="input bg-[--contrast] w-full text-xs sm:text-sm p-2 resize-none rounded-full"
            placeholder="Write a comment..."
            autocomplete="off"
          />
          <!-- Added submit button -->
        </form>
      </div>
    </div>
    """
  end

  def handle_event("create_comment", %{"post_id" => post_id, "content" => content}, socket) do
    comment_params = %{
      content: content,
      post_id: post_id,
      user_id: socket.assigns.current_user.id
    }

    case Posts.create_comment(comment_params) do
      {:ok, _} ->
        socket = redirect(socket, to: "/posts/#{post_id}")
        {:noreply, socket}

      {:error, _} ->
        {:noreply, socket}
    end
  end
end
