class DielController < ApplicationController
  def info
    params.require([:lokalita, :diel])

    ziadosti = ApaZiadostiOPriamePodporyDiely.where(
        lokalita: params[:lokalita],
        diel: params[:diel]
    )

    render json: (ziadosti.group_by(&:rok).sort_by(&:first).map do |rok, ziadosti|
      [
          rok,
          ziadosti.map do |ziadost|
            ziadost.attributes.merge(
                celkova_suma: ApaPrijimatelia.celkova_suma(ziadost.ziadatel, rok),
                celkova_vymera: ApaZiadostiOPriamePodporyDiely.celkova_vymera(ziadost.ziadatel, rok),
                pocet_dielov: ApaZiadostiOPriamePodporyDiely.pocet_dielov(ziadost.ziadatel, rok, ),
                pocet_ziadosti: ApaZiadostiOPriamePodporyDiely.pocet_ziadosti(ziadost.ziadatel, rok)
            )
          end
      ]
    end).to_h
  end
end
