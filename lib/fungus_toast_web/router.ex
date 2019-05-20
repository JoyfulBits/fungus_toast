defmodule FungusToastWeb.Router do
  use FungusToastWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug ProperCase.Plug.SnakeCaseParams
  end

  scope "/", FungusToastWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api", FungusToastWeb do
    pipe_through :api

    resources "/games", GameController, only: [:show, :create] do
      resources "/players", PlayerController, except: [:new, :edit] do
        resources "/skills", PlayerSkillController, only: [:index], as: :skill
        post "/skills", PlayerSkillController, :update, as: :skill
      end

      resources "/rounds", RoundController, only: [:show, :create]
    end

    resources "/game-invitations", JoinedGameController, only: [:create] do

    end

    resources "/users", UserController, except: [:new, :edit] do
      get "/games", GameController, :index, as: :game
    end

    resources "/skills", SkillController, only: [:index] do
      get "/skills", SkillController, :index, as: :skills
    end
  end
end
