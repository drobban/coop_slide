# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     CoopSlide.Repo.insert!(%CoopSlide.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias CoopSlide.Repo
alias CoopSlide.Accounts
alias CoopSlide.Accounts.User

user = Accounts.get_user_by_email("david@conrock-software.se")

user =
  if !user do
    User.registration_changeset(%User{}, %{
      email: "david@conrock-software.se",
      password: "123456789qwerty"
    })
    |> User.confirm_changeset()
    |> Repo.insert!()
  else
    user
  end
