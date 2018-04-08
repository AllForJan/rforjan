class EntityController < ApplicationController
  def info
    params.require(:entity_id)

    ziadosti = ApaZiadostiOPriamePodporyDiely.where(ziadatel_normalized: params[:entity_id]).to_a
    icos = ziadosti.map(&:ico).compact.uniq

    prijimatel_through_meno = ApaPrijimatelia.where(meno_normalized: params[:entity_id]).to_a
    prijimatel_through_ico = ApaPrijimatelia.where(id: ApaPrijimatelia.joins(:finstat).merge(Finstat.where(ico: icos)).select(:id)).to_a
    prijimatel = (prijimatel_through_meno + prijimatel_through_ico).uniq(&:id)

    ico_by_prijimatel_id = PrijimateliaFinstat.where(prijimatelia_id: prijimatel.map(&:id)).joins(:finstat).pluck('prijimatelia_id, ico').to_h
    ico_by_ziadatel_normalized = ziadosti.map { |ziadost| [ziadost.ziadatel_normalized, ziadost.ico] }.to_h

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
              prijimatel_rok.group_by { |p| [p.meno, ico_by_prijimatel_id[p.id] || ico_by_ziadatel_normalized[p.meno_normalized], p.psc, p.obec, p.opatrenie] }.map do |key, prijimatel_obec_opatrenie|
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

  def distances_stats
    cache_path = "#{Rails.root}/tmp/prijimatelia_stats"

    stats = if !File.exist?(cache_path) || File.empty?(cache_path) || params[:reload]
              data = ApaPrijimatelia.get_distance_stats.collect do |row|
                {
                    meno_normalized: row['meno_normalized'],
                    average_distance: row['average_distance'],
                    max_distance: row['max_distance'],
                    position: JSON.parse(row['location'])
                }
              end

              File.open(cache_path,"w") { |f| f.write(data.to_json) }

              data
            else
              JSON.parse(File.read(cache_path))
            end

    render json: {
        stats: stats
    }
  end
end
