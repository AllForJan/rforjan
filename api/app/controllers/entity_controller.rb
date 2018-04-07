class EntityController < ApplicationController
  def info
    params.require(:entity_id)

    prijimatel = ApaPrijimatelia.where(meno_normalized: params[:entity_id])
    ziadosti = ApaZiadostiOPriamePodporyDiely.where(ziadatel_normalized: params[:entity_id])

    render json: {
        ziadosti: ziadosti,
        prijimatel: prijimatel
    }
  end
end
