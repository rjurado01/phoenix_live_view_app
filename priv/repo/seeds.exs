# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     App.Repo.insert!(%App.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
{:ok, user} = App.User.create(%{
  email: "admin@email.com",
  password: "asdfasdf",
  password_confirmation: "asdfasdf",
  role: "admin"
})

user
|> App.User.confirm_email_changeset(%{})
|> App.User.update %{current_password: "asdfasdf"}

for x <- 1..10 do
  {:ok, user} = App.User.create(%{
    email: "user#{x}@email.com",
    password: "asdfasdf",
    password_confirmation: "asdfasdf"})

  user
  |> App.User.confirm_email_changeset(%{})
  |> App.User.update %{current_password: "asdfasdf"}
end
