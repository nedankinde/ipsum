defmodule IpsumWeb.Components.RecentChats do
  use IpsumWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="w-24 h-full bg-[--darker] flex flex-col py-10 overflow-y-auto"></div>
    """
  end
end
