class EntityController < ApplicationController
  def info
    params.require(:entity_id)

    ziadosti = ApaZiadostiOPriamePodporyDiely.where(ziadatel_normalized: params[:entity_id]).to_a
    icos = ziadosti.map(&:ico).compact.uniq

    prijimatel_through_meno = ApaPrijimatelia.where(meno_normalized: params[:entity_id]).to_a

    prijimatel_ico_map = ApaPrijimatelia.joins(<<-SQL)
      join prijimatelia_finstat 
        on prijimatelia_finstat.prijimatelia_id = apa_prijimatelia.id
      join finstat
        on finstat.id = prijimatelia_finstat.finstat_id
    SQL
      .where(finstat: { ico: icos }).pluck(:id, :ico).to_h

    prijimatel_through_ico = ApaPrijimatelia.where(id: prijimatel_ico_map.keys).to_a

    prijimatel = (prijimatel_through_meno + prijimatel_through_ico).uniq(&:id)

    render json: {
        ziadosti: ziadosti.group_by(&:rok).map do |rok, ziadosti_rok|
          [
              rok,
              ziadosti_rok.group_by { |z| [z.ziadatel, z.ico, z.lokalita, z.diel, z.kultura] }.map do |key, ziadosti_diel_kultura|
                {
                    ziadatel: key[0],
                    ico: key[1],
                    lokalita: key[2],
                    diel: key[3],
                    kultura: key[4],
                    pocet_ziadosti: ziadosti_diel_kultura.size,
                    vymera_ziadosti: ziadosti_diel_kultura.sum(&:vymera)
                }
              end
          ]
        end.to_h,
        prijimatel: prijimatel.group_by(&:rok).map do |rok, prijimatel_rok|
          [
              rok,
              prijimatel_rok.group_by { |p| [p.meno, prijimatel_ico_map[p.id], p.psc, p.obec, p.opatrenie] }.map do |key, prijimatel_obec_opatrenie|
                {
                    ziadatel: key[0],
                    ico: key[1],
                    psc: key[2],
                    obec: key[3],
                    opatrenie: key[4],
                    pocet_prijmov: prijimatel_obec_opatrenie.size,
                    suma_prijmov: prijimatel_obec_opatrenie.sum(&:suma)
                }
              end
          ]
        end.to_h
    }
  end

  def distances
    params.require(:entity_ico)

    ico = params[:entity_ico]
    address = ApaPrijimatelia.get_address_for_ico(ico)

    address['point_json'] = JSON.parse(address['point_json'])

    render json: { error: 'Adresa nenajdena' }, status: :not_found and return unless address

    diely = ApaZiadostiOPriamePodporyDiely.vzdialenosti(ico, address['point'],2016).collect do |diel|
      {
          lokalita: diel['lokalita'],
          diel: diel['diel'],
          kultura: diel['kultura'],
          vymera: diel['vymera'],
          vzdialenost: diel['distance'],
          geometria: JSON.parse(diel['diel_geometria'])
      }
    end

    render json: {
        adresa: address,
        diely: diely
    }
  end
end
