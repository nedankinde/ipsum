defmodule IpsumWeb.Components.Button do
  use IpsumWeb, :live_component

  def render(assigns) do
    ~H"""
    <button class={"button #{@class}"} phx-click={@event}>
      {@text}
    </button>
    """
  end
end
