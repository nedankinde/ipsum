defmodule IpsumWeb.Components.CreatePost do
  alias IpsumWeb.Components.Button
  use IpsumWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="z-0 w-full">
      <.form for={@post_changeset} phx-submit="create_post">
        <input
          name="content"
          phx-change="post_form_update"
          value={@post_content}
          class="input bg-[--contrast] text-base sm:text-lg md:text-xl w-full py-2 md:py-4 align-start border-none outline-none focus:ring-0 resize-none"
          placeholder="What's on your mind?"
          autocomplete="off"
        />
      </.form>
    </div>
    """
  end
end
