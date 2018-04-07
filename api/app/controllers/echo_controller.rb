class EchoController < ApplicationController
  def ping
    render json: {
        ping: 'pong',
        apa_prijimatelia_count: ApaPrijimatelia.count
    }
  end
end
