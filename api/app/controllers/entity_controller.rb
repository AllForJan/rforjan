class EntityController < ApplicationController
  def info
    params.require(:entity_id)

    prijimatel = ApaPrijimatelia.where(meno_normalized: params[:entity_id])
    ziadosti = ApaZiadostiOPriamePodporyDiely.where(ziadatel_normalized: params[:entity_id])

    render json: {
        ziadosti: ziadosti.group_by(&:rok).map do |rok, ziadosti_rok|
          [
              rok,
              ziadosti_rok.group_by { |z| [z.lokalita, z.diel, z.kultura] }.map do |key, ziadosti_diel_kultura|
                {
                    lokalita: key[0],
                    diel: key[1],
                    kultura: key[2],
                    pocet_ziadosti: ziadosti_diel_kultura.size,
                    vymera_ziadosti: ziadosti_diel_kultura.sum(&:vymera)
                }
              end
          ]
        end.to_h,
        prijimatel: prijimatel.group_by(&:rok).map do |rok, prijimatel_rok|
          [
              rok,
              prijimatel_rok.group_by { |p| [p.psc, p.obec, p.opatrenie] }.map do |key, prijimatel_obec_opatrenie|
                {
                    psc: key[0],
                    obec: key[1],
                    opatrenie: key[2],
                    pocet_prijmov: prijimatel_obec_opatrenie.size,
                    suma_prijmov: prijimatel_obec_opatrenie.sum(&:suma)
                }
              end
          ]
        end.to_h
    }
  end
end
