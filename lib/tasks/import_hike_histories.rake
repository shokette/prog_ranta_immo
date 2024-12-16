require 'csv'
require 'date'

namespace :hike_histories do
    desc 'Import hike histories from CSV file'
    task import: :environment do
        log_file = Rails.root.join('log', 'hike_histories_import.log')
        csv_file = Rails.root.join('lib', 'data', 'progrando_progs.csv')

        FRENCH_MONTHS = {
            'janvier' => 1,
            'fevrier' => 2,
            'février' => 2,
            'mars' => 3,
            'avril' => 4,
            'mai' => 5,
            'juin' => 6,
            'juillet' => 7,
            'aout' => 8,
            'août' => 8,
            'septembre' => 9,
            'octobre' => 10,
            'novembre' => 11,
            'decembre' => 12,
            'décembre' => 12
        }.freeze

        def normalize_string(str)
            # Convertir en minuscules et retirer les accents
            str = str.to_s.downcase
            {
                'é' => 'e', 'è' => 'e', 'ê' => 'e',
                'à' => 'a', 'â' => 'a',
                'ï' => 'i', 'î' => 'i',
                'û' => 'u', 'ù' => 'u',
                'ô' => 'o',
                'ç' => 'c'
            }.each do |accent, sans_accent|
                str = str.gsub(accent, sans_accent)
            end
            str
        end

        def parse_date(date_value)
            return nil if date_value.blank?
            return date_value if date_value.is_a?(Date)

            begin
                # Regex modifiée pour accepter les caractères accentués
                if date_value =~ /([[:alpha:]]+),\s+([[:alpha:]]+)\s+(\d{2}),\s+(\d{4})/
                    month_name = normalize_string($2)
                    day = $3.to_i
                    year = $4.to_i

                    # Debug
                    # puts "Original date: #{date_value}"
                    # puts "Normalized month: #{month_name}"
                    # puts "Month number: #{FRENCH_MONTHS[month_name]}"
                    # puts "Day: #{day}"
                    # puts "Year: #{year}"

                    # Convert French month name to number
                    month = FRENCH_MONTHS[month_name]

                    if month
                        begin
                            return Date.new(year, month, day)
                        rescue ArgumentError => e
                            puts "Error creating date object: #{e.message}"
                            nil
                        end
                    else
                        puts "Month not found in dictionary: #{month_name}"
                    end
                else
                    puts "Date format doesn't match pattern: #{date_value}"
                end

                # Fallback to default parsing
                Date.parse(date_value.to_s)
            rescue ArgumentError, TypeError => e
                puts "Error parsing date '#{date_value}': #{e.message}"
                nil
            end
        end

        def clean_number(str)
            return nil if str.blank?
            str.gsub(',', '.').strip
        end

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

        File.open(log_file, 'a') do |log|
            log.puts "\n=== Import started at #{Time.current} ==="

            begin
                rows = CSV.read(csv_file,
                                headers: true,
                                encoding: 'utf-8',
                                col_sep: ',')

                rows.each do |row|
                    begin
                        # Utilise uniquement la colonne "Dates" pour hiking_date
                        hiking_date = parse_date(row['Dates'])

                        unless hiking_date
                            log.puts "Skipping row: Invalid date format in Dates column: #{row['Dates']}"
                            next
                        end

                        # Clean numbers
                        carpooling_cost = convert_num(row['* C.V.'])

                        member = Member.find_or_initialize_by(phone: row['Tel.']&.strip)

                        member.assign_attributes(name: row['Animateur']&.strip)
                        member.save(validate: false)
                        history = HikeHistory.find_or_initialize_by(
                            hiking_date: parse_date(hiking_date),
                            openrunner_ref: convert_num(row['Ref']&.strip))
                        hike_id = Hike.find_by(number: convert_num(row['Ref']))&.id
                        hike_id = Hike.find_by(number: convert_num(row['N°']))&.id if hike_id.nil?
                        history.assign_attributes(
                            departure_time: row['Depart']&.strip,
                            day_type: row['Journee']&.strip,
                            carpooling_cost: carpooling_cost,
                            member_id: member&.id,
                            hike_id: hike_id,
                        )

                        if history.save(validate: false)
                            puts "Successfully imported history for hike ##{history.hike_id} on #{history.hiking_date}"
                            log.puts "Successfully imported history for hike ##{history.hike_id} on #{history.hiking_date}"
                        else
                            log.puts "Error importing history for hike ##{row['N°']}: #{history.errors.full_messages.join(', ')}"
                        end
                    rescue StandardError => e
                        log.puts "Error processing row: #{e.message}"
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