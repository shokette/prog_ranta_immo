class StatsController < ApplicationController
    def dashboard
        @stats = {
            total_hikes: fetch_total_hikes,
            total_distance: fetch_total_distance,
            total_elevation: fetch_total_elevation,
            active_guides: fetch_active_guides,
            monthly_stats: fetch_monthly_stats,
            guide_stats: fetch_guide_stats,
        }
        @last_hikes = fetch_last_hikes
    end

    private

    def fetch_last_hikes
        Hike.joins(:latest_history)
            .select('hikes.*, hike_histories.hiking_date, members.name as member_name')
            .joins('LEFT JOIN members ON members.id = hike_histories.member_id')
            .where('hike_histories.hiking_date < ?', Date.current)
            .order('hike_histories.hiking_date DESC')
            .limit(10)
    end

    def fetch_total_hikes
        Hike.joins(:latest_history)
            .where('hike_histories.hiking_date >= ?', Date.current.beginning_of_year)
            .distinct
            .count
    end

    def fetch_total_distance
        HikeHistory.joins(:hike)
                   .sum('hikes.distance_km')
    end

    def fetch_total_elevation
        HikeHistory.joins(:hike)
                   .sum('hikes.elevation_gain')
    end

    def fetch_active_guides
        Hike.joins(:latest_history)
            .where('hike_histories.hiking_date >= ?', Date.current.beginning_of_month)
            .distinct
            .count
    end

    def fetch_monthly_stats
        stats = Hike.joins(:latest_history)
                    .where('hike_histories.hiking_date >= ?', 1.year.ago)
                    .group("DATE_FORMAT(hike_histories.hiking_date, '%Y-%m')")
                    .distinct
                    .count

        formatted_stats = stats.transform_keys { |k| Date.parse(k + '-01').strftime('%b') }
        last_12_months = 12.times.map { |i| i.months.ago.strftime('%b') }.reverse

        last_12_months.each_with_object({}) { |month, hash|
            hash[month] = formatted_stats[month] || 0
        }
    end

    def fetch_guide_stats
        HikeHistory.joins(:member)
                   .where('hiking_date >= ?', 1.year.ago)
                   .where.not(members: { name: nil })
                   .group('members.name')
                   .order('count_all DESC')
                   .limit(10)
                   .count
    end
end