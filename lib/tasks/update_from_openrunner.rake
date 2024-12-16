# lib/tasks/hikes.rake
namespace :hikes do
    desc "Met à jour toutes les randonnées depuis OpenRunner"
    task update_all: :environment do
        puts "🚀 Démarrage de la mise à jour de toutes les randonnées..."

        # Récupère toutes les randonnées avec une référence OpenRunner valide
        hikes = Hike.where.not(openrunner_ref: [nil, "", "0"])
        total = hikes.count

        puts "📋 #{total} randonnées à mettre à jour"

        hikes.each_with_index do |hike, index|
            puts "\n[#{index + 1}/#{total}] Traitement de #{hike.trail_name} (ref: #{hike.openrunner_ref})"

            begin
                UpdateHikeFromOpenrunnerJob.perform_now(hike)
            rescue => e
                puts "❌ Échec pour #{hike.trail_name}: #{e.message}"
            end

            # Petit délai entre chaque requête pour éviter de surcharger OpenRunner
            sleep 2
        end

        puts "\n✅ Mise à jour terminée!"
    end
end