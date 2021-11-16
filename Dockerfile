# Extend from the official Elixir image
FROM elixir:latest

RUN apt-get update && apt-get install -y postgresql-client

# Create app directory and copy the Elixir projects into it
RUN mkdir /app
COPY . /app
WORKDIR /app

ENV MIX_ENV=prod
ENV PORT=4000
ENV DATABASE_URL=postgresql://postgres:e95e770ead483835dfa738b086074b21@laurent.tech:22463/bloodbath

# Install hex package manager
# By using --force, we don’t need to type “Y” to confirm the installation
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get --only prod
RUN mix phx.digest

# Compile the project
RUN mix do compile

CMD ["/app/entrypoint.sh"]
