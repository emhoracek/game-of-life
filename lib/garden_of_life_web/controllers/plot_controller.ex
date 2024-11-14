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

  def new(conn, params) do
    changeset =
      %Plot{}
      |> Ecto.Changeset.change(params)
      |> Phoenix.Component.to_form()

    conn
    |> assign(:changeset, changeset)
    |> render(:new)
  end

  def create(conn, params) do
    changeset = Plot.changeset(%Plot{}, params["plot"])

    if changeset.valid? do
      {res, plot} = Repo.insert(changeset)

      case res do
        :ok ->
          redirect(conn, to: ~p"/garden/#{plot.name}")

        _ ->
          redirect(conn, to: ~p"/plots/new")
      end
    else
      redirect(conn, to: ~p"/plots/new")
    end
  end
end
