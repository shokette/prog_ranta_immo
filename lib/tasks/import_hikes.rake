# lib/tasks/import_hikes.rake
require 'csv'

namespace :hikes do
    desc 'Import hikes from CSV file'
    task import: :environment do

        def convert_num(value)
            return nil if value.nil? || value.to_s.strip.empty?

            # Première tentative : conversion directe en integer
            begin
                return value.to_i
            rescue ArgumentError, TypeError
                # Continue si la conversion directe échoue
            end

            # Deuxième tentative : extraire uniquement les chiffres
            digits_only = value.to_s.gsub(/[^\d]/, '')

            # Vérifier si on a des chiffres après le nettoyage
            return digits_only.to_i if digits_only.present?

            # En dernier recours
            nil
        end

        log_file = Rails.root.join('log', 'hikes_import.log')
        csv_file = Rails.root.join('lib', 'data', 'progrando_hikes.csv')

        File.open(log_file, 'a') do |log|
            log.puts "\n=== Import started at #{Time.current} ==="

            begin
                rows = CSV.read(csv_file,
                                headers: true,
                                encoding: 'utf-8',
                                col_sep: ',')

                puts "Headers found: #{rows.headers.inspect}" # Pour debug

                rows.each do |row|
                    begin

                        hike = Hike.find_or_initialize_by(number: row['Numero'])
                        hike.assign_attributes(
                            day: row['D'],
                            difficulty: row['Dif.'] || 1,
                            starting_point: row['Depart de la randonnee'],
                            trail_name: row['Parcours'],
                            carpooling_cost: convert_num(row['C.V. *']),
                            distance_km: convert_num(row['Kl']),
                            elevation_gain: convert_num(row['m']),
                            openrunner_ref: convert_num(row['Ref Openrunner']) || 0,
                        )

                        if hike.save
                            log.puts "Successfully imported hike ##{hike.number}"
                        else
                            log.puts "Error importing hike ##{row['Numero']}: #{hike.errors.full_messages.join(', ')}"
                        end
                    rescue StandardError => e
                        log.puts "Error processing row #{row['Numero']}: #{e.message}"
                        puts e.message # Pour debug
                    end
                end

            rescue StandardError => e
                log.puts "Fatal error during import: #{e.message}"
                log.puts e.backtrace
                puts e.message # Pour debug
            end

            log.puts "=== Import finished at #{Time.current} ==="
        end
    end
end