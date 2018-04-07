class EchoController < ApplicationController
  def ping
    render json: {ping: 'pong'}
  end
end
