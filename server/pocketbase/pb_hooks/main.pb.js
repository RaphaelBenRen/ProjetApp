/// <reference path="../pb_data/types.d.ts" />


cronAdd("sync_rappels", "0 8,20 * * *", () => {
    try {

        const url = "https://codelabs.formation-flutter.fr/assets/rappels.json"

        const res = $http.send({
            url: url,
            method: "GET",
            timeout: 30, // seconds
        })

        if (res.statusCode != 200) {
            console.log("Error fetching data:", res.statusCode)
            return
        }

        let items = []
        const raw = res.json
        if (Array.isArray(raw)) {
            items = raw
        } else if (raw.list && Array.isArray(raw.list)) {
            items = raw.list
        } else if (raw.results && Array.isArray(raw.results)) {
            items = raw.results
        } else {
            console.log("Unknown API format:", JSON.stringify(raw).substring(0, 100))
            return
        }

        const collection = $app.findCollectionByNameOrId("rappels")

        $app.runInTransaction((txApp) => {
            for (let item of items) {

                const uniqueId = item.identification_produits

                if (!uniqueId) continue // Skip si pas d'ID

                let record
                try {
                    record = txApp.findFirstRecordByData("rappels", "identification_produits", uniqueId)
                } catch (e) {
                    // Record not found
                    record = null
                }

                if (!record) {
                    // Create new record
                    record = new Record(collection)
                }

                // Mapping des champs
                record.set("gtin", item.gtin ? String(item.gtin) : "")
                record.set("numero_fiche", item.numero_fiche)
                record.set("identification_produits", uniqueId)
                record.set("libelle", item.libelle)
                record.set("marque_produit", item.marque_produit)
                record.set("motif_rappel", item.motif_rappel)
                record.set("risques_encourus", item.risques_encourus)
                record.set("conduites_a_tenir_par_le_consommateur", item.conduites_a_tenir_par_le_consommateur)


                record.set("liens_vers_les_images", item.liens_vers_les_images)
                record.set("lien_vers_affichette_pdf", item.lien_vers_affichette_pdf)


                if (item.date_publication) record.set("date_publication", item.date_publication)
                if (item.date_debut_commercialisation) record.set("date_debut_commercialisation", item.date_debut_commercialisation + " 00:00:00.000Z")
                if (item.date_date_fin_commercialisation) record.set("date_date_fin_commercialisation", item.date_date_fin_commercialisation + " 00:00:00.000Z")

                record.set("distributeurs", item.distributeurs)
                record.set("zone_geographique_de_vente", item.zone_geographique_de_vente)
                record.set("informations_complementaires", item.informations_complementaires)
                record.set("rappel_guid", item.rappel_guid)
                record.set("id_source", item.id)

                txApp.save(record)
            }
        })

        console.log(`Synced ${items.length} items successfully`)

    } catch (err) {
        console.log("Cron error:", err)
    }
})
