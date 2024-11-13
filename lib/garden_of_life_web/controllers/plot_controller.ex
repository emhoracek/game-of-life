defmodule GardenOfLifeWeb.PlotController do
  use GardenOfLifeWeb, :controller
  import Ecto.Query
  alias GardenOfLife.{Repo, Plot}

  def index(conn, _params) do
    plots = Repo.all(from(p in Plot))

    conn
    |> assign(:plots, plots)
    |> render(:index)
  end

  def show(conn, %{"id" => id}) do
    plot = Repo.one(from p in Plot, where: p.name == ^id)

    conn
    |> assign(:plot, plot)
    |> render(:show)
  end
end
