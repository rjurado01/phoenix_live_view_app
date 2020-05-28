defmodule App.Model do
  defmacro __using__(_params) do
    quote do
      use Ecto.Schema
      use Ecto.Schema

      import Ecto.Changeset
      import Ecto.Query, only: [dynamic: 2]

      alias App.Repo

      def changeset(attrs) do
        changeset(struct(__MODULE__), attrs)
      end

      def all do
        __MODULE__ |> Repo.all
      end

      def first do
        __MODULE__ |> Repo.first
      end

      def last do
        __MODULE__ |> Repo.last
      end

      def count do
        __MODULE__ |> Repo.count
      end

      def get(id) do
        try do
          __MODULE__ |> Repo.get(id)
        rescue
          Ecto.Query.CastError -> nil
        end
      end

      def create(attrs) do
        create(:changeset, attrs)
      end

      def create(changeset_name, attrs) do
        apply(__MODULE__, changeset_name, [attrs]) |> Repo.insert
      end

      def update(object, attrs) do
        update(object, :changeset, attrs)
      end

      def update(object, changeset_name, attrs) do
        apply(__MODULE__, changeset_name, [object, attrs]) |> Repo.update
      end

      defdelegate delete(object), to: Repo
    end
  end
end
