# lib/tasks/deduplicate_hikes.rake
namespace :hikes do
    desc "Merge duplicate hikes based on openrunner_ref and migrate their histories"
    task deduplicate: :environment do
        # Logger pour suivre les opérations
        logger = Logger.new(STDOUT)
        logger.level = Logger::INFO

        logger.info "Starting hikes deduplication process..."

        # Trouver tous les openrunner_ref qui ont des doublons
        duplicate_refs = Hike.where.not(openrunner_ref: [nil, "", "0"])
                             .group(:openrunner_ref)
                             .having("COUNT(*) > 1")
                             .pluck(:openrunner_ref)

        logger.info "Found #{duplicate_refs.size} openrunner references with duplicates"

        ActiveRecord::Base.transaction do
            begin
                duplicate_refs.each do |ref|
                    # Récupérer tous les hikes avec ce openrunner_ref
                    duplicate_hikes = Hike.where(openrunner_ref: ref).order(:created_at)

                    # Le premier hike sera conservé (le plus ancien)
                    hike_to_keep = duplicate_hikes.first
                    hikes_to_remove = duplicate_hikes[1..]

                    logger.info "Processing openrunner_ref #{ref}:"
                    logger.info "  - Keeping hike ##{hike_to_keep.id} (#{hike_to_keep.trail_name})"

                    hikes_to_remove.each do |hike|
                        logger.info "  - Migrating histories from hike ##{hike.id} (#{hike.trail_name})"

                        # Migrer les historiques vers le hike conservé
                        HikeHistory.where(hike_id: hike.number).update_all(hike_id: hike_to_keep.id)

                        # Supprimer le hike doublon
                        logger.info "  - Removing duplicate hike ##{hike.id}"
                        hike.destroy
                    end
                end

                logger.info "Deduplication completed successfully"

                # Afficher un résumé
                logger.info "\nSummary:"
                logger.info "- Processed #{duplicate_refs.size} duplicate groups"
                logger.info "- Remaining hikes: #{Hike.count}"
                logger.info "- Total histories: #{HikeHistory.count}"

            rescue => e
                logger.error "Error during deduplication: #{e.message}"
                logger.error e.backtrace.join("\n")
                raise ActiveRecord::Rollback
            end
        end
    end

    # Tâche pour afficher uniquement les doublons sans les traiter
    desc "List duplicate hikes based on openrunner_ref"
    task list_duplicates: :environment do
        logger = Logger.new(STDOUT)

        duplicate_refs = Hike.where.not(openrunner_ref: [nil, "", "0"])
                             .group(:openrunner_ref)
                             .having("COUNT(*) > 1")
                             .pluck(:openrunner_ref)

        if duplicate_refs.empty?
            logger.info "No duplicates found"
        else
            logger.info "Found #{duplicate_refs.size} duplicate groups:"

            duplicate_refs.each do |ref|
                hikes = Hike.where(openrunner_ref: ref)
                logger.info "\nOpenrunner ref #{ref}:"
                hikes.each do |hike|
                    histories_count = HikeHistory.where(hike_id: hike.id).count
                    logger.info "- #{hike.trail_name} (ID: #{hike.id}, Histories: #{histories_count})"
                end
            end
        end
    end
end