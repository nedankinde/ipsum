defmodule IpsumWeb.Components.Sidebar do
  alias IpsumWeb.Components.Button
  use IpsumWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <div class="min-w-[350px] w-1/5 h-full hidden lg:block relative" id="sidebar">
        <div class="py-12 px-8 lg:px-10 flex flex-col h-full overflow-y-auto">
          <%!-- profile --%>
          <div class="p-4 flex gap-4 items-center hover:bg-[--contrast] rounded-xl transition-all duration-200">
            <div
              class="w-12 h-12 rounded-xl shadow-lg"
              style={"background: var(--gradient-#{@user.gradient})"}
            >
            </div>
            <div class="flex flex-col">
              <.link
                class="text-base font-bold truncate w-32 hover:opacity-80 transition-colors"
                navigate={"/user/#{@user.id}"}
              >
                {@user.id}
              </.link>
              <p class="text-xs font-medium text-[--secondary] flex items-center gap-1.5">
                <span class="w-2 h-2 rounded-full bg-[--success] animate-pulse"></span> Online
              </p>
            </div>
          </div>

          <%!-- links --%>
          <div class="flex-1 py-8 text-[--secondary] px-2 flex flex-col gap-3">
            <div class={"group text-lg flex gap-4 items-center p-3 rounded-xl transition-all duration-200 hover:bg-[--contrast] #{if @active == :home, do: "card bg-[--contrast]"}"}>
              <i class="fa-solid fa-home w-8 text-center group-hover:scale-110 transition-transform">
              </i>
              <.link navigate={~p"/"} class="hover:text-[--text] transition-colors">Home</.link>
            </div>
            <div class={"group text-lg flex gap-4 items-center p-3 rounded-xl transition-all duration-200 hover:bg-[--contrast] #{if @active == :notifications, do: "card bg-[--contrast]"}"}>
              <i class="fa-solid fa-envelope w-8 text-center group-hover:scale-110 transition-transform">
              </i>
              <.link navigate={~p"/notifications"} class="hover:text-[--text] transition-colors">
                Notifications
              </.link>
            </div>
            <div class={"group text-lg flex gap-4 items-center p-3 rounded-xl transition-all duration-200 hover:bg-[--contrast] #{if @active == :messages, do: "card bg-[--contrast]"}"}>
              <i class="fa-solid fa-message w-8 text-center group-hover:scale-110 transition-transform">
              </i>
              <.link navigate={~p"/messages"} class="hover:text-[--text] transition-colors">
                Messages
              </.link>
            </div>
            <div class={"group text-lg flex gap-4 items-center p-3 rounded-xl transition-all duration-200 hover:bg-[--contrast] #{if @active == :settings, do: "card bg-[--contrast]"}"}>
              <i class="fa-solid fa-gear w-8 text-center group-hover:scale-110 transition-transform">
              </i>
              <.link navigate={~p"/settings"} class="hover:text-[--text] transition-colors">
                Settings
              </.link>
            </div>
          </div>

          <%!-- post button --%>
          <div class="mb-6">
            <.live_component
              module={Button}
              id="post_button"
              text="New Post"
              event="create_post_modal"
              class="button button-primary w-full py-2 text-sm font-semibold rounded-xl hover:scale-[1.02] transition-transform shadow-lg"
            />
          </div>
        </div>
      </div>
    </div>
    """
  end
end
