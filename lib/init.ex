defmodule SeedSetup do
  alias CoopSlide.Repo
  alias CoopSlide.Accounts
  alias CoopSlide.Accounts.User

  def run() do
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
  end
end
