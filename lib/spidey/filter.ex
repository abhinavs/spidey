defmodule Spidey.Filter do
  @doc "Filters the urls"
  @callback filter_urls(urls :: [String.t()], opts :: [Keyword.t()]) :: [String.t()]

  def filter_urls(urls, filter, opts \\ []) do
    urls
    |> filter.filter_urls(opts)
    |> Stream.uniq()
  end
end
