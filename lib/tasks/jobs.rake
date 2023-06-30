namespace :jobs do
  desc "Run this script to remove duplicate ScrapeProductUrlJobs (with the same url)"
  task clear_scrape_product_url_duplicates: :environment do
    puts "Removing duplicate ScrapeProductUrlJobs (with the same url)..."

    result = ActiveRecord::Base.connection.execute("
      delete from good_jobs
      where serialized_params->>'arguments' IN (
        select serialized_params->>'arguments'
        from good_jobs
        where job_class = 'ScrapeProductUrlJob' and performed_at is null
        group by serialized_params->>'arguments'
        having count(serialized_params->>'arguments') > 1
      )")

    if result.cmd_tuples > 0
      puts "Removed #{result.cmd_tuples} duplicate ScrapeProductUrlJobs (with the same url)"
    else
      puts "No duplicate ScrapeProductUrlJobs (with the same url) found"
    end
  end
end
