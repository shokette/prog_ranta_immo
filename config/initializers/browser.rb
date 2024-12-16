require "browser"

Rails.application.config.middleware.use(Browser::Middleware) do
    false # Retourne false pour continuer la chaîne de middleware
end