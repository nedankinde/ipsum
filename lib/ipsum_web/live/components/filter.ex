defmodule IpsumWeb.Components.Filter do
  use IpsumWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="w-full mx-auto my-6 font-semibold">
      <div class="flex ">
        <a class="grow px-4 py-3 cursor-pointer flex gap-3 place-items-center justify-center text-sm hover:text-primary border-b-2 border-[--primary] translate-y-[1px]">
          <i class="fas fa-user text-xs mr-1"></i>For you
        </a>
        <a class="grow px-4 py-3 cursor-pointer flex gap-3 place-items-center justify-center text-sm hover:text-primary">
          <i class="fas fa-users text-xs mr-1"></i>Following
        </a>
      </div>
    </div>
    """
  end
end
