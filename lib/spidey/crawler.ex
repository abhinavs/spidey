defmodule Spidey.Crawler do
  alias Spidey.Logger
  alias Spidey.Filter
  alias Spidey.Crawler.{UrlStore, Queue, Content}

  @typedoc """
  The options passed to `Spidey.Crawler.crawl/3`. Currently only allows the
  specification of the filter to apply to crawled URLs, uses
  `Spidey.Filter.DefaultFilter` by default.
  """
  @type crawl_options :: [filter: module()]

  @doc """
  Crawls a given url synchronously through a supervision tree under the name of
  `pool_name`. It accepts the filter to apply to crawled urls through the
  `filter` option.
  """
  @spec crawl(String.t(), atom(), crawl_options()) :: [String.t()]
  def crawl(seed, pool_name, opts) do
    filter = Keyword.get(opts, :filter, Spidey.Filter.DefaultFilter)

    Logger.log("starting crawler supervision tree #{pool_name}")
    {:ok, pid} = Spidey.Crawler.Supervisor.start_link(pool_name, [])

    try do
      Logger.log("starting ETS table #{pool_name}")
      UrlStore.init!(seed, pool_name)

      Queue.push(seed, pool_name)
      crawl_queue(pool_name, seed, filter)
    after
      Logger.log("terminating crawler supervision tree #{pool_name}")
      Process.exit(pid, :normal)

      Logger.log("terminating ETS table #{pool_name}")
      UrlStore.teardown(pool_name)
    end
  end

  defp crawl_queue(pool_name, seed, filter) do
    queue_length = Queue.length(pool_name)

    if queue_length == 0 do
      Logger.log("no urls remaining in queue. Returning all urls")
      UrlStore.retrieve_all(pool_name)
    else
      max_concurrency = System.schedulers_online()

      Logger.log(
        "attempting to crawl #{queue_length} urls at a concurrent rate of #{max_concurrency}"
      )

      urls = Queue.take(queue_length, pool_name)

      Task.Supervisor.async_stream(
        :"#{pool_name}TaskSupervisor",
        urls,
        fn url ->
          url
          |> Content.scan()
          |> Filter.filter_urls(filter, seed: seed)
          |> Stream.reject(&UrlStore.exists?(&1, pool_name))
          |> Stream.each(&push_to_stores(&1, pool_name))
          |> Stream.run()
        end,
        timeout: 10_000,
        on_timeout: :kill_task
      )
      |> Stream.run()

      crawl_queue(pool_name, seed, filter)
    end
  end

  defp push_to_stores(url, pool_name) do
    Queue.push(url, pool_name)
    UrlStore.add(url, pool_name)
  end
end
