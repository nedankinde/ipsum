defmodule IpsumWeb.Components.ProfileDesc do
  use IpsumWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="card w-full p-6 flex flex-col sm:flex-row sm:justify-between sm:items-center gap-4">
      <div class="flex flex-col justify-center text-center md:flex-row gap-3 items-center">
        <div class="w-14 h-14 rounded-full" style={"background: var(--gradient-#{@user.gradient})"}>
        </div>
        <h3 class="font-semibold">{@user.id}</h3>
      </div>
      <div class="flex flex-col sm:flex-row gap-3 w-full sm:w-auto">
        <form phx-submit="create_chat" class="m-0 w-full sm:w-auto">
          <input type="hidden" name="user_id" value={@user.id} />
          <button type="submit" class="button button-primary w-full px-4 sm:w-auto">
            Message
          </button>
        </form>
        <div id="links" class="w-full sm:w-auto">
          <%= if @is_following do %>
            <form phx-submit="remove_follow" class="m-0">
              <input type="hidden" name="user_id" value={@user.id} />
              <button type="submit" class="button button-secondary px-4 w-full sm:w-auto">
                Unfollow
              </button>
            </form>
          <% else %>
            <form phx-submit="create_follow" class="m-0">
              <input type="hidden" name="user_id" value={@user.id} />
              <button type="submit" class="button button-primary px-4 w-full sm:w-auto">
                Follow
              </button>
            </form>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
