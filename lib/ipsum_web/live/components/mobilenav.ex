defmodule IpsumWeb.Components.MobileNav do
  alias IpsumWeb.Components.Button
  use IpsumWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="overflow-hidden">
      <div
        class="fixed bottom-0 left-0 w-full bg-[--background] border-t border-[--highlight] z-50 lg:hidden"
        id="mobile_nav"
      >
        <div class="flex items-center justify-between px-8 py-6 md:py-4 overflow-x-hidden">
          <div class={"transition-colors duration-200 text-[--secondary] hover:text-[--text] #{if @active == :home, do: "text-[--text]"}"}>
            <.link navigate={~p"/"} class="flex flex-col items-center">
              <i class="fa-solid fa-home text-xl"></i>
              <span class="text-xs mt-2 px-1 hidden sm:inline">Home</span>
            </.link>
          </div>
          <div class={"transition-colors duration-200 text-[--secondary] hover:text-[--text] #{if @active == :notifications, do: "text-[--text]"}"}>
            <.link navigate={~p"/notifications"} class="flex flex-col items-center">
              <i class="fa-solid fa-envelope text-xl"></i>
              <span class="text-xs mt-2 px-1 hidden sm:inline">Notifications</span>
            </.link>
          </div>
          <div class={"transition-colors duration-200 text-[--secondary] hover:text-[--text] #{if @active == :messages, do: "text-[--text]"}"}>
            <.link navigate={~p"/messages"} class="flex flex-col items-center">
              <i class="fa-solid fa-message text-xl"></i>
              <span class="text-xs mt-2 px-1 hidden sm:inline">Messages</span>
            </.link>
          </div>
          <div
            class="flex flex-col items-center text-[--secondary] transition-colors duration-200 hover:text-[--text]"
            phx-click="create_post_modal"
          >
            <i class="fa-solid fa-plus text-xl"></i>
            <span class="text-xs mt-2 px-1 hidden sm:inline">Post</span>
          </div>
          <div class={"transition-colors duration-200 text-[--secondary] hover:text-[--text] #{if @active == :settings, do: "text-[--text]"}"}>
            <.link navigate={~p"/user/#{@user.id}"} class="flex flex-col items-center">
              <div
                class="w-6 h-6 rounded-full"
                style={"background: var(--gradient-#{@user.gradient})"}
              >
              </div>
              <span class="text-xs mt-2 px-1 hidden sm:inline">Profile</span>
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
