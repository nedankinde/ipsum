defmodule IpsumWeb.HomeLive.Index do
  alias Ipsum.Posts
  use IpsumWeb, :live_view

  def mount(_params, session, socket) do
    socket = socket |> assign(:show_sidebar, false)
    if connected?(socket), do: Phoenix.PubSub.subscribe(Ipsum.PubSub, "posts")

    socket =
      assign_new(socket, :current_user, fn ->
        Ipsum.Accounts.get_user_by_session_token(session["user_token"])
      end)
      |> assign(:show_post_modal, false)

    {:ok,
     assign(socket |> stream(:posts, Posts.list_posts()), post_content: "", post_changeset: %{})}
  end

  def render(assigns) do
    ~H"""
    <div class="flex w-full h-screen overflow-hidden">
      <.live_component
        module={IpsumWeb.Components.Sidebar}
        id="sidebar"
        user={assigns[:current_user]}
        active={:home}
      />
      <div class="w-full h-full md:pb-0">
        <.live_component
          module={IpsumWeb.Components.Feed}
          id="feed"
          user={assigns[:current_user]}
          post_content={assigns[:post_content]}
          post_changeset={assigns[:post_changeset]}
          posts={@streams.posts}
          enable_filters={true}
          show_create_post={true}
        />
        <.live_component
          module={IpsumWeb.Components.MobileNav}
          id="mobile_nav"
          user={assigns[:current_user]}
          active={:home}
        />
      </div>
      <%!-- remove later --%>
      <div class="hidden 2xl:flex flex-col min-w-[400px] mt-12 space-y-6 pr-8">
        <div class="card px-8 py-6 hover:border-[--primary] transition-colors duration-200">
          <h3 class="text-lg font-semibold mb-6 flex items-center">
            <.icon name="hero-users" class="w-5 h-5 mr-2 text-[--primary]" /> Who to Follow
          </h3>
          <div class="space-y-4">
            <div :for={user <- 1..3} class="flex items-center gap-4 group">
              <div class="w-12 h-12 rounded-full overflow-hidden bg-gradient-to-br from-[--primary] to-[--teal] opacity-75">
              </div>
              <div class="flex-1">
                <div class="text-sm font-medium group-hover:text-[--primary] transition-colors">
                  Jane Smith
                </div>
                <div class="text-sm text-[--secondary]">@janesmith</div>
              </div>
              <button class="button button-primary px-4">Follow</button>
            </div>
          </div>
        </div>

        <div class="card p-8 hover:border-[--teal] transition-colors duration-200">
          <h3 class="text-lg font-semibold mb-6 flex items-center">
            <.icon name="hero-chart-bar" class="w-5 h-5 mr-2 text-[--teal]" /> Trending Topics
          </h3>
          <div class="space-y-4">
            <div
              :for={topic <- ["ElixirLang", "Phoenix", "LiveView", "WebDev"]}
              class="group cursor-pointer"
            >
              <div class="flex items-center gap-2 py-2 group-hover:text-[--teal] transition-colors">
                <span class="text-[--secondary]">#</span>
                <span class="font-medium">{topic}</span>
              </div>
              <div class="text-sm text-[--secondary]">1,234 posts</div>
            </div>
          </div>
        </div>
      </div>

      <%= if assigns[:show_post_modal] do %>
        <div class="absolute top-0 left-0 w-full h-full overflow-hidden backdrop-blur-sm flex items-center justify-center">
          <div class="top-0 left-0 absolute w-full h-full bg-[--darkest] opacity-60"></div>
          <div class="relative w-full h-1/2 sm:w-1/2 z-10">
            <.live_component
              module={IpsumWeb.Components.CreatePost}
              id="create_post_modal"
              post_content={@post_content}
              post_changeset={@post_changeset}
              user={@current_user}
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
end
