defmodule IpsumWeb.Components.Feed do
  alias IpsumWeb.Components.ProfileDesc
  alias IpsumWeb.Components.Post
  alias IpsumWeb.Components.Filter
  alias IpsumWeb.Components.Searchbar
  alias IpsumWeb.Components.CreatePost
  use IpsumWeb, :live_component

  def render(assigns) do
    ~H"""
    <div
      class="w-full h-full flex flex-col items-center py-6 md:py-12 px-4 md:px-36 overflow-x-hidden overflow-y-auto"
      style="scrollbar-gutter: stable; background-color: var(--background);"
    >
      <%= if @enable_filters do %>
        <%!-- <.live_component module={Searchbar} id="seachbar" /> --%>
      <% end %>

      <%= if @show_create_post do %>
        <.live_component
          module={CreatePost}
          id="create_post"
          user={@user}
          post_content={@post_content}
          post_changeset={@post_changeset}
        />
      <% end %>

      <%= if @enable_filters do %>
        <.live_component module={Filter} id="filter" />
      <% else %>
        <div class="py-3"></div>
      <% end %>

      <%= if assigns[:show_profile_desc] do %>
        <.live_component
          module={ProfileDesc}
          is_following={assigns[:is_following]}
          id="profile_desc"
          user={@user}
        />
      <% end %>

      <div id="posts" phx-update="stream" class="posts w-full">
        <div :for={{id, post} <- @posts} id={id}>
          <.live_component module={Post} id={post.id} post={post} current_user={@user} />
        </div>
      </div>
    </div>
    """
  end
end
