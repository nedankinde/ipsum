defmodule IpsumWeb.Components.Navbar do
  use IpsumWeb, :live_component

  def render(assigns) do
    ~H"""
    <ul class="relative z-10 flex items-center gap-2 px-2 sm:px-4 lg:px-6 justify-end flex-wrap">
      <%= if @current_user do %>
        <li class="text-[0.75rem] leading-5 text-zinc-900 break-all">
          {@current_user.email}
        </li>
        <li>
          <.link
            href={~p"/users/settings"}
            class="text-[0.75rem] leading-5 text-zinc-900 font-semibold hover:text-zinc-700"
          >
            Settings
          </.link>
        </li>
        <li>
          <.link
            href={~p"/users/log_out"}
            method="delete"
            class="text-[0.75rem] leading-5 text-zinc-900 font-semibold hover:text-zinc-700"
          >
            Log out
          </.link>
        </li>
      <% else %>
        <li>
          <.link
            href={~p"/users/register"}
            class="text-[0.75rem] leading-5 text-zinc-900 font-semibold hover:text-zinc-700"
          >
            Register
          </.link>
        </li>
        <li>
          <.link
            href={~p"/users/log_in"}
            class="text-[0.75rem] leading-5 text-zinc-900 font-semibold hover:text-zinc-700"
          >
            Log in
          </.link>
        </li>
      <% end %>
    </ul>
    """
  end
end
