defmodule IpsumWeb.Components.Searchbar do
  use IpsumWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="w-full pb-5 flex justify-center">
      <div class="relative">
        <input
          class="input input-primary w-full md:w-auto px-12 py-3 rounded-full"
          placeholder="Search Ipsum..."
          type="search"
          autocomplete="off"
        />
        <div class="absolute inset-y-0 left-5 flex items-center pointer-events-none">
          <i class="fas fa-search text-gray-400 text-md"></i>
        </div>
      </div>
    </div>
    """
  end
end
