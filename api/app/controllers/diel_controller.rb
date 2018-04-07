class DielController < ApplicationController
  def info
    params.require(:diel)

    ziadosti = ApaZiadostiOPriamePodporyDiely.where(diel: params[:diel])

    render json: {
        ziadosti: ziadosti
    }
  end
end
