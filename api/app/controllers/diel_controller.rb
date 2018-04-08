class DielController < ApplicationController
  def info
    params.require([:lokalita, :diel])

    ziadosti = ApaZiadostiOPriamePodporyDiely.where(
        lokalita: params[:lokalita],
        diel: params[:diel]
    )

    render json: (ziadosti.group_by(&:rok).sort_by(&:first).map do |rok, ziadosti_rok|
      ziadatelia = ziadosti_rok.map(&:ziadatel_normalized).uniq

      [
          rok,
          ziadatelia.map do |ziadatel|
            ziadosti_ziadatel = ziadosti_rok.select { |z| z.ziadatel_normalized == ziadatel }
            prijimatelia_ziadatel = ApaPrijimatelia.where(meno_normalized: ziadatel, rok: rok).to_a

            [
                ziadatel,
                {
                  ziadosti: ziadosti_ziadatel.group_by { |z| [z.ziadatel, z.ico] }.map do |key, ziadosti_ico|
                    {
                        ziadatel: key[0],
                        ico: key[1],
                        pocet_ziadosti: ziadosti_ico.count,
                        celkova_vymera: ziadosti_ico.sum(&:vymera)
                    }
                  end,
                  prijimatelia: prijimatelia_ziadatel.group_by { |p| [p.meno, p.obec, p.psc] }.map do |key, prijimatelia_obec|
                    {
                        meno: key[0],
                        obec: key[1],
                        psc: key[2],
                        pocet_prijmov: prijimatelia_obec.count,
                        suma_prijmov: prijimatelia_obec.sum(&:suma)
                    }
                  end
                }
            ]
          end.to_h
      ]
    end).to_h
  end
end
